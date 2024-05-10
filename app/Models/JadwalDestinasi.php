<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class JadwalDestinasi extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = 'jadwal_destinasi'; // Nama tabel di database

    // Definisi kolom tabel
    protected $fillable = [
        'id_jadwaldestinasi',
        'id_paketdestinasi',
        'hari',
        'hari_ke',
        'destinasi_ke',
        'koordinat_berangkat',
        'koordinat_tiba',
        'jarak_tempuh',
        'waktu_tempuh',
        'waktu_sebenarnya',
        'id_destinasi',
        'jam_mulai',
        'jam_selesai',
        'zona_mulai',
        'zona_selesai',
        'catatan'
        // ... Kolom lain di tabel
    ];

    // Relasi dengan model lain (jika ada)
    // ...
}
