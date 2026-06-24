<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\TempatMakanController;
use App\Http\Controllers\API\ReviewController;
use App\Http\Controllers\API\PhotoController;
use App\Http\Controllers\API\PhotoReportController;
use App\Http\Controllers\API\PengajuanOwnerController;
use App\Http\Controllers\API\AdminController;
use App\Http\Controllers\API\FavoriteController;
use App\Http\Controllers\API\OwnerController;
use App\Http\Controllers\API\NotificationController;

// ============================================================
// PUBLIC ROUTES (Tanpa Token)
// ============================================================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// ============================================================
// PRIVATE ROUTES (Wajib Bearer Token dari Login)
// ============================================================
Route::middleware('auth:sanctum')->group(function () {

    // ----------------------------------------------------------
    // AUTH & PROFIL
    // ----------------------------------------------------------
    Route::post('/logout',   [AuthController::class, 'logout']);
    Route::get('/profile',   [AuthController::class, 'profile']);
    // PENTING: Untuk upload foto profil, Flutter WAJIB pakai POST (bukan PUT/PATCH)
    // karena multipart/form-data file upload tidak support PUT di Laravel
    Route::post('/profile/update', [AuthController::class, 'updateProfile']); // Recommended untuk upload foto
    Route::post('/profile',        [AuthController::class, 'updateProfile']); // Fallback POST
    Route::put('/profile',         [AuthController::class, 'updateProfile']); // Untuk update teks saja (tanpa file)
    Route::patch('/profile',       [AuthController::class, 'updateProfile']); // Alternatif PUT
    Route::delete('/profile',      [AuthController::class, 'deleteAccount']);

    // ----------------------------------------------------------
    // NOTIFIKASI
    // ----------------------------------------------------------
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);

    // ----------------------------------------------------------
    // TEMPAT MAKAN
    // ----------------------------------------------------------
    // GPS / LBS: Cari tempat makan terdekat berdasarkan koordinat
    Route::get('/tempat-makan/nearby', [TempatMakanController::class, 'nearby']);

    // CRUD Tempat Makan (index, show, store, update, destroy)
    Route::apiResource('tempat-makan', TempatMakanController::class);

    // Owner: Lihat warung milik sendiri
    Route::get('/owner/tempat-makan', [TempatMakanController::class, 'myTempatMakan']);

    // ----------------------------------------------------------
    // REVIEW
    // ----------------------------------------------------------
    // User: Lihat & Tambah review di satu tempat makan
    Route::get('/tempat-makan/{id}/reviews',  [ReviewController::class, 'index']);
    Route::post('/tempat-makan/{id}/reviews', [ReviewController::class, 'store']);

    // User: Edit & Hapus review sendiri
    Route::put('/reviews/{id}',    [ReviewController::class, 'update']);
    Route::delete('/reviews/{id}', [ReviewController::class, 'destroy']);

    // Owner: Balas, Edit Balasan, Hapus Balasan review
    Route::post('/reviews/{id}/reply',   [ReviewController::class, 'reply']);
    Route::put('/reviews/{id}/reply',    [ReviewController::class, 'updateReply']);
    Route::delete('/reviews/{id}/reply', [ReviewController::class, 'deleteReply']);

    // ----------------------------------------------------------
    // FOTO
    // ----------------------------------------------------------
    // Lihat & Upload foto di satu tempat makan
    Route::get('/tempat-makan/{id}/photos',  [PhotoController::class, 'index']);
    Route::post('/tempat-makan/{id}/photos', [PhotoController::class, 'store']);

    // Hapus foto (oleh pemilik foto / owner warung / admin)
    Route::delete('/photos/{id}', [PhotoController::class, 'destroy']);

    // Laporkan foto tidak pantas (Owner atau User)
    Route::post('/photos/{id}/report', [PhotoReportController::class, 'store']);

    // ----------------------------------------------------------
    // FAVORIT
    // ----------------------------------------------------------
    Route::get('/favorites',                          [FavoriteController::class, 'index']);
    Route::get('/tempat-makan/{id}/favorite',         [FavoriteController::class, 'check']);
    Route::post('/tempat-makan/{id}/favorite',        [FavoriteController::class, 'store']);   // Simpan favorit (C)
    Route::delete('/tempat-makan/{id}/favorite',      [FavoriteController::class, 'destroy']); // Hapus favorit (D)
    Route::post('/tempat-makan/{id}/favorite/toggle', [FavoriteController::class, 'toggle']);  // Toggle (untuk tombol ❤️)

    // ----------------------------------------------------------
    // PENGAJUAN OWNER (oleh User biasa)
    // ----------------------------------------------------------
    Route::get('/pengajuan-owner',    [PengajuanOwnerController::class, 'cekStatus']);
    Route::post('/pengajuan-owner',   [PengajuanOwnerController::class, 'ajukan']);
    Route::delete('/pengajuan-owner', [PengajuanOwnerController::class, 'batalkan']);

    // ----------------------------------------------------------
    // OWNER DASHBOARD
    // ----------------------------------------------------------
    Route::get('/owner/dashboard', [OwnerController::class, 'dashboard']);

    // ----------------------------------------------------------
    // ADMIN – Manajemen Pengajuan Owner
    // ----------------------------------------------------------
    Route::get('/admin/pengajuan',                    [AdminController::class, 'getPengajuan']);
    Route::post('/admin/pengajuan/{id}/approve',      [AdminController::class, 'setujuiPengajuan']);
    Route::post('/admin/pengajuan/{id}/reject',       [AdminController::class, 'tolakPengajuan']);
    Route::delete('/admin/pengajuan/{id}',            [AdminController::class, 'hapusPengajuan']);

    // ADMIN – Manajemen User
    Route::get('/admin/users',              [AdminController::class, 'getAllUsers']);
    Route::post('/admin/users/{id}/suspend',[AdminController::class, 'suspendUser']);
    Route::delete('/admin/users/{id}',      [AdminController::class, 'deleteUser']);

    // ADMIN – Moderasi Review
    Route::get('/admin/reviews',           [AdminController::class, 'getAllReviews']);
    Route::delete('/admin/reviews/{id}',   [AdminController::class, 'deleteReview']); // Hapus review bermasalah (D)

    // ADMIN – Moderasi Foto
    Route::get('/admin/photos',         [AdminController::class, 'getAllPhotos']);
    Route::delete('/admin/photos/{id}', [AdminController::class, 'deletePhoto']);

    // ADMIN – Laporan Foto
    Route::get('/admin/photo-reports',              [PhotoReportController::class, 'index']);
    Route::post('/admin/photo-reports/{id}/action', [PhotoReportController::class, 'resolve']);

    // ADMIN – Dashboard Sistem
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard']);
});