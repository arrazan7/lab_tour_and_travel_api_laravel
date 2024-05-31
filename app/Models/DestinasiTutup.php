<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class DestinasiTutup extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = 'destinasi_tutup'; // Nama tabel di database

    // Definisi kolom tabel
    protected $fillable = [
        'id_destinasitutup',
        'id_destinasi',
        'hari_tutup'
        // ... Kolom lain di tabel
    ];

    // Relasi dengan model lain (jika ada)
    // ...
}
