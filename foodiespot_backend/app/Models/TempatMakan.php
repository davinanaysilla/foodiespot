<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TempatMakan extends Model
{
    use HasFactory;

    protected $table = 'tempat_makan';

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'address',
        'latitude',
        'longitude',
        'image_url',
        'rating',
    ];

    /**
     * Cast decimal & float columns to PHP float so JSON never returns them as strings.
     * MySQL PDO returns DECIMAL columns as strings by default — this fixes that.
     */
    protected $casts = [
        'rating'    => 'float',
        'latitude'  => 'float',
        'longitude' => 'float',
    ];

    // Tambahkan maps_url ke setiap response JSON
    protected $appends = ['maps_url'];

    /**
     * Accessor: Override field image_url agar SELALU return full URL.
     * Flutter baca field `image_url` → langsung dapat URL gambar yang bisa ditampilkan.
     *
     * Contoh input (DB): "tempat_makan_cover/abc123.jpg"
     * Contoh output    : "http://10.0.2.2:8000/storage/tempat_makan_cover/abc123.jpg"
     */
    public function getImageUrlAttribute($value): ?string
    {
        if (!$value) return null;
        if (str_starts_with($value, 'http')) return $value;
        return asset('storage/' . $value);
    }

    /**
     * Accessor: URL Google Maps untuk navigasi langsung dari Flutter.
     * Flutter buka URL ini pakai url_launcher → otomatis buka Google Maps dengan navigasi.
     * Contoh: https://www.google.com/maps/dir/?api=1&destination=-6.200,106.816
     */
    public function getMapsUrlAttribute(): ?string
    {
        if (!$this->latitude || !$this->longitude) return null;
        return "https://www.google.com/maps/dir/?api=1&destination={$this->latitude},{$this->longitude}";
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function photos()
    {
        return $this->hasMany(Photo::class);
    }

    public function owner()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
}