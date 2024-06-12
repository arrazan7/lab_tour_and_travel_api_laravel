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

        // Memeriksa apakah data ditemukan
        if ($paketDestinasi -> isEmpty()) {
            $response = [
                'status' => false,
                'message' => 'Get List Paket Destinasi Failed.',
                'data' => []
            ];

            return response() -> json($response);
        }
        else {
            $response = [
                'status' => true,
                'message' => 'Get List Paket Destinasi Successfully.',
                'data' => $paketDestinasi, // Mengirimkan data paket_destinasi dalam format JSON
            ];

            return response()->json($response); // Mengembalikan respons JSON
        }
    }

    public function filter(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        $paketDestinasi = PaketDestinasi::all(); // Mengambil semua data dari tabel paket_destinasi

        // Memeriksa apakah data ditemukan
        if ($paketDestinasi -> isEmpty()) {
            $response = [
                'status' => false,
                'message' => 'Get List Paket Destinasi Failed.',
                'data' => []
            ];

            return response() -> json($response);
        }
        else {
            $response = [
                'status' => true,
                'message' => 'Get List Paket Destinasi Successfully.',
                'data' => $paketDestinasi, // Mengirimkan data paket_destinasi dalam format JSON
            ];

            return response()->json($response); // Mengembalikan respons JSON
        }
    }

    public function show(int $id_paketdestinasi)
    {
        // Mencari data jadwal destinasi berdasarkan id_jadwaldestinasi
        $paketDestinasi = PaketDestinasi::where('id_paketdestinasi', $id_paketdestinasi) -> get() -> first();

        // Memeriksa apakah data ditemukan
        if (!$paketDestinasi) {
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

    public function update(Request $request)
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

        // Prepare parameterized stored update
        $storedNama = "UPDATE paket_destinasi SET nama_paket = ? WHERE id_paketdestinasi = ?";
        $paramsNama = [
            $data['nama_paket'],
            $data['id_paketdestinasi']
        ];

        // Execute stored update using try-catch block
        try {
            DB::statement($storedNama, $paramsNama);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal memperbarui Nama Paket Destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }

        if (!empty($data['foto'])) {
            // foto perlu diperbarui
            // Prepare parameterized stored update
            $storedFoto = "UPDATE paket_destinasi SET foto = ? WHERE id_paketdestinasi = ?";
            $paramsFoto = [
                $data['foto'],
                $data['id_paketdestinasi']
            ];

            // Execute stored query update using try-catch block
            try {
                DB::statement($storedFoto, $paramsFoto);
            } catch (\Exception $e) {
                return response() -> json([
                    'status' => false,
                    'message' => 'Gagal memperbarui Foto Paket Destinasi. Message: ' .$e. '', // User-friendly error message,
                    'data' => []
                ], 500);
            }
        }

        return response() -> json([
            'status' => true,
            'message' => 'Paket Destinasi Berhasil Diperbarui.',
            'data' => $data
        ], 200);
    }

    public function destroy(Request $request)
    {
        // Dapatkan id_destinasi dari request
        $id_paketdestinasi = $request->input('id_paketdestinasi');
        $durasi_wisata = $request->input('durasi_wisata');

        // Hapus jadwal destinasi. Prepare parameterized stored delete
        for ($hari_ke = $durasi_wisata; $hari_ke >= 1; $hari_ke--) {
            $queryJadwal = "DELETE FROM jadwal_destinasi WHERE id_paketdestinasi = ? AND hari_ke = ?";
            $paramJadwal = [
                $id_paketdestinasi,
                $hari_ke
            ];
            // Execute stored query update using try-catch block
            try {
                DB::statement($queryJadwal, $paramJadwal);
            } catch (\Exception $e) {
                return response() -> json([
                    'status' => false,
                    'message' => 'Gagal menghapus jadwal Destinasi. Message: ' .$e. '', // User-friendly error message,
                    'data' => []
                ], 500);
            }
        }

        // Hapus paket destinasi. Prepare parameterized stored delete
        $queryPaket = "DELETE FROM paket_destinasi WHERE id_paketdestinasi = ?";
        $paramPaket = [
            $id_paketdestinasi
        ];
        // Execute stored query update using try-catch block
        try {
            DB::statement($queryPaket, $paramPaket);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal menghapus paket Destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }

        return response() -> json([
            'status' => true,
            'message' => 'Jadwal Destinasi Berhasil Dihapus.',
            'data' => $id_paketdestinasi
        ], 200);
    }
}
