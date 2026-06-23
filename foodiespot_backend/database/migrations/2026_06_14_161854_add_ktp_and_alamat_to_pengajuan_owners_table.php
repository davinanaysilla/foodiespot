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
        Schema::table('pengajuan_owners', function (Blueprint $table) {
            // Menambahkan kolom KTP dan Alamat
            $table->string('ktp_path')->after('deskripsi_toko')->nullable();
            $table->text('alamat')->after('ktp_path')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('pengajuan_owners', function (Blueprint $table) {
            $table->dropColumn(['ktp_path', 'alamat']);
        });
    }
};
