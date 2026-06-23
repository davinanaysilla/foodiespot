<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\TempatMakan;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class TempatMakanController extends Controller
{
    // --- 1. READ (Lihat Semua Tempat Makan + Fitur Pencarian) ---
    public function index(Request $request)
    {
        $query = TempatMakan::latest();

        // Filter berdasarkan kata kunci pencarian
        if ($request->has('search') && $request->search != '') {
            $keyword = $request->search;
            $query->where('name', 'like', '%' . $keyword . '%')
                  ->orWhere('address', 'like', '%' . $keyword . '%')
                  ->orWhere('description', 'like', '%' . $keyword . '%');
        }

        $tempatMakan = $query->get();

        return response()->json([
            'status' => 'success',
            'data'   => $tempatMakan
        ], 200);
    }

    // --- 2. NEARBY (Cari Tempat Makan Terdekat via GPS / LBS) ---
    // Menggunakan Haversine Formula untuk menghitung jarak antara dua koordinat GPS
    public function nearby(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'latitude'  => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'radius'    => 'nullable|numeric|min:0.1|max:100', // Radius dalam km, default 10km
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $userLat    = $request->latitude;
        $userLng    = $request->longitude;
        $radiusKm   = $request->radius ?? 10; // Default 10 km
        $earthRadius = 6371; // Radius bumi dalam kilometer

        // Query Haversine Formula langsung di SQL untuk efisiensi
        $tempatMakanList = TempatMakan::select('*')
            ->selectRaw(
                "( {$earthRadius} * ACOS(
                    COS(RADIANS(?)) * COS(RADIANS(latitude)) *
                    COS(RADIANS(longitude) - RADIANS(?)) +
                    SIN(RADIANS(?)) * SIN(RADIANS(latitude))
                )) AS distance",
                [$userLat, $userLng, $userLat]
            )
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->having('distance', '<=', $radiusKm)
            ->orderBy('distance', 'asc')
            ->get();

        return response()->json([
            'status'     => 'success',
            'user_location' => [
                'latitude'  => $userLat,
                'longitude' => $userLng,
            ],
            'radius_km'  => $radiusKm,
            'total'      => $tempatMakanList->count(),
            'data'       => $tempatMakanList
        ], 200);
    }

    // --- 3. SHOW (Lihat Detail Satu Tempat Makan) ---
    public function show($id)
    {
        $tempatMakan = TempatMakan::with(['reviews.user:id,name,photo_url', 'photos', 'owner:id,name'])->find($id);

        if (!$tempatMakan) {
            return response()->json(['status' => 'error', 'message' => 'Tempat makan tidak ditemukan'], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $tempatMakan
        ], 200);
    }

    // --- 4. KHUSUS OWNER (Lihat Warung Milik Sendiri) ---
    public function myTempatMakan(Request $request)
    {
        if ($request->user()->role !== 'owner') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Mitra/Owner.'], 403);
        }

        $tempatMakan = TempatMakan::where('user_id', $request->user()->id)->latest()->get();

        return response()->json([
            'status' => 'success',
            'data'   => $tempatMakan
        ], 200);
    }

    // --- 5. CREATE (Buka Warung Baru) ---
    public function store(Request $request)
    {
        if ($request->user()->role !== 'owner' && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Hanya Owner atau Admin yang bisa menambah tempat makan'], 403);
        }

        $validator = Validator::make($request->all(), [
            'name'        => 'required|string|max:255',
            'description' => 'required|string',
            'address'     => 'required|string',
            'latitude'    => 'nullable|numeric|between:-90,90',
            'longitude'   => 'nullable|numeric|between:-180,180',
            'image'       => 'nullable|image|mimes:jpeg,png,jpg|max:4096',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $imageUrl = null;
        if ($request->hasFile('image')) {
            $imageUrl = $request->file('image')->store('tempat_makan_cover', 'public');
        }

        $tempatMakan = TempatMakan::create([
            'user_id'     => $request->user()->id,
            'name'        => $request->name,
            'description' => $request->description,
            'address'     => $request->address,
            'latitude'    => $request->latitude,
            'longitude'   => $request->longitude,
            'image_url'   => $imageUrl,
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Tempat makan berhasil ditambahkan',
            'data'    => $tempatMakan
        ], 201);
    }

    // --- 6. UPDATE (Edit Informasi Warung) ---
    public function update(Request $request, $id)
    {
        $tempatMakan = TempatMakan::find($id);

        if (!$tempatMakan) {
            return response()->json(['status' => 'error', 'message' => 'Data tidak ditemukan'], 404);
        }

        // Hanya PEMILIK ASLI atau ADMIN yang boleh mengedit
        if ($tempatMakan->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki akses untuk mengedit warung ini'], 403);
        }

        $validator = Validator::make($request->all(), [
            'name'        => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'address'     => 'sometimes|required|string',
            'latitude'    => 'sometimes|nullable|numeric|between:-90,90',
            'longitude'   => 'sometimes|nullable|numeric|between:-180,180',
            'image'       => 'sometimes|nullable|image|mimes:jpeg,png,jpg|max:4096',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $dataUpdate = $request->only(['name', 'description', 'address', 'latitude', 'longitude']);

        // Ganti gambar cover jika ada gambar baru
        if ($request->hasFile('image')) {
            if ($tempatMakan->image_url && Storage::disk('public')->exists($tempatMakan->image_url)) {
                Storage::disk('public')->delete($tempatMakan->image_url);
            }
            $dataUpdate['image_url'] = $request->file('image')->store('tempat_makan_cover', 'public');
        }

        $tempatMakan->update($dataUpdate);

        return response()->json([
            'status'  => 'success',
            'message' => 'Tempat makan berhasil diperbarui',
            'data'    => $tempatMakan->fresh()
        ], 200);
    }

    // --- 7. DELETE (Hapus Warung) ---
    public function destroy(Request $request, $id)
    {
        $tempatMakan = TempatMakan::find($id);

        if (!$tempatMakan) {
            return response()->json(['status' => 'error', 'message' => 'Data tidak ditemukan'], 404);
        }

        // Hanya PEMILIK ASLI atau ADMIN yang boleh menghapus
        if ($tempatMakan->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak untuk menghapus warung ini'], 403);
        }

        // Hapus gambar cover jika ada
        if ($tempatMakan->image_url && Storage::disk('public')->exists($tempatMakan->image_url)) {
            Storage::disk('public')->delete($tempatMakan->image_url);
        }

        $tempatMakan->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Tempat makan berhasil dihapus'
        ], 200);
    }
}