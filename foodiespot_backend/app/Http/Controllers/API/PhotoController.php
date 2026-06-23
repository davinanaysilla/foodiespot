<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Photo;
use App\Models\TempatMakan;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class PhotoController extends Controller
{
    // --- 1. LIHAT SEMUA FOTO DI SATU TEMPAT MAKAN ---
    public function index($tempatMakanId)
    {
        $photos = Photo::with('user:id,name')->where('tempat_makan_id', $tempatMakanId)->latest()->get();

        return response()->json([
            'status' => 'success',
            'data' => $photos
        ], 200);
    }

    // --- 2. UPLOAD FOTO BARU ---
    public function store(Request $request, $tempatMakanId)
    {
        // Validasi file (Wajib gambar, maksimal ukuran 2MB)
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        // Cek tempat makannya ada atau tidak
        if (!TempatMakan::find($tempatMakanId)) {
            return response()->json(['status' => 'error', 'message' => 'Tempat makan tidak ditemukan'], 404);
        }

        // Simpan file ke folder: storage/app/public/tempat_makan_photos
        $path = $request->file('image')->store('tempat_makan_photos', 'public');

        $photo = Photo::create([
            'user_id' => $request->user()->id,
            'tempat_makan_id' => $tempatMakanId,
            'image_path' => $path,
        ]);

        $photo->load('user:id,name');

        return response()->json([
            'status' => 'success',
            'message' => 'Foto berhasil diunggah',
            'data' => $photo
        ], 201);
    }

    // --- 3. HAPUS FOTO ---
    public function destroy(Request $request, $id)
    {
        $photo = Photo::find($id);

        if (!$photo) {
            return response()->json(['status' => 'error', 'message' => 'Foto tidak ditemukan'], 404);
        }

        // Hanya yang upload foto ATAU Admin ATAU Owner warung tersebut yang boleh menghapus
        $isOwner = TempatMakan::find($photo->tempat_makan_id)->user_id === $request->user()->id;
        
        if ($photo->user_id !== $request->user()->id && $request->user()->role !== 'admin' && !$isOwner) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak menghapus foto ini'], 403);
        }

        // Hapus file fisik dari hardisk laptop/server
        if (Storage::disk('public')->exists($photo->image_path)) {
            Storage::disk('public')->delete($photo->image_path);
        }

        $photo->delete();

        return response()->json(['status' => 'success', 'message' => 'Foto berhasil dihapus'], 200);
    }
}