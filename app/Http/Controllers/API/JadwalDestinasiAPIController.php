<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\JadwalDestinasi;
use App\Models\Destinasi;

class JadwalDestinasiAPIController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function indexByID(int $id_paketdestinasi)
    {
        // Mencari data jadwal destinasi berdasarkan id_paketdestinasi
        $jadwalDestinasi = JadwalDestinasi::where('id_paketdestinasi', $id_paketdestinasi)
        -> groupBy('id_paketdestinasi', 'hari_ke', 'destinasi_ke')
        -> orderBy('hari_ke', 'asc')
        -> orderBy('destinasi_ke', 'asc')
        -> get();

        // Memeriksa apakah data ditemukan
        if ($jadwalDestinasi -> isEmpty()) {
            $response = [
                'status' => false,
                'message' => 'Data jadwal destinasi dengan id_paketdestinasi ' . $id_paketdestinasi . ' tidak ditemukan.',
                'data' => []
            ];

            return response() -> json($response);
        }
        else {
            $dataJadwal = $jadwalDestinasi;
            for ($i = 0; $i < count($jadwalDestinasi); $i++) {
                $destinasi = Destinasi::where('id_destinasi', $jadwalDestinasi[$i]['id_destinasi']) -> first();
                $namaDestinasi = $destinasi ? $destinasi['nama_destinasi'] : ''; // Set default value if not found
                $kotaDestinasi = $destinasi ? $destinasi['kota'] : '';
                $fotoDestinasi = $destinasi ? $destinasi['foto'] : '';
                $wniDestinasi = $destinasi ? $destinasi['harga_wni'] : '';
                $wnaDestinasi = $destinasi ? $destinasi['harga_wna'] : '';
                $ratingDestinasi = $destinasi ? $destinasi['rating'] : '';
                $jadwalDestinasi[$i] = [
                    'id_jadwaldestinasi' => $dataJadwal[$i]['id_jadwaldestinasi'],
                    'id_paketdestinasi' => $dataJadwal[$i]['id_paketdestinasi'],
                    'hari' => $dataJadwal[$i]['hari'],
                    'hari_ke' => $dataJadwal[$i]['hari_ke'],
                    'destinasi_ke' => $dataJadwal[$i]['destinasi_ke'],
                    'koordinat_berangkat' => $dataJadwal[$i]['koordinat_berangkat'],
                    'koordinat_tiba' => $dataJadwal[$i]['koordinat_tiba'],
                    'jarak_tempuh' => $dataJadwal[$i]['jarak_tempuh'],
                    'waktu_tempuh' => $dataJadwal[$i]['waktu_tempuh'],
                    'waktu_sebenarnya' => $dataJadwal[$i]['waktu_sebenarnya'],
                    'id_destinasi' => $dataJadwal[$i]['id_destinasi'],
                    'jam_mulai' => $dataJadwal[$i]['jam_mulai'],
                    'jam_selesai' => $dataJadwal[$i]['jam_selesai'],
                    'jam_lokasi' => $dataJadwal[$i]['jam_lokasi'],
                    'catatan' => $dataJadwal[$i]['catatan'],
                    'nama_destinasi' => $namaDestinasi,
                    'kota' => $kotaDestinasi,
                    'foto' => $fotoDestinasi,
                    'harga_wni' => $wniDestinasi,
                    'harga_wna' => $wnaDestinasi,
                    'rating' => $ratingDestinasi,
                ];
            }

            $response = [
                'status' => true,
                'message' => 'Data jadwal destinasi dengan id_paketdestinasi ' . $id_paketdestinasi . ' berhasil ditemukan.',
                'data' => $jadwalDestinasi
            ];

            return response() -> json($response); // Mengembalikan respons JSON
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(int $id_jadwaldestinasi)
    {
        // Mencari data jadwal destinasi berdasarkan id_jadwaldestinasi
        $jadwalDestinasi = JadwalDestinasi::where('id_jadwaldestinasi', $id_jadwaldestinasi) -> get() -> first();

        // Memeriksa apakah data ditemukan
        if (!$jadwalDestinasi) {
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

    /**
     * Store a newly created resource in storage.
     */
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
        $storedProcCall = "CALL jadwal_destinasi (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
            $data['jam_lokasi'],
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

    /**
     * Update the specified resource in storage.
     */
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

    /**
     * Update the specified resource in storage.
     */
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

    /**
     * Update the specified resource in storage.
     */
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

        // Prepare parameterized query update
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

    /**
     * Update the specified resource in storage.
     */
    public function updateWaktuTempuh(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke', 'waktu_tempuh'];
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
        $storedProcCall = "CALL update_waktu_tempuh (?, ?, ?, ?)";
        $boundParams = [
            $data['id_paketdestinasi'],
            $data['hari_ke'],
            $data['destinasi_ke'],
            $data['waktu_tempuh']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedProcCall, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Waktu Tempuh Berhasil Diperbarui.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal memperbarui Waktu Tempuh. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function updateJarakTempuh(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Validate input data
        $requiredFields = ['id_paketdestinasi', 'hari_ke', 'destinasi_ke', 'jarak_tempuh'];
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

        // Prepare parameterized query update
        $storedQueryUpdate = "UPDATE jadwal_destinasi SET jarak_tempuh = ? WHERE id_paketdestinasi = ? AND hari_ke = ? AND destinasi_ke = ?";
        $boundParams = [
            $data['jarak_tempuh'],
            $data['id_paketdestinasi'],
            $data['hari_ke'],
            $data['destinasi_ke']
        ];

        // Execute stored procedure using try-catch block
        try {
            DB::statement($storedQueryUpdate, $boundParams);

            return response() -> json([
                'status' => true,
                'message' => 'Jarak Tempuh Berhasil Diperbarui.',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal memperbarui Jarak Tempuh. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
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
