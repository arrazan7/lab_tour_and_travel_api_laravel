<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\PaketDestinasi;

class PaketDestinasiAPIController extends Controller
{
    public function index()
    {
        $paketDestinasi = PaketDestinasi::all(); // Mengambil semua data dari tabel paket_destinasi

        $response = [
            'status' => true,
            'message' => 'Get List Paket Destinasi Successfully.',
            'data' => $paketDestinasi, // Mengirimkan data paket_destinasi dalam format JSON
        ];

        return response()->json($response); // Mengembalikan respons JSON
    }

    public function store(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_profile', 'nama_paket'];
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
        $storedProcCall = "CALL paket_destinasi (?, ?, ?)";
        $boundParams = [
            $data['id_profile'],
            $data['nama_paket'],
            $data['foto']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedProcCall, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Paket Destinasi Berhasil Ditambahkan.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal menambahkan paket destinasi. ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }

    public function show(int $id_paketdestinasi)
    {
        // Mencari data jadwal destinasi berdasarkan id_jadwaldestinasi
        $paketDestinasi = PaketDestinasi::where('id_paketdestinasi', $id_paketdestinasi) -> get();

        // Memeriksa apakah data ditemukan
        if ($paketDestinasi -> isEmpty()) {
            return response() -> json([
                'status' => false,
                'message' => 'Data paket destinasi dengan id_paketdestinasi ' . $id_paketdestinasi . ' tidak ditemukan.',
                'data' => []
            ], 404);
        }
        else {
            return response() -> json([
                'status' => true,
                'message' => 'Data paket destinasi dengan id_paketdestinasi ' . $id_paketdestinasi . ' berhasil ditemukan.',
                'data' => $paketDestinasi
            ], 200); // Mengembalikan respons JSON
        }
    }

    public function updateNamaPaket(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_paketdestinasi', 'nama_paket'];
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
        $storedQueryUpdate = "UPDATE paket_destinasi SET nama_paket = ? WHERE id_paketdestinasi = ?";
        $boundParams = [
            $data['nama_paket'],
            $data['id_paketdestinasi']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedQueryUpdate, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Nama Paket Destinasi Berhasil Diperbarui.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal memperbarui Nama Paket Destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }

    public function updateFotoPaket(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        if (empty($data['id_paketdestinasi'])) {
            return response() -> json([
                'status' => false,
                'message' => 'Input data id_paketdestinasi tidak boleh kosong.',
                'data' => []
            ], 400);
            exit;
        }

        // Prepare parameterized stored procedure call
        $storedQueryUpdate = "UPDATE paket_destinasi SET foto = ? WHERE id_paketdestinasi = ?";
        $boundParams = [
            $data['foto'],
            $data['id_paketdestinasi']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedQueryUpdate, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Foto Paket Destinasi Berhasil Diperbarui.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal memperbarui Foto Paket Destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }
}
