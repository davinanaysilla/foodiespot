<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PengajuanOwner;
use Illuminate\Support\Facades\Validator;

class PengajuanOwnerController extends Controller
{
    // --- CEK STATUS PENGAJUAN (READ) ---
    public function cekStatus(Request $request)
    {
        // Cari apakah user ini punya pengajuan
        $pengajuan = PengajuanOwner::where('user_id', $request->user()->id)->latest()->first();

        if (!$pengajuan) {
            return response()->json(['status' => 'success', 'message' => 'Belum ada pengajuan', 'data' => null], 200);
        }

        return response()->json(['status' => 'success', 'data' => $pengajuan], 200);
    }

    // --- AJUKAN JADI OWNER (CREATE) ---
    public function ajukan(Request $request)
    {
        if ($request->user()->role !== 'user') {
            return response()->json(['status' => 'error', 'message' => 'Anda sudah menjadi mitra/admin.'], 400);
        }

        // Validasi sekarang mewajibkan alamat dan foto KTP
        $validator = Validator::make($request->all(), [
            'nama_toko' => 'required|string|max:255',
            'deskripsi_toko' => 'required|string',
            'alamat' => 'required|string',
            'ktp_image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $pengajuanAktif = PengajuanOwner::where('user_id', $request->user()->id)->where('status', 'pending')->first();
        if ($pengajuanAktif) {
            return response()->json(['status' => 'error', 'message' => 'Anda masih memiliki pengajuan yang sedang diproses.'], 400);
        }

        // Simpan foto KTP ke dalam folder khusus
        $ktpPath = $request->file('ktp_image')->store('ktp_pengajuan', 'public');

        $pengajuan = PengajuanOwner::create([
            'user_id' => $request->user()->id,
            'nama_toko' => $request->nama_toko,
            'deskripsi_toko' => $request->deskripsi_toko,
            'alamat' => $request->alamat,
            'ktp_path' => $ktpPath,
            'status' => 'pending',
        ]);

        return response()->json(['status' => 'success', 'message' => 'Pengajuan berhasil dikirim.', 'data' => $pengajuan], 201);
    }

    // --- BATALKAN PENGAJUAN (DELETE) ---
    public function batalkan(Request $request)
    {
        $pengajuan = PengajuanOwner::where('user_id', $request->user()->id)->where('status', 'pending')->first();

        if (!$pengajuan) {
            return response()->json(['status' => 'error', 'message' => 'Tidak ada pengajuan yang bisa dibatalkan.'], 404);
        }

        $pengajuan->delete();

        return response()->json(['status' => 'success', 'message' => 'Pengajuan berhasil dibatalkan.'], 200);
    }
}