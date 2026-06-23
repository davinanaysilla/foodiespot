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
        Schema::create('pengajuan_owners', function (Blueprint $table) {
            $table->id();
            
            // Siapa yang mengajukan
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            
            // Informasi awal toko yang mau didaftarkan
            $table->string('nama_toko');
            $table->text('deskripsi_toko')->nullable();
            
            // Status persetujuan dari Admin
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pengajuan_owners');
    }
};
