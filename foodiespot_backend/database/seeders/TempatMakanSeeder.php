<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\TempatMakan;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class TempatMakanSeeder extends Seeder
{
    /**
     * Seed data dummy owner + restoran di area Jember, Jawa Timur.
     * Setiap restoran dimiliki oleh akun owner yang berbeda-beda.
     */
    public function run(): void
    {
        // ── STEP 1: Buat akun-akun Owner dummy ─────────────────────────────
        $owners = [
            [
                'name'     => 'Pak Bambang Santoso',
                'email'    => 'bambang.owner@foodiespot.com',
                'password' => Hash::make('owner123'),
                'role'     => 'owner',
            ],
            [
                'name'     => 'Bu Siti Rahayu',
                'email'    => 'siti.owner@foodiespot.com',
                'password' => Hash::make('owner123'),
                'role'     => 'owner',
            ],
            [
                'name'     => 'Mas Hendra Kurniawan',
                'email'    => 'hendra.owner@foodiespot.com',
                'password' => Hash::make('owner123'),
                'role'     => 'owner',
            ],
            [
                'name'     => 'Bu Wulan Pertiwi',
                'email'    => 'wulan.owner@foodiespot.com',
                'password' => Hash::make('owner123'),
                'role'     => 'owner',
            ],
            [
                'name'     => 'Pak Soleh Wahyudi',
                'email'    => 'soleh.owner@foodiespot.com',
                'password' => Hash::make('owner123'),
                'role'     => 'owner',
            ],
            [
                'name'     => 'Bu Yuli Astuti',
                'email'    => 'yuli.owner@foodiespot.com',
                'password' => Hash::make('owner123'),
                'role'     => 'owner',
            ],
            [
                'name'     => 'Pak Ahmad Fauzi',
                'email'    => 'ahmad.owner@foodiespot.com',
                'password' => Hash::make('owner123'),
                'role'     => 'owner',
            ],
        ];

        $ownerModels = [];
        foreach ($owners as $ownerData) {
            $owner = User::firstOrCreate(
                ['email' => $ownerData['email']],
                $ownerData
            );
            $ownerModels[] = $owner;
        }

        $this->command->info('✅ ' . count($ownerModels) . ' akun owner berhasil dibuat/ditemukan.');

        // ── STEP 2: Data Restoran (masing-masing terhubung ke owner) ────────
        // Format: [...data restoran..., 'owner_index' => 0] (index ke $ownerModels)
        $tempatMakan = [
            // ── PUSAT KOTA JEMBER (Kaliwates) — Owner: Pak Bambang ──────────
            [
                'owner_index' => 0,
                'name'        => 'Nasi Bebek Sinjay Jember',
                'description' => 'Bebek goreng crispy khas Jember dengan sambal mangga muda yang legendaris. Bumbu rempah meresap sampai ke tulang, wajib coba!',
                'address'     => 'Jl. Gajah Mada No. 12, Kaliwates, Jember',
                'latitude'    => -8.1678,
                'longitude'   => 113.7014,
                'rating'      => 4.8,
            ],
            [
                'owner_index' => 0,
                'name'        => 'Rawon Nguling Pak Bambang',
                'description' => 'Rawon daging sapi segar dengan kuah kluwek hitam pekat kaya rempah. Disajikan dengan nasi hangat, kerupuk udang, dan sambal terasi.',
                'address'     => 'Jl. PB. Sudirman No. 88, Kaliwates, Jember',
                'latitude'    => -8.1722,
                'longitude'   => 113.7025,
                'rating'      => 4.7,
            ],
            [
                'owner_index' => 0,
                'name'        => 'Kedai Kopi Petani Jember',
                'description' => 'Kedai kopi dengan biji Arabika & Robusta premium hasil perkebunan Jember. Tersedia aneka kue tradisional dan sarapan pagi spesial.',
                'address'     => 'Jl. Ahmad Yani No. 5, Kaliwates, Jember',
                'latitude'    => -8.1701,
                'longitude'   => 113.7042,
                'rating'      => 4.7,
            ],

            // ── SUMBERSARI (Kawasan Kampus UNEJ) — Owner: Bu Siti ──────────
            [
                'owner_index' => 1,
                'name'        => 'Warung Pecel Bu Siti Sumbersari',
                'description' => 'Pecel pincuk dengan bumbu kacang uleg segar, lengkap dengan rempeyek udang dan tempe bacem. Langganan mahasiswa UNEJ sejak 2005.',
                'address'     => 'Jl. Kalimantan No. 37, Sumbersari, Jember (dekat UNEJ)',
                'latitude'    => -8.1594,
                'longitude'   => 113.7220,
                'rating'      => 4.6,
            ],
            [
                'owner_index' => 1,
                'name'        => 'Bakso Mercon Sumbersari Bu Siti',
                'description' => 'Bakso daging sapi dengan level kepedasan yang bisa disesuaikan (tidak pedas s/d level 5). Kuah kaldu segar, isian bakso jumbo.',
                'address'     => 'Jl. Sumatra No. 12, Sumbersari, Jember',
                'latitude'    => -8.1622,
                'longitude'   => 113.7188,
                'rating'      => 4.4,
            ],
            [
                'owner_index' => 1,
                'name'        => 'Es Teler & Jus Segar Jember',
                'description' => 'Minuman segar es teler dengan campuran alpukat, nangka, kelapa muda, dan susu kental manis. Plus aneka jus buah segar.',
                'address'     => 'Jl. Jawa No. 55, Sumbersari, Jember',
                'latitude'    => -8.1643,
                'longitude'   => 113.7245,
                'rating'      => 4.5,
            ],

            // ── PATRANG — Owner: Mas Hendra ─────────────────────────────────
            [
                'owner_index' => 2,
                'name'        => 'Iga Bakar Mas Hendra Patrang',
                'description' => 'Iga sapi bakar & goreng dengan bumbu rempah nusantara lengkap. Dagingnya empuk dan juicy, cocok untuk makan malam keluarga.',
                'address'     => 'Jl. Kalimantan No. 7, Patrang, Jember',
                'latitude'    => -8.1544,
                'longitude'   => 113.6921,
                'rating'      => 4.6,
            ],
            [
                'owner_index' => 2,
                'name'        => 'Mie Ayam & Bakso Mas Hendra',
                'description' => 'Mie ayam dengan topping jamur, ayam cincang berbumbu, dan pangsit goreng renyah. Porsi jumbo dengan harga yang bersahabat.',
                'address'     => 'Jl. Mastrip No. 34, Patrang, Jember',
                'latitude'    => -8.1561,
                'longitude'   => 113.6958,
                'rating'      => 4.3,
            ],
            [
                'owner_index' => 2,
                'name'        => 'Nasi Krawu Jember Mas Hendra',
                'description' => 'Nasi krawu dengan daging sapi suwir bumbu kuning khas, serundeng kelapa gurih, dan sambal petis yang nagih. Resep turun-temurun.',
                'address'     => 'Jl. Sultan Agung No. 15, Patrang, Jember',
                'latitude'    => -8.1580,
                'longitude'   => 113.6982,
                'rating'      => 4.4,
            ],

            // ── PAKUSARI — Owner: Bu Wulan ──────────────────────────────────
            [
                'owner_index' => 3,
                'name'        => 'Ayam Gepuk Bu Wulan Pakusari',
                'description' => 'Ayam gepuk dengan bumbu bacem manis-gurih, digoreng hingga crispy sempurna. Paket ayam + nasi + es teh dengan harga hemat.',
                'address'     => 'Jl. Raya Pakusari No. 88, Pakusari, Jember',
                'latitude'    => -8.2021,
                'longitude'   => 113.7388,
                'rating'      => 4.5,
            ],
            [
                'owner_index' => 3,
                'name'        => 'Depot Soto Ayam Bu Wulan',
                'description' => 'Soto ayam kampung dengan kuah bening rempah yang gurih dan segar. Tersedia lauk pilihan: tempe goreng, perkedel, dan sate usus.',
                'address'     => 'Jl. Pakusari Raya No. 10, Pakusari, Jember',
                'latitude'    => -8.2038,
                'longitude'   => 113.7401,
                'rating'      => 4.5,
            ],

            // ── AJUNG + BALUNG — Owner: Pak Soleh ──────────────────────────
            [
                'owner_index' => 4,
                'name'        => 'Warung Sate Kambing Pak Soleh',
                'description' => 'Sate kambing muda yang empuk dibakar di atas arang batok kelapa. Disajikan dengan bumbu kecap bawang iris dan lontong hangat.',
                'address'     => 'Jl. Pakusari Raya No. 22, Pakusari, Jember',
                'latitude'    => -8.2045,
                'longitude'   => 113.7412,
                'rating'      => 4.7,
            ],
            [
                'owner_index' => 4,
                'name'        => 'Seafood Bakar Pak Soleh Ajung',
                'description' => 'Hidangan seafood segar: ikan bakar, cumi goreng tepung, udang saus tiram. Harga terjangkau, bahan langsung dari nelayan lokal.',
                'address'     => 'Jl. Raya Ajung No. 100, Ajung, Jember',
                'latitude'    => -8.2198,
                'longitude'   => 113.7512,
                'rating'      => 4.6,
            ],
            [
                'owner_index' => 4,
                'name'        => 'Sop Buntut Balung Pak Soleh',
                'description' => 'Sop buntut sapi dengan kuah bening rempah yang kaya kolagen alami. Dagingnya empuk hingga ke tulang, tersedia juga sop iga sapi.',
                'address'     => 'Jl. Raya Balung No. 45, Balung, Jember',
                'latitude'    => -8.2842,
                'longitude'   => 113.6998,
                'rating'      => 4.6,
            ],

            // ── AMBULU — Owner: Bu Yuli ──────────────────────────────────────
            [
                'owner_index' => 5,
                'name'        => 'Warung Ikan Bakar Bu Yuli Ambulu',
                'description' => 'Ikan laut segar hasil tangkapan langsung dibakar dengan bumbu kuning dan sambal bawang. Suasana alam terbuka, dekat pantai Ambulu.',
                'address'     => 'Jl. Raya Ambulu No. 67, Ambulu, Jember',
                'latitude'    => -8.3445,
                'longitude'   => 113.6124,
                'rating'      => 4.8,
            ],
            [
                'owner_index' => 5,
                'name'        => 'Bebek Goreng Songkem Bu Yuli',
                'description' => 'Bebek goreng khas Madura, dikukus dahulu lalu digoreng hingga kulitnya crispy. Dagingnya lembut dengan bumbu rempah yang meresap.',
                'address'     => 'Jl. Diponegoro No. 3, Ambulu, Jember',
                'latitude'    => -8.3421,
                'longitude'   => 113.6098,
                'rating'      => 4.5,
            ],
            [
                'owner_index' => 5,
                'name'        => 'Gado-Gado & Pecel Bu Yuli',
                'description' => 'Gado-gado Jawa lengkap: sayuran rebus, lontong, telur, dan siraman bumbu kacang legit buatan sendiri. Juga tersedia nasi pecel pincuk.',
                'address'     => 'Jl. Merdeka No. 12, Balung, Jember',
                'latitude'    => -8.2867,
                'longitude'   => 113.7010,
                'rating'      => 4.2,
            ],

            // ── PUGER (Pesisir) — Owner: Pak Ahmad ──────────────────────────
            [
                'owner_index' => 6,
                'name'        => 'Seafood & Lobster Pantai Puger',
                'description' => 'Restoran seafood tepi pantai Puger. Ikan segar, lobster, dan cumi langsung dari nelayan dengan pemandangan laut yang memukau.',
                'address'     => 'Jl. Pantai Puger No. 1, Puger, Jember',
                'latitude'    => -8.3788,
                'longitude'   => 113.4782,
                'rating'      => 4.9,
            ],
            [
                'owner_index' => 6,
                'name'        => 'Warung Nasi Pecel Lamongan Pak Ahmad',
                'description' => 'Nasi pecel Lamongan dengan ikan lele goreng crispy, tempe bacem, dan bumbu kacang pilihan. Tersedia juga soto Lamongan dengan kuah kuning.',
                'address'     => 'Jl. Nusa Indah No. 8, Kaliwates, Jember',
                'latitude'    => -8.1688,
                'longitude'   => 113.7055,
                'rating'      => 4.3,
            ],
        ];

        // ── STEP 3: Simpan restoran ke database ─────────────────────────────
        $count = 0;
        foreach ($tempatMakan as $data) {
            $ownerIndex = $data['owner_index'];
            $owner      = $ownerModels[$ownerIndex];

            $exists = TempatMakan::where('name', $data['name'])->exists();
            if (!$exists) {
                TempatMakan::create([
                    'user_id'     => $owner->id,
                    'name'        => $data['name'],
                    'description' => $data['description'],
                    'address'     => $data['address'],
                    'latitude'    => $data['latitude'],
                    'longitude'   => $data['longitude'],
                    'rating'      => $data['rating'],
                ]);
                $count++;
            }
        }

        $this->command->info("✅ Berhasil menambahkan {$count} restoran dummy di area Jember.");
        $this->command->line('');
        $this->command->line('📋 Akun Owner yang tersedia (password: owner123):');
        foreach ($ownerModels as $owner) {
            $this->command->line("   - {$owner->name} → {$owner->email}");
        }
    }
}
