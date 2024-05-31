<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Destinasi extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = 'destinasi'; // Nama tabel di database

    // Definisi kolom tabel
    protected $fillable = [
        'id_destinasi',
        'nama_destinasi',
        'jenis',
        'kota',
        'jam_buka',
        'jam_tutup',
        'jam_lokasi',
        'harga_wni',
        'harga_wna',
        'foto',
        'koordinat',
        'deskripsi',
        'rating'
        // ... Kolom lain di tabel
    ];

    // Relasi dengan model lain (jika ada)
    // ...
}
