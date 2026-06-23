<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Review;
use App\Models\TempatMakan;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class ReviewController extends Controller
{
    // --- 1. LIHAT SEMUA REVIEW DI SATU TEMPAT MAKAN ---
    public function index($tempatMakanId)
    {
        $reviews = Review::with('user:id,name,photo_url')
                    ->where('tempat_makan_id', $tempatMakanId)
                    ->latest()
                    ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $reviews
        ], 200);
    }

    // --- 2. TAMBAH REVIEW (User biasa) ---
    public function store(Request $request, $tempatMakanId)
    {
        if ($request->user()->role !== 'user') {
            return response()->json(['status' => 'error', 'message' => 'Hanya pelanggan yang dapat memberikan review'], 403);
        }

        $validator = Validator::make($request->all(), [
            'rating'  => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
            'image'   => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $existingReview = Review::where('user_id', $request->user()->id)
                                ->where('tempat_makan_id', $tempatMakanId)
                                ->first();

        if ($existingReview) {
            return response()->json(['status' => 'error', 'message' => 'Anda sudah memberikan review untuk tempat ini'], 400);
        }

        $imagePath = null;

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('tempat_makan_photos', 'public');

            // Otomatis buat data di tabel Photos agar galeri foto tetap berfungsi
            \App\Models\Photo::create([
                'user_id'        => $request->user()->id,
                'tempat_makan_id' => $tempatMakanId,
                'image_path'     => $imagePath,
            ]);
        }

        $review = Review::create([
            'user_id'         => $request->user()->id,
            'tempat_makan_id' => $tempatMakanId,
            'rating'          => $request->rating,
            'comment'         => $request->comment,
            'image_path'      => $imagePath,
        ]);

        $this->updateAverageRating($tempatMakanId);
        $review->load('user:id,name,photo_url');

        return response()->json([
            'status'  => 'success',
            'message' => 'Review berhasil ditambahkan',
            'data'    => $review
        ], 201);
    }

    // --- 3. EDIT REVIEW SENDIRI (User) ---
    public function update(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json(['status' => 'error', 'message' => 'Review tidak ditemukan'], 404);
        }

        // Hanya pemilik review yang boleh edit
        if ($review->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Anda tidak berhak mengedit review ini'], 403);
        }

        $validator = Validator::make($request->all(), [
            'rating'  => 'sometimes|required|integer|min:1|max:5',
            'comment' => 'sometimes|nullable|string',
            'image'   => 'sometimes|nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $dataUpdate = [];

        if ($request->has('rating')) {
            $dataUpdate['rating'] = $request->rating;
        }

        if ($request->has('comment')) {
            $dataUpdate['comment'] = $request->comment;
        }

        // Ganti foto review jika ada foto baru
        if ($request->hasFile('image')) {
            // Hapus foto lama jika ada
            if ($review->image_path && Storage::disk('public')->exists($review->image_path)) {
                Storage::disk('public')->delete($review->image_path);
            }
            $dataUpdate['image_path'] = $request->file('image')->store('tempat_makan_photos', 'public');
        }

        $review->update($dataUpdate);

        if (isset($dataUpdate['rating'])) {
            $this->updateAverageRating($review->tempat_makan_id);
        }

        $review->load('user:id,name,photo_url');

        return response()->json([
            'status'  => 'success',
            'message' => 'Review berhasil diperbarui',
            'data'    => $review
        ], 200);
    }

    // --- 4. HAPUS REVIEW (User sendiri atau Admin) ---
    public function destroy(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json(['status' => 'error', 'message' => 'Review tidak ditemukan'], 404);
        }

        if ($review->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $tempatMakanId = $review->tempat_makan_id;

        // Hapus file gambar review jika ada
        if ($review->image_path && Storage::disk('public')->exists($review->image_path)) {
            Storage::disk('public')->delete($review->image_path);
        }

        $review->delete();
        $this->updateAverageRating($tempatMakanId);

        return response()->json(['status' => 'success', 'message' => 'Review berhasil dihapus'], 200);
    }

    // --- 5. BALAS REVIEW (Owner) ---
    public function reply(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json(['status' => 'error', 'message' => 'Review tidak ditemukan'], 404);
        }

        $tempatMakan = \App\Models\TempatMakan::find($review->tempat_makan_id);

        if ($tempatMakan->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Hanya pemilik warung yang berhak membalas ulasan ini.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'reply' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $review->update(['reply' => $request->reply]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Berhasil membalas ulasan pelanggan',
            'data'    => $review
        ], 200);
    }

    // --- 6. EDIT BALASAN REVIEW (Owner) ---
    public function updateReply(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json(['status' => 'error', 'message' => 'Review tidak ditemukan'], 404);
        }

        if (!$review->reply) {
            return response()->json(['status' => 'error', 'message' => 'Belum ada balasan untuk diedit'], 400);
        }

        $tempatMakan = \App\Models\TempatMakan::find($review->tempat_makan_id);

        if ($tempatMakan->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Hanya pemilik warung yang berhak mengedit balasan ini.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'reply' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $review->update(['reply' => $request->reply]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Balasan berhasil diperbarui',
            'data'    => $review
        ], 200);
    }

    // --- 7. HAPUS BALASAN REVIEW (Owner) ---
    public function deleteReply(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json(['status' => 'error', 'message' => 'Review tidak ditemukan'], 404);
        }

        $tempatMakan = \App\Models\TempatMakan::find($review->tempat_makan_id);

        if ($tempatMakan->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $review->update(['reply' => null]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Balasan berhasil dihapus'
        ], 200);
    }

    // --- Helper: Kalkulasi Rata-rata Rating ---
    private function updateAverageRating($tempatMakanId)
    {
        $rataRata = Review::where('tempat_makan_id', $tempatMakanId)->avg('rating');

        TempatMakan::where('id', $tempatMakanId)->update([
            'rating' => round($rataRata ?? 0, 1)
        ]);
    }
}