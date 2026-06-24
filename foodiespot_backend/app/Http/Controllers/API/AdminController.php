<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PengajuanOwner;
use App\Models\User;
use App\Models\TempatMakan;
use App\Models\Review;
use App\Models\Photo;

class AdminController extends Controller
{
    // ======================================================
    // HELPER: Pastikan hanya Admin yang bisa akses
    // ======================================================
    private function isAdmin(Request $request)
    {
        return $request->user()->role === 'admin';
    }

    // ======================================================
    // MANAJEMEN PENGAJUAN OWNER
    // ======================================================

    // Lihat semua pengajuan (bisa filter by status)
    public function getPengajuan(Request $request)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $status = $request->query('status', 'pending'); // Default: pending
        $query = PengajuanOwner::with('user:id,name,email');

        if ($status !== 'all') {
            $query->where('status', $status);
        }

        $pengajuan = $query->latest()->get();

        return response()->json([
            'status' => 'success',
            'data'   => $pengajuan
        ], 200);
    }

    // Setujui pengajuan owner
    public function setujuiPengajuan(Request $request, $id)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak.'], 403);
        }

        $pengajuan = PengajuanOwner::find($id);

        if (!$pengajuan) {
            return response()->json(['status' => 'error', 'message' => 'Data pengajuan tidak ditemukan.'], 404);
        }

        $pengajuan->update(['status' => 'approved']);

        $user = User::find($pengajuan->user_id);
        if ($user) {
            $user->update(['role' => 'owner']);
        }

        return response()->json([
            'status'  => 'success',
            'message' => "Pengajuan toko '{$pengajuan->nama_toko}' berhasil disetujui. User sekarang adalah Owner!"
        ], 200);
    }

    // Tolak pengajuan owner
    public function tolakPengajuan(Request $request, $id)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak.'], 403);
        }

        $pengajuan = PengajuanOwner::find($id);

        if (!$pengajuan) {
            return response()->json(['status' => 'error', 'message' => 'Data pengajuan tidak ditemukan.'], 404);
        }

        $pengajuan->update(['status' => 'rejected']);

        return response()->json([
            'status'  => 'success',
            'message' => "Pengajuan toko '{$pengajuan->nama_toko}' telah ditolak."
        ], 200);
    }

    // Hapus pengajuan secara permanen
    public function hapusPengajuan(Request $request, $id)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak.'], 403);
        }

        $pengajuan = PengajuanOwner::find($id);

        if (!$pengajuan) {
            return response()->json(['status' => 'error', 'message' => 'Data pengajuan tidak ditemukan.'], 404);
        }

        // Hapus file KTP jika ada
        if ($pengajuan->ktp_path && \Illuminate\Support\Facades\Storage::disk('public')->exists($pengajuan->ktp_path)) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($pengajuan->ktp_path);
        }

        $pengajuan->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Pengajuan berhasil dihapus secara permanen.'
        ], 200);
    }

    // ======================================================
    // MANAJEMEN USER
    // ======================================================

    // Lihat semua user (bisa filter by role)
    public function getAllUsers(Request $request)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $query = User::where('id', '!=', $request->user()->id); // Exclude admin sendiri

        if ($request->has('role') && in_array($request->role, ['user', 'owner', 'admin'])) {
            $query->where('role', $request->role);
        }

        if ($request->has('search') && $request->search != '') {
            $keyword = $request->search;
            $query->where(function ($q) use ($keyword) {
                $q->where('name', 'like', '%' . $keyword . '%')
                  ->orWhere('email', 'like', '%' . $keyword . '%');
            });
        }

        $users = $query->latest()->get();

        return response()->json([
            'status' => 'success',
            'data'   => $users
        ], 200);
    }

    // Hapus user
    public function deleteUser(Request $request, $id)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $user = User::find($id);

        if (!$user) {
            return response()->json(['status' => 'error', 'message' => 'User tidak ditemukan'], 404);
        }

        // Tidak boleh menghapus diri sendiri
        if ($user->id === $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Tidak dapat menghapus akun Anda sendiri.'], 400);
        }

        // Hapus foto profil jika ada
        if ($user->photo_url && \Illuminate\Support\Facades\Storage::disk('public')->exists($user->photo_url)) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($user->photo_url);
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'status'  => 'success',
            'message' => "User '{$user->name}' berhasil dihapus."
        ], 200);
    }

    // Suspend / Unsuspend user (toggle)
    public function suspendUser(Request $request, $id)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $user = User::find($id);

        if (!$user) {
            return response()->json(['status' => 'error', 'message' => 'User tidak ditemukan'], 404);
        }

        // Tidak boleh mensuspend diri sendiri
        if ($user->id === $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Tidak dapat mensuspend akun Anda sendiri.'], 400);
        }

        // Toggle status suspend
        $newStatus = !$user->is_suspended;
        $user->update(['is_suspended' => $newStatus]);

        // Jika disuspend, cabut semua token aktif agar langsung logout
        if ($newStatus) {
            $user->tokens()->delete();
        }

        $action = $newStatus ? 'ditangguhkan' : 'diaktifkan kembali';

        return response()->json([
            'status'       => 'success',
            'message'      => "Akun '{$user->name}' berhasil {$action}.",
            'is_suspended' => $newStatus,
        ], 200);
    }

    // ======================================================
    // MODERASI REVIEW
    // ======================================================

    // Lihat semua review (dari semua tempat makan)
    public function getAllReviews(Request $request)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $reviews = Review::with([
                        'user:id,name,email',
                        'tempatMakan:id,name',
                    ])
                    ->latest()
                    ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data'   => $reviews
        ], 200);
    }

    // Hapus review bermasalah (oleh admin)
    public function deleteReview(Request $request, $id)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $review = Review::find($id);

        if (!$review) {
            return response()->json(['status' => 'error', 'message' => 'Review tidak ditemukan'], 404);
        }

        $tempatMakanId = $review->tempat_makan_id;

        // Hapus gambar review jika ada
        if ($review->image_path && \Illuminate\Support\Facades\Storage::disk('public')->exists($review->image_path)) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($review->image_path);
        }

        $review->delete();

        // Recalculate average rating
        $rataRata = Review::where('tempat_makan_id', $tempatMakanId)->avg('rating');
        \App\Models\TempatMakan::where('id', $tempatMakanId)->update([
            'rating' => round($rataRata ?? 0, 1)
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Review berhasil dihapus oleh Admin.'
        ], 200);
    }

    // ======================================================
    // MODERASI FOTO
    // ======================================================

    // Lihat semua foto (dari semua tempat makan)
    public function getAllPhotos(Request $request)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $photos = Photo::with([
                        'user:id,name,email',
                        'tempatMakan:id,name',
                    ])
                    ->latest()
                    ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data'   => $photos
        ], 200);
    }

    // Hapus foto tidak sesuai (oleh admin)
    public function deletePhoto(Request $request, $id)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        $photo = Photo::find($id);

        if (!$photo) {
            return response()->json(['status' => 'error', 'message' => 'Foto tidak ditemukan'], 404);
        }

        if (\Illuminate\Support\Facades\Storage::disk('public')->exists($photo->image_path)) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($photo->image_path);
        }

        $photo->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Foto berhasil dihapus oleh Admin.'
        ], 200);
    }

    // ======================================================
    // DASHBOARD SISTEM
    // ======================================================

    public function dashboard(Request $request)
    {
        if (!$this->isAdmin($request)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        // Statistik User
        $totalUser   = User::where('role', 'user')->count();
        $totalOwner  = User::where('role', 'owner')->count();
        $totalAdmin  = User::where('role', 'admin')->count();
        $totalSuspended = User::where('is_suspended', true)->count();

        // Statistik Tempat Makan
        $totalTempatMakan = TempatMakan::count();

        // Statistik Review
        $totalReview     = Review::count();
        $averageRating   = Review::avg('rating');

        // Statistik Foto
        $totalFoto = Photo::count();

        // Statistik Pengajuan Owner
        $totalPengajuanPending  = PengajuanOwner::where('status', 'pending')->count();
        $totalPengajuanApproved = PengajuanOwner::where('status', 'approved')->count();
        $totalPengajuanRejected = PengajuanOwner::where('status', 'rejected')->count();

        // Aktivitas Terbaru: 10 user terbaru bergabung
        $userTerbaru = User::where('role', 'user')
                           ->latest()
                           ->take(10)
                           ->get(['id', 'name', 'email', 'role', 'created_at']);

        // Aktivitas Terbaru: 10 review terbaru
        $reviewTerbaru = Review::with('user:id,name', 'tempatMakan:id,name')
                               ->latest()
                               ->take(10)
                               ->get();

        // Aktivitas Terbaru: 5 tempat makan terbaru
        $tempatMakanTerbaru = TempatMakan::with('owner:id,name')
                                         ->latest()
                                         ->take(5)
                                         ->get(['id', 'name', 'address', 'rating', 'user_id', 'created_at']);

        return response()->json([
            'status' => 'success',
            'data'   => [
                'statistik_user' => [
                    'total_user'      => $totalUser,
                    'total_owner'     => $totalOwner,
                    'total_admin'     => $totalAdmin,
                    'total_suspended' => $totalSuspended,
                    'total_semua'     => $totalUser + $totalOwner + $totalAdmin,
                ],
                'statistik_tempat_makan' => [
                    'total' => $totalTempatMakan,
                ],
                'statistik_review' => [
                    'total'          => $totalReview,
                    'average_rating' => round($averageRating ?? 0, 2),
                ],
                'statistik_foto' => [
                    'total' => $totalFoto,
                ],
                'statistik_pengajuan' => [
                    'pending'  => $totalPengajuanPending,
                    'approved' => $totalPengajuanApproved,
                    'rejected' => $totalPengajuanRejected,
                ],
                'aktivitas_terbaru' => [
                    'user_baru'         => $userTerbaru,
                    'review_terbaru'    => $reviewTerbaru,
                    'tempat_makan_baru' => $tempatMakanTerbaru,
                ],
            ]
        ], 200);
    }
}