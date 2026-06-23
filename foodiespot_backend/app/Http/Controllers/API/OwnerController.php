<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\TempatMakan;
use App\Models\Review;
use App\Models\Photo;
use App\Models\Favorite;

class OwnerController extends Controller
{
    /**
     * Dashboard statistik untuk Owner.
     * Menampilkan ringkasan seluruh warung milik owner yang sedang login.
     */
    public function dashboard(Request $request)
    {
        // Validasi hanya owner yang bisa akses
        if ($request->user()->role !== 'owner') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak. Anda bukan Owner.'], 403);
        }

        // Ambil semua id tempat makan milik owner ini
        $tempatMakanIds = TempatMakan::where('user_id', $request->user()->id)->pluck('id');

        // Hitung total tempat makan
        $totalTempatMakan = $tempatMakanIds->count();

        // Statistik Review
        $totalReview    = Review::whereIn('tempat_makan_id', $tempatMakanIds)->count();
        $averageRating  = Review::whereIn('tempat_makan_id', $tempatMakanIds)->avg('rating');

        // Distribusi rating (1–5 bintang)
        $ratingDistribution = [];
        for ($i = 1; $i <= 5; $i++) {
            $ratingDistribution[$i] = Review::whereIn('tempat_makan_id', $tempatMakanIds)
                                             ->where('rating', $i)
                                             ->count();
        }

        // Statistik Foto
        $totalFoto = Photo::whereIn('tempat_makan_id', $tempatMakanIds)->count();

        // Jumlah pengunjung (proxy: jumlah yang mem-favoritkan warung)
        $totalFavorit = Favorite::whereIn('tempat_makan_id', $tempatMakanIds)->count();

        // Review terbaru (5 review terakhir) dari semua warung milik owner ini
        $reviewTerbaru = Review::with('user:id,name,photo_url')
                               ->whereIn('tempat_makan_id', $tempatMakanIds)
                               ->latest()
                               ->take(5)
                               ->get();

        // Statistik per-warung (breakdown)
        $statsPerWarung = TempatMakan::whereIn('id', $tempatMakanIds)
                                     ->withCount(['reviews', 'photos', 'favorites'])
                                     ->get()
                                     ->map(function ($warung) {
                                         return [
                                             'id'             => $warung->id,
                                             'name'           => $warung->name,
                                             'rating'         => $warung->rating,
                                             'total_review'   => $warung->reviews_count,
                                             'total_foto'     => $warung->photos_count,
                                             'total_favorit'  => $warung->favorites_count,
                                         ];
                                     });

        return response()->json([
            'status' => 'success',
            'data'   => [
                'summary' => [
                    'total_tempat_makan' => $totalTempatMakan,
                    'total_review'       => $totalReview,
                    'average_rating'     => round($averageRating ?? 0, 2),
                    'total_foto'         => $totalFoto,
                    'total_favorit'      => $totalFavorit, // Proxy "pengunjung"
                ],
                'rating_distribution' => $ratingDistribution,
                'review_terbaru'      => $reviewTerbaru,
                'per_warung'          => $statsPerWarung,
            ]
        ], 200);
    }
}
