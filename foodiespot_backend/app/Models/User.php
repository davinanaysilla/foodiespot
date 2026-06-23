<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'phone',    
        'photo_url',
        'is_suspended',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Accessor: Override field photo_url agar SELALU return full URL.
     * Ini memastikan Flutter selalu dapat URL yang bisa langsung ditampilkan,
     * baik dari `$user->photo_url` maupun saat eager loading `with('user:id,name,photo_url')`.
     *
     * Contoh input (DB): "profile_photos/abc123.jpg"
     * Contoh output    : "http://10.0.2.2:8000/storage/profile_photos/abc123.jpg"
     */
    public function getPhotoUrlAttribute($value): ?string
    {
        if (!$value) return null;
        // Jika sudah full URL (misal dari Google/Facebook login), kembalikan apa adanya
        if (str_starts_with($value, 'http')) return $value;
        return asset('storage/' . $value);
    }

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
            'is_suspended'      => 'boolean',
        ];
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function photos()
    {
        return $this->hasMany(Photo::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
}