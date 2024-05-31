<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class TemaDestinasi extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = 'tema_destinasi'; // Nama tabel di database

    // Definisi kolom tabel
    protected $fillable = [
        'id_temadestinasi',
        'id_destinasi',
        'id_tema'
        // ... Kolom lain di tabel
    ];

    // Relasi dengan model lain (jika ada)
    // ...
}
