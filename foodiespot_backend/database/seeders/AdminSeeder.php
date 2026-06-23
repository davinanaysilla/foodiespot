<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Buat akun Admin default untuk testing.
     */
    public function run(): void
    {
        // Cek dulu apakah admin sudah ada, hindari duplikat
        if (!User::where('email', 'admin@foodiespot.com')->exists()) {
            User::create([
                'name'     => 'Admin FoodieSpot',
                'email'    => 'admin@foodiespot.com',
                'password' => Hash::make('admin123'),
                'role'     => 'admin',
            ]);

            $this->command->info('✅ Akun Admin berhasil dibuat: admin@foodiespot.com / admin123');
        } else {
            $this->command->warn('⚠️  Akun Admin sudah ada, dilewati.');
        }
    }
}
