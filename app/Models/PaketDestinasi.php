<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class PaketDestinasi extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = 'paket_destinasi'; // Nama tabel di database

    // Definisi kolom tabel
    protected $fillable = [
        'id_paketdestinasi',
        'id_profile',
        'nama_paket',
        'durasi_wisata',
        'harga_wni',
        'harga_wna',
        'total_jarak_tempuh',
        'foto',
        'tanggal_dibuat'
        // ... Kolom lain di tabel
    ];

    // Relasi dengan model lain (jika ada)
    // ...
}
