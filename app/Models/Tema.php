<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Tema extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = 'tema'; // Nama tabel di database

    // Definisi kolom tabel
    protected $fillable = [
        'id_tema',
        'nama_tema',
        'jenis'
        // ... Kolom lain di tabel
    ];

    // Relasi dengan model lain (jika ada)
    // ...
}
