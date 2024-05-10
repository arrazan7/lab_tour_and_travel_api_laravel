<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\JadwalDestinasi;

class JadwalDestinasiAPIController extends Controller
{
    public function indexByID(int $id_paketdestinasi)
    {
        // Mencari data jadwal destinasi berdasarkan id_paketdestinasi
        $paketDestinasi = JadwalDestinasi::where('id_paketdestinasi', $id_paketdestinasi)
        -> groupBy('id_paketdestinasi', 'hari_ke', 'destinasi_ke')
        -> orderBy('hari_ke', 'asc')
        -> orderBy('destinasi_ke', 'asc')
        -> get();

        // Memeriksa apakah data ditemukan
        if ($paketDestinasi -> isEmpty()) {
            $response = [
                'status' => false,
                'message' => 'Data jadwal destinasi dengan id_paketdestinasi ' . $id_paketdestinasi . ' tidak ditemukan.',
                'data' => []
            ];

            return response() -> json($response);
        }
        else {
            $response = [
                'status' => true,
                'message' => 'Data jadwal destinasi dengan id_paketdestinasi ' . $id_paketdestinasi . ' berhasil ditemukan.',
                'data' => $paketDestinasi
            ];

            return response() -> json($response); // Mengembalikan respons JSON
        }
    }

    public function show(int $id_jadwaldestinasi)
    {
        // Mencari data jadwal destinasi berdasarkan id_jadwaldestinasi
        $jadwalDestinasi = JadwalDestinasi::where('id_jadwaldestinasi', $id_jadwaldestinasi) -> get();

        // Memeriksa apakah data ditemukan
        if ($jadwalDestinasi -> isEmpty()) {
            return response() -> json([
                'status' => false,
                'message' => 'Data jadwal destinasi dengan id_jadwaldestinasi ' . $id_jadwaldestinasi . ' tidak ditemukan.',
                'data' => []
            ], 404);
        }
        else {
            return response() -> json([
                'status' => true,
                'message' => 'Data jadwal destinasi dengan id_paketdestinasi ' . $id_jadwaldestinasi . ' berhasil ditemukan.',
                'data' => $jadwalDestinasi
            ], 200); // Mengembalikan respons JSON
        }
    }

    public function store(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_paketdestinasi', 'hari', 'id_destinasi', 'jam_mulai', 'jam_selesai'];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                return response() -> json([
                    'status' => false,
                    'message' => "Input data `{$field}` tidak boleh kosong.",
                    'data' => []
                ], 400);
                exit;
            }
        }

        // Prepare parameterized stored procedure call
        $storedProcCall = "CALL jadwal_destinasi (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        $boundParams = [
            $data['id_paketdestinasi'],
            $data['hari'],
            $data['koordinat_berangkat'],
            $data['koordinat_tiba'],
            $data['jarak_tempuh'],
            $data['waktu_tempuh'],
            $data['id_destinasi'],
            $data['jam_mulai'],
            $data['jam_selesai'],
            $data['zona_mulai'],
            $data['zona_selesai'],
            $data['catatan'],
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedProcCall, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Jadwal Destinasi Berhasil Ditambahkan.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal menambahkan jadwal destinasi. ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }

    public function updateJamMulai(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke', 'jam_mulai'];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                return response() -> json([
                    'status' => false,
                    'message' => 'Input data ' .$field. ' tidak boleh kosong.',
                    'data' => []
                ], 400);
                exit;
            }
        }

        // Prepare parameterized stored procedure call
        $storedProcCall = "CALL update_jam_mulai (?, ?, ?, ?)";
        $boundParams = [
            $data['id_paketdestinasi'],
            $data['hari_ke'],
            $data['destinasi_ke'],
            $data['jam_mulai']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedProcCall, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Jam Mulai Berhasil Diperbarui.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal memperbarui Jam Mulai. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }

    public function updateJamSelesai(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke', 'jam_selesai'];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                return response() -> json([
                    'status' => false,
                    'message' => 'Input data ' .$field. ' tidak boleh kosong.',
                    'data' => []
                ], 400);
                exit;
            }
        }

        // Prepare parameterized stored procedure call
        $storedProcCall = "CALL update_jam_selesai (?, ?, ?, ?)";
        $boundParams = [
            $data['id_paketdestinasi'],
            $data['hari_ke'],
            $data['destinasi_ke'],
            $data['jam_selesai']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedProcCall, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Jam Selesai Berhasil Diperbarui.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal memperbarui Jam Selesai. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }

    public function updateIdDestinasi(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke', 'id_destinasi'];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                return response() -> json([
                    'status' => false,
                    'message' => 'Input data ' .$field. ' tidak boleh kosong.',
                    'data' => []
                ], 400);
                exit;
            }
        }

        // Prepare parameterized stored procedure call
        $storedQueryUpdate = "UPDATE jadwal_destinasi SET id_destinasi = ? WHERE id_paketdestinasi = ? AND hari_ke = ? AND destinasi_ke = ?";
        $boundParams = [
            $data['id_destinasi'],
            $data['id_paketdestinasi'],
            $data['hari_ke'],
            $data['destinasi_ke']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedQueryUpdate, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'ID Destinasi Berhasil Diperbarui.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal memperbarui ID Destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }

    public function destroy(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke'];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                return response() -> json([
                    'status' => false,
                    'message' => 'Input data ' .$field. ' tidak boleh kosong.',
                    'data' => []
                ], 400);
                exit;
            }
        }

        // Prepare parameterized stored procedure call
        $storedProcCall = "CALL delete_jadwal_destinasi (?, ?, ?)";
        $boundParams = [
            $data['id_paketdestinasi'],
            $data['hari_ke'],
            $data['destinasi_ke']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedProcCall, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Jadwal Destinasi Berhasil Dihapus.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal menghapus jadwal destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }
}
