<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthAPIController;
use App\Http\Controllers\API\DestinasiAPIController;
use App\Http\Controllers\API\PaketDestinasiAPIController;
use App\Http\Controllers\API\JadwalDestinasiAPIController;

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');

// Open Routes
Route::post('/authenticate', [AuthAPIController::class, 'login']);
Route::post('/register', [AuthAPIController::class, 'register']);

// Protected Routes
Route::group(["middleware" => ["auth:sanctum"]], function(){
    Route::get('/logout', [AuthAPIController::class, 'logout']);
    Route::get('/profile', [AuthAPIController::class, 'profile']);
});

Route::get('/read-destinasi', [DestinasiAPIController::class, 'index']);

Route::get('/read-paket', [PaketDestinasiAPIController::class, 'index']);
Route::post('/store-paket', [PaketDestinasiAPIController::class, 'store']);
Route::get('/search-paket/{id_paketdestinasi}', [PaketDestinasiAPIController::class, 'show']);
Route::post('/update-nama-paket', [PaketDestinasiAPIController::class, 'updateNamaPaket']);
Route::post('/update-foto-paket', [PaketDestinasiAPIController::class, 'updateFotoPaket']);

Route::get('/read-jadwal/{id_paketdestinasi}', [JadwalDestinasiAPIController::class, 'indexByID']);
Route::get('/search-jadwal/{id_jadwaldestinasi}', [JadwalDestinasiAPIController::class, 'show']);
Route::post('/store-jadwal', [JadwalDestinasiAPIController::class, 'store']);
Route::post('/update-jam-mulai', [JadwalDestinasiAPIController::class, 'updateJamMulai']);
Route::post('/update-jam-selesai', [JadwalDestinasiAPIController::class, 'updateJamSelesai']);
Route::post('/update-id-destinasi', [JadwalDestinasiAPIController::class, 'updateIdDestinasi']);
Route::post('/delete-jadwal', [JadwalDestinasiAPIController::class, 'destroy']);

