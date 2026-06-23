<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PengajuanOwner extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'nama_toko',
        'deskripsi_toko',
        'ktp_path', // 
        'alamat',  
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}