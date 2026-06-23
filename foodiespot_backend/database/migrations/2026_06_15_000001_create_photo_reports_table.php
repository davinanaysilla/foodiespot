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
        Schema::create('photo_reports', function (Blueprint $table) {
            $table->id();

            // Foto yang dilaporkan
            $table->foreignId('photo_id')
                  ->constrained('photos')
                  ->onDelete('cascade');

            // User yang melaporkan (bisa owner atau siapapun)
            $table->foreignId('reported_by')
                  ->constrained('users')
                  ->onDelete('cascade');

            // Alasan laporan
            $table->string('reason'); // e.g. "Foto tidak pantas", "Spam", "Tidak relevan"
            $table->text('description')->nullable(); // Deskripsi tambahan dari pelapor

            // Status tindakan admin
            $table->enum('status', ['pending', 'resolved', 'dismissed'])->default('pending');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('photo_reports');
    }
};
