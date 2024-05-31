<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Destinasi;
use App\Models\DestinasiTutup;
use App\Models\Tema;
use App\Models\TemaDestinasi;

class DestinasiAPIController extends Controller
{
    public function index()
    {
        // Mencari data destinasi
        $destinasi = Destinasi::all(); // Mengambil semua data dari tabel destinasi

        // Memeriksa apakah data Destinasi ditemukan
        if ($destinasi -> isEmpty()) {
            return response() -> json([
                'status' => false,
                'message' => 'Get List Destinasi Failed.',
                'data' => []
            ], 404);
        }
        else {
            $destinasiData = []; // Membuat array kosong untuk menampung data destinasi
            foreach ($destinasi as $destinasiRow) {
                // Mencari tema destinasi
                $temaDestinasi = TemaDestinasi::where('id_destinasi', $destinasiRow -> id_destinasi) -> get();
                $temaData = []; // Membuat array kosong data tema destinasi
                foreach ($temaDestinasi as $temaRow) {
                    // Mencari nama dan jenis tema
                    $tema = Tema::where('id_tema', $temaRow -> id_tema) -> first();
                    $temaData[] = [
                        'id_temadestinasi' => $temaRow -> id_temadestinasi,
                        'id_destinasi' => $temaRow -> id_destinasi,
                        'id_tema' => $temaRow -> id_tema,
                        'nama_tema' => $tema -> nama_tema,
                        'jenis' => $tema -> jenis
                    ]; // Mengisi data tema destinasi
                };

                // Mencari hari tutup
                $destinasiTutup = DestinasiTutup::where('id_destinasi', $destinasiRow -> id_destinasi) -> get();
                $tutupData = []; // Membuat array kosong data hari tutup destinasi
                foreach ($destinasiTutup as $tutupRow) {
                    $tutupData[] = [
                        'id_destinasitutup' => $tutupRow -> id_destinasitutup,
                        'id_destinasi' => $tutupRow -> id_destinasi,
                        'hari_tutup' => $tutupRow -> hari_tutup
                    ]; // Mengisi data hari tutup destinasi
                };

                $destinasiData[] = [
                    'id_destinasi' => $destinasiRow -> id_destinasi,
                    'nama_destinasi' => $destinasiRow -> nama_destinasi,
                    'jenis' => $destinasiRow -> jenis,
                    'kota' => $destinasiRow -> kota,
                    'jam_buka' => $destinasiRow -> jam_buka,
                    'jam_tutup' => $destinasiRow -> jam_tutup,
                    'jam_lokasi' => $destinasiRow -> jam_lokasi,
                    'harga_wni' => $destinasiRow -> harga_wni,
                    'harga_wna' => $destinasiRow -> harga_wna,
                    'foto' => $destinasiRow -> foto,
                    'koordinat' => $destinasiRow -> koordinat,
                    'deskripsi' => $destinasiRow -> deskripsi,
                    'rating' => $destinasiRow -> rating,
                    'tema' => $temaData, // Menyisipkan data tema destinasi
                    'tutup' => $tutupData, // Menyisipkan data hari tutup destinasi
                ]; // Menyisipkan data destinasi ke array
            }

            // Kembalikan data destinasi dalam format JSON dengan pesan sukses
            return response()->json([
                'status' => true,
                'message' => 'Get List Destinasi Successfully.',
                'data' => $destinasiData
            ], 200);
        }
    }

    public function show(int $id_destinasi)
    {
        // Mencari data destinasi berdasarkan id_destinasi
        $destinasi = Destinasi::where('id_destinasi', $id_destinasi) -> get();

        // Memeriksa apakah data ditemukan
        if ($destinasi -> isEmpty()) {
            return response() -> json([
                'status' => false,
                'message' => 'Get List Destinasi by Id ' . $id_destinasi . ' Failed.',
                'data' => []
            ], 404);
        }
        else {
            return response() -> json([
                'status' => true,
                'message' => 'Get List Destinasi by Id ' . $id_destinasi . ' Successfully.',
                'data' => $destinasi
            ], 200); // Mengembalikan respons JSON
        }
    }

    // public function store(Request $request)
    // {
    //     // Dapatkan data yang dikirim dari Laravel UI
    //     $data = $request -> all();

    //     // Validate input data
    //     $requiredFields = ['id_paketdestinasi', 'hari', 'id_destinasi', 'jam_mulai', 'jam_selesai'];
    //     foreach ($requiredFields as $field) {
    //         if (empty($data[$field])) {
    //             return response() -> json([
    //                 'status' => false,
    //                 'message' => "Input data `{$field}` tidak boleh kosong.",
    //                 'data' => []
    //             ], 400);
    //             exit;
    //         }
    //     }

    //     // Prepare parameterized stored procedure call
    //     $storedProcCall = "CALL jadwal_destinasi (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    //     $boundParams = [
    //         $data['id_paketdestinasi'],
    //         $data['hari'],
    //         $data['koordinat_berangkat'],
    //         $data['koordinat_tiba'],
    //         $data['jarak_tempuh'],
    //         $data['waktu_tempuh'],
    //         $data['id_destinasi'],
    //         $data['jam_mulai'],
    //         $data['jam_selesai'],
    //         $data['zona_mulai'],
    //         $data['zona_selesai'],
    //         $data['catatan'],
    //     ];

    //     // Execute stored procedure using try-catch block
    //     try {
    //         DB::statement($storedProcCall, $boundParams);

    //         return response() -> json([
    //             'status' => true,
    //             'message' => 'Jadwal Destinasi Berhasil Ditambahkan.',
    //             'data' => $data
    //         ], 200);
    //     } catch (\Exception $e) {
    //         return response() -> json([
    //             'status' => false,
    //             'message' => 'Gagal menambahkan jadwal destinasi. ' .$e. '', // User-friendly error message,
    //             'data' => []
    //         ], 500);
    //     }
    // }

    // public function updateJamMulai(Request $request)
    // {
    //     // Dapatkan data yang dikirim dari Laravel UI
    //     $data = $request -> all();

    //     // Validate input data
    //     $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke', 'jam_mulai'];
    //     foreach ($requiredFields as $field) {
    //         if (empty($data[$field])) {
    //             return response() -> json([
    //                 'status' => false,
    //                 'message' => 'Input data ' .$field. ' tidak boleh kosong.',
    //                 'data' => []
    //             ], 400);
    //             exit;
    //         }
    //     }

    //     // Prepare parameterized stored procedure call
    //     $storedProcCall = "CALL update_jam_mulai (?, ?, ?, ?)";
    //     $boundParams = [
    //         $data['id_paketdestinasi'],
    //         $data['hari_ke'],
    //         $data['destinasi_ke'],
    //         $data['jam_mulai']
    //     ];

    //     // Execute stored procedure using try-catch block
    //     try {
    //         DB::statement($storedProcCall, $boundParams);

    //         return response() -> json([
    //             'status' => true,
    //             'message' => 'Jam Mulai Berhasil Diperbarui.',
    //             'data' => $data
    //         ], 200);
    //     } catch (\Exception $e) {
    //         return response() -> json([
    //             'status' => false,
    //             'message' => 'Gagal memperbarui Jam Mulai. Message: ' .$e. '', // User-friendly error message,
    //             'data' => []
    //         ], 500);
    //     }
    // }

    // public function updateJamSelesai(Request $request)
    // {
    //     // Dapatkan data yang dikirim dari Laravel UI
    //     $data = $request -> all();

    //     // Validate input data
    //     $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke', 'jam_selesai'];
    //     foreach ($requiredFields as $field) {
    //         if (empty($data[$field])) {
    //             return response() -> json([
    //                 'status' => false,
    //                 'message' => 'Input data ' .$field. ' tidak boleh kosong.',
    //                 'data' => []
    //             ], 400);
    //             exit;
    //         }
    //     }

    //     // Prepare parameterized stored procedure call
    //     $storedProcCall = "CALL update_jam_selesai (?, ?, ?, ?)";
    //     $boundParams = [
    //         $data['id_paketdestinasi'],
    //         $data['hari_ke'],
    //         $data['destinasi_ke'],
    //         $data['jam_selesai']
    //     ];

    //     // Execute stored procedure using try-catch block
    //     try {
    //         DB::statement($storedProcCall, $boundParams);

    //         return response() -> json([
    //             'status' => true,
    //             'message' => 'Jam Selesai Berhasil Diperbarui.',
    //             'data' => $data
    //         ], 200);
    //     } catch (\Exception $e) {
    //         return response() -> json([
    //             'status' => false,
    //             'message' => 'Gagal memperbarui Jam Selesai. Message: ' .$e. '', // User-friendly error message,
    //             'data' => []
    //         ], 500);
    //     }
    // }

    // public function updateIdDestinasi(Request $request)
    // {
    //     // Dapatkan data yang dikirim dari Laravel UI
    //     $data = $request -> all();

    //     // Validate input data
    //     $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke', 'id_destinasi'];
    //     foreach ($requiredFields as $field) {
    //         if (empty($data[$field])) {
    //             return response() -> json([
    //                 'status' => false,
    //                 'message' => 'Input data ' .$field. ' tidak boleh kosong.',
    //                 'data' => []
    //             ], 400);
    //             exit;
    //         }
    //     }

    //     // Prepare parameterized stored procedure call
    //     $storedQueryUpdate = "UPDATE jadwal_destinasi SET id_destinasi = ? WHERE id_paketdestinasi = ? AND hari_ke = ? AND destinasi_ke = ?";
    //     $boundParams = [
    //         $data['id_destinasi'],
    //         $data['id_paketdestinasi'],
    //         $data['hari_ke'],
    //         $data['destinasi_ke']
    //     ];

    //     // Execute stored procedure using try-catch block
    //     try {
    //         DB::statement($storedQueryUpdate, $boundParams);

    //         return response() -> json([
    //             'status' => true,
    //             'message' => 'ID Destinasi Berhasil Diperbarui.',
    //             'data' => $data
    //         ], 200);
    //     } catch (\Exception $e) {
    //         return response() -> json([
    //             'status' => false,
    //             'message' => 'Gagal memperbarui ID Destinasi. Message: ' .$e. '', // User-friendly error message,
    //             'data' => []
    //         ], 500);
    //     }
    // }

    // public function destroy(Request $request)
    // {
    //     // Dapatkan data yang dikirim dari Laravel UI
    //     $data = $request -> all();

    //     // Validate input data
    //     $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke'];
    //     foreach ($requiredFields as $field) {
    //         if (empty($data[$field])) {
    //             return response() -> json([
    //                 'status' => false,
    //                 'message' => 'Input data ' .$field. ' tidak boleh kosong.',
    //                 'data' => []
    //             ], 400);
    //             exit;
    //         }
    //     }

    //     // Prepare parameterized stored procedure call
    //     $storedProcCall = "CALL delete_jadwal_destinasi (?, ?, ?)";
    //     $boundParams = [
    //         $data['id_paketdestinasi'],
    //         $data['hari_ke'],
    //         $data['destinasi_ke']
    //     ];

    //     // Execute stored procedure using try-catch block
    //     try {
    //         DB::statement($storedProcCall, $boundParams);

    //         return response() -> json([
    //             'status' => true,
    //             'message' => 'Jadwal Destinasi Berhasil Dihapus.',
    //             'data' => $data
    //         ], 200);
    //     } catch (\Exception $e) {
    //         return response() -> json([
    //             'status' => false,
    //             'message' => 'Gagal menghapus jadwal destinasi. Message: ' .$e. '', // User-friendly error message,
    //             'data' => []
    //         ], 500);
    //     }
    // }
}
