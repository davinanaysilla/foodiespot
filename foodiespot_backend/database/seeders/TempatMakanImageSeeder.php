<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\TempatMakan;

class TempatMakanImageSeeder extends Seeder
{
    /**
     * Tambahkan foto cover dummy ke restoran yang belum punya gambar.
     * Menggunakan URL gambar nyata dari Unsplash (makanan & restoran Indonesia).
     */
    public function run(): void
    {
        // Daftar URL foto makanan/restoran dari Unsplash (gratis & publik)
        $foodImages = [
            // Bebek / Ayam goreng
            'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=600&q=80',
            // Nasi & lauk pauk
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600&q=80',
            // Rawon / Sup daging
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
            // Soto ayam
            'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600&q=80',
            // Mie ayam / Mie goreng
            'https://images.unsplash.com/photo-1555126634-323283e090fa?w=600&q=80',
            // Sate
            'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600&q=80',
            // Ikan bakar / Seafood
            'https://images.unsplash.com/photo-1615361200141-f45040f367be?w=600&q=80',
            // Bakso
            'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600&q=80',
            // Kopi / Kedai
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&q=80',
            // Warung makan tradisional
            'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600&q=80',
            // Pecel / Gado-gado
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
            // Seafood pantai
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
            // Iga bakar
            'https://images.unsplash.com/photo-1544025162-d76538b2da21?w=600&q=80',
            // Nasi goreng
            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600&q=80',
            // Es teler / Minuman
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600&q=80',
            // Warung nasi
            'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=600&q=80',
            // Sop buntut
            'https://images.unsplash.com/photo-1547592180-85f173990554?w=600&q=80',
            // Bebek goreng
            'https://images.unsplash.com/photo-1598103442097-8b74394b95c3?w=600&q=80',
            // Restoran tepi pantai
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
            // Makanan tradisional Jawa
            'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=600&q=80',
        ];

        // Ambil semua restoran yang TIDAK punya image_url (hanya dummy tanpa foto)
        $withoutImage = TempatMakan::whereNull('image_url')->orWhere('image_url', '')->get();

        if ($withoutImage->isEmpty()) {
            $this->command->warn('⚠️  Semua restoran sudah punya foto, tidak ada yang diperbarui.');
            return;
        }

        $count = 0;
        foreach ($withoutImage as $index => $resto) {
            // Assign gambar secara berurutan (modulo agar tidak out of bounds)
            $imageUrl = $foodImages[$index % count($foodImages)];

            $resto->update(['image_url' => $imageUrl]);
            $count++;
            $this->command->line("   🍽️  {$resto->name} → foto ditambahkan");
        }

        $this->command->info("✅ {$count} restoran berhasil ditambahkan foto cover.");
    }
}
