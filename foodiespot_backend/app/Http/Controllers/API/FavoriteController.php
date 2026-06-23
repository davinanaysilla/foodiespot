<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Favorite;
use App\Models\TempatMakan;

class FavoriteController extends Controller
{
    // --- 1. AMBIL SEMUA FAVORIT USER ---
    public function index(Request $request)
    {
        // Langsung ambil data TempatMakan (beserta koordinat untuk Maps) yang disukai user ini
        $favorites = TempatMakan::whereHas('favorites', function ($query) use ($request) {
            $query->where('user_id', $request->user()->id);
        })->latest()->get();

        return response()->json([
            'status' => 'success',
            'data'   => $favorites
        ], 200);
    }

    // --- 2. CEK APAKAH WARUNG INI SUDAH DI-FAVORITKAN? ---
    public function check(Request $request, $tempatMakanId)
    {
        $isFavorite = Favorite::where('user_id', $request->user()->id)
                              ->where('tempat_makan_id', $tempatMakanId)
                              ->exists();

        return response()->json([
            'status'      => 'success',
            'is_favorite' => $isFavorite
        ], 200);
    }

    // --- 3. SIMPAN FAVORIT (Tambah) ---
    public function store(Request $request, $tempatMakanId)
    {
        if (!TempatMakan::find($tempatMakanId)) {
            return response()->json(['status' => 'error', 'message' => 'Tempat makan tidak ditemukan'], 404);
        }

        $existing = Favorite::where('user_id', $request->user()->id)
                            ->where('tempat_makan_id', $tempatMakanId)
                            ->first();

        if ($existing) {
            return response()->json(['status' => 'error', 'message' => 'Sudah ada di favorit'], 400);
        }

        Favorite::create([
            'user_id'         => $request->user()->id,
            'tempat_makan_id' => $tempatMakanId,
        ]);

        return response()->json([
            'status'      => 'success',
            'message'     => 'Berhasil ditambahkan ke favorit',
            'is_favorite' => true
        ], 201);
    }

    // --- 4. HAPUS FAVORIT (Eksplisit DELETE) ---
    public function destroy(Request $request, $tempatMakanId)
    {
        $favorite = Favorite::where('user_id', $request->user()->id)
                            ->where('tempat_makan_id', $tempatMakanId)
                            ->first();

        if (!$favorite) {
            return response()->json(['status' => 'error', 'message' => 'Favorit tidak ditemukan'], 404);
        }

        $favorite->delete();

        return response()->json([
            'status'      => 'success',
            'message'     => 'Berhasil dihapus dari favorit',
            'is_favorite' => false
        ], 200);
    }

    // --- 5. TOGGLE (Tambah / Hapus sekaligus — untuk tombol ❤️ di Flutter) ---
    public function toggle(Request $request, $tempatMakanId)
    {
        $favorite = Favorite::where('user_id', $request->user()->id)
                            ->where('tempat_makan_id', $tempatMakanId)
                            ->first();

        if ($favorite) {
            $favorite->delete();
            return response()->json([
                'status'      => 'success',
                'message'     => 'Dihapus dari favorit',
                'is_favorite' => false
            ], 200);
        }

        Favorite::create([
            'user_id'         => $request->user()->id,
            'tempat_makan_id' => $tempatMakanId,
        ]);

        return response()->json([
            'status'      => 'success',
            'message'     => 'Ditambahkan ke favorit',
            'is_favorite' => true
        ], 201);
    }
}