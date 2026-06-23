<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('tempat_makan', function (Blueprint $table) {
            // Menambahkan kolom image_path untuk foto sampul utama warung
            $table->string('image_path')->nullable()->after('address');
        });
    }

    public function down(): void
    {
        Schema::table('tempat_makan', function (Blueprint $table) {
            $table->dropColumn('image_path');
        });
    }
};
