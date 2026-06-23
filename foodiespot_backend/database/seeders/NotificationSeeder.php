<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Notification;

class NotificationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $users = User::all();

        foreach ($users as $user) {
            Notification::create([
                'user_id' => $user->id,
                'title' => 'Selamat datang di FoodieSpot!',
                'type' => 'system_info',
                'is_read' => true
            ]);

            Notification::create([
                'user_id' => $user->id,
                'title' => 'Review Anda disukai oleh 5 orang',
                'type' => 'like',
                'is_read' => false
            ]);

            Notification::create([
                'user_id' => $user->id,
                'title' => 'Pemilik restoran membalas ulasan Anda',
                'type' => 'review_reply',
                'is_read' => false
            ]);
        }
    }
}
