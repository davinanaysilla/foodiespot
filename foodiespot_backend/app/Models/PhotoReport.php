<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PhotoReport extends Model
{
    use HasFactory;

    protected $fillable = [
        'photo_id',
        'reported_by',
        'reason',
        'description',
        'status',
    ];

    public function photo()
    {
        return $this->belongsTo(Photo::class);
    }

    public function reporter()
    {
        return $this->belongsTo(User::class, 'reported_by');
    }
}
