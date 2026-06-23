<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Photo;
use App\Models\PhotoReport;
use App\Models\TempatMakan;
use Illuminate\Support\Facades\Validator;

class PhotoReportController extends Controller
{
    /**
     * OWNER: Laporkan foto tidak pantas.
     * Hanya owner dari tempat makan terkait yang boleh melaporkan.
     */
    public function store(Request $request, $photoId)
    {
        $photo = Photo::find($photoId);

        if (!$photo) {
            return response()->json(['status' => 'error', 'message' => 'Foto tidak ditemukan'], 404);
        }

        // Cek apakah user adalah owner dari tempat makan foto tersebut
        $tempatMakan = TempatMakan::find($photo->tempat_makan_id);
        $isOwnerOfPlace = $tempatMakan && $tempatMakan->user_id === $request->user()->id;

        // Owner warung tersebut ATAU user manapun boleh melapor
        // (setidaknya harus sudah login / authenticated)
        $validator = Validator::make($request->all(), [
            'reason'      => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        // Cegah laporan duplikat dari user yang sama untuk foto yang sama
        $existingReport = PhotoReport::where('photo_id', $photoId)
                                     ->where('reported_by', $request->user()->id)
                                     ->where('status', 'pending')
                                     ->first();

        if ($existingReport) {
            return response()->json(['status' => 'error', 'message' => 'Anda sudah melaporkan foto ini sebelumnya.'], 400);
        }

        $report = PhotoReport::create([
            'photo_id'    => $photoId,
            'reported_by' => $request->user()->id,
            'reason'      => $request->reason,
            'description' => $request->description,
            'status'      => 'pending',
        ]);

        $report->load('reporter:id,name', 'photo');

        return response()->json([
            'status'  => 'success',
            'message' => 'Laporan foto berhasil dikirim. Admin akan meninjau laporan ini.',
            'data'    => $report
        ], 201);
    }

    /**
     * ADMIN: Lihat semua laporan foto (yang masih pending).
     */
    public function index(Request $request)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $status = $request->query('status', 'pending'); // Default tampilkan yang pending

        $reports = PhotoReport::with([
                        'reporter:id,name,email',
                        'photo.tempatMakan:id,name',
                        'photo.user:id,name',
                    ])
                    ->where('status', $status)
                    ->latest()
                    ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $reports
        ], 200);
    }

    /**
     * ADMIN: Tindaklanjuti laporan — resolve (hapus foto) atau dismiss (abaikan laporan).
     */
    public function resolve(Request $request, $id)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $report = PhotoReport::find($id);

        if (!$report) {
            return response()->json(['status' => 'error', 'message' => 'Laporan tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'action' => 'required|in:resolve,dismiss',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        if ($request->action === 'resolve') {
            // Hapus foto yang dilaporkan
            $photo = Photo::find($report->photo_id);
            if ($photo) {
                if (\Illuminate\Support\Facades\Storage::disk('public')->exists($photo->image_path)) {
                    \Illuminate\Support\Facades\Storage::disk('public')->delete($photo->image_path);
                }
                $photo->delete();
            }

            // Tandai semua laporan untuk foto ini sebagai resolved
            PhotoReport::where('photo_id', $report->photo_id)->update(['status' => 'resolved']);

            return response()->json([
                'status'  => 'success',
                'message' => 'Foto telah dihapus dan laporan ditandai sebagai resolved.'
            ], 200);
        }

        // Jika dismiss — abaikan laporan
        $report->update(['status' => 'dismissed']);

        return response()->json([
            'status'  => 'success',
            'message' => 'Laporan telah diabaikan (dismissed).'
        ], 200);
    }
}
