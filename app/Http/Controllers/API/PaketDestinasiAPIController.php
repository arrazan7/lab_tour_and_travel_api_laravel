<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\PaketDestinasi;
use App\Models\Tema;
use App\Models\Destinasi;

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
        $filter = $request -> all();
        $filterLokasi = $filter['lokasi'];
        $filterTema = $filter['tema'];
        $filterDurasi = $filter['durasi'];
        $filterHarga = $filter['harga'];

        if (empty($filterLokasi)) {
            // Memasukkan semua nama kota ke $filter['lokasi'] jika $filter['lokasi'] tidak berisi nilai
            $distinctKota = Destinasi::select('kota')->distinct()->get();
            $dataKotaAll = [];
            foreach ($distinctKota as $row) {
                $dataKotaAll[] = $row['kota'];
            }
            $filterLokasi = $dataKotaAll;
        }
        if (empty($filterTema)) {
            // Memasukkan semua id_tema ke $filter['tema'] jika $filter['tema'] tidak berisi nilai
            $distinctTema = Tema::select('id_tema')->distinct()->get();
            $dataTemaAll = [];
            foreach ($distinctTema as $row) {
                $dataTemaAll[] = $row['id_tema'];
            }
            $filterTema = $dataTemaAll;
        }
        if (empty($filterDurasi)) {
            // Memasukkan semua durasi wisata ke $filter['durasi'] jika $filter['durasi'] tidak berisi nilai
            $filterDurasi = [1, 2, 3, 4, 5];
        }
        if (empty($filterHarga)) {
            // Memasukkan semua harga ke $filter['harga'] jika $filter['harga'] tidak berisi nilai
            $filterHarga = [1, 2, 3, 4, 5];
        }

        $kueriFilterDurasi = "";
        // Membuat kueri filter durasi
        if (count($filterDurasi) != 0) {
            for ($i = 0; $i < count($filterDurasi); $i++) {
                if ($filterDurasi[$i] == 1) {
                    if (empty($kueriFilterDurasi)) {
                        $kueriFilterDurasi = "WHERE durasi_wisata = 1";
                    }
                    else {
                        $kueriFilterDurasi .= " OR durasi_wisata = 1";
                    }
                }
                elseif ($filterDurasi[$i] == 2) {
                    if (empty($kueriFilterDurasi)) {
                        $kueriFilterDurasi = "WHERE durasi_wisata = 2";
                    }
                    else {
                        $kueriFilterDurasi .= " OR durasi_wisata = 2";
                    }
                }
                elseif ($filterDurasi[$i] == 3) {
                    if (empty($kueriFilterDurasi)) {
                        $kueriFilterDurasi = "WHERE durasi_wisata = 3";
                    }
                    else {
                        $kueriFilterDurasi .= " OR durasi_wisata = 3";
                    }
                }
                elseif ($filterDurasi[$i] == 4) {
                    if (empty($kueriFilterDurasi)) {
                        $kueriFilterDurasi = "WHERE durasi_wisata = 4";
                    }
                    else {
                        $kueriFilterDurasi .= " OR durasi_wisata = 4";
                    }
                }
                elseif ($filterDurasi[$i] == 5) {
                    if (empty($kueriFilterDurasi)) {
                        $kueriFilterDurasi = "WHERE durasi_wisata > 4";
                    }
                    else {
                        $kueriFilterDurasi .= " OR durasi_wisata > 4";
                    }
                }
            }
        }

        $kueriFilterHarga = "";
        // Membuat kueri filter harga
        if (count($filterHarga) != 0) {
            for ($i = 0; $i < count($filterHarga); $i++) {
                if ($filterHarga[$i] == 1) {
                    if (empty($kueriFilterHarga)) {
                        $kueriFilterHarga = "WHERE (harga_wni BETWEEN 0 AND 50000)";
                    }
                    else {
                        $kueriFilterHarga .= " OR (harga_wni BETWEEN 0 AND 50000)";
                    }
                }
                elseif ($filterHarga[$i] == 2) {
                    if (empty($kueriFilterHarga)) {
                        $kueriFilterHarga = "WHERE (harga_wni BETWEEN 50001 AND 150000)";
                    }
                    else {
                        $kueriFilterHarga .= " OR (harga_wni BETWEEN 50001 AND 150000)";
                    }
                }
                elseif ($filterHarga[$i] == 3) {
                    if (empty($kueriFilterHarga)) {
                        $kueriFilterHarga = "WHERE (harga_wni BETWEEN 150001 AND 300000)";
                    }
                    else {
                        $kueriFilterHarga .= " OR (harga_wni BETWEEN 150001 AND 300000)";
                    }
                }
                elseif ($filterHarga[$i] == 4) {
                    if (empty($kueriFilterHarga)) {
                        $kueriFilterHarga = "WHERE (harga_wni BETWEEN 300001 AND 500000)";
                    }
                    else {
                        $kueriFilterHarga .= " OR (harga_wni BETWEEN 300001 AND 500000)";
                    }
                }
                elseif ($filterHarga[$i] == 5) {
                    if (empty($kueriFilterHarga)) {
                        $kueriFilterHarga = "WHERE harga_wni > 500000";
                    }
                    else {
                        $kueriFilterHarga .= " OR harga_wni > 500000";
                    }
                }
            }
        }

        // Convert array of params to a comma-separated string of placeholders
        $placeholdersKota = implode(',', array_fill(0, count($filterLokasi), '?'));
        $placeholdersTema = implode(',', array_fill(0, count($filterTema), '?'));

        $querySelected = "SELECT * FROM paket_destinasi
                                WHERE id_paketdestinasi IN
                                    (SELECT DISTINCT id_paketdestinasi FROM jadwal_destinasi
                                        WHERE id_destinasi IN
                                            (SELECT id_destinasi FROM destinasi WHERE kota IN ($placeholdersKota))
                                        AND id_destinasi IN
                                            (SELECT id_destinasi FROM tema_destinasi WHERE id_tema IN ($placeholdersTema))
                                    )
                                AND durasi_wisata IN
                                    (SELECT DISTINCT durasi_wisata FROM paket_destinasi
                                        " .$kueriFilterDurasi. "
                                    )
                                AND harga_wni IN
                                    (SELECT DISTINCT harga_wni FROM paket_destinasi
                                        " .$kueriFilterHarga. "
                                    )
                                ORDER BY id_paketdestinasi";

        // Merge all parameters into a single array
        $boundParams = array_merge($filterLokasi, $filterTema);

        try {
            // Execute the query with bound parameters
            $data = DB::select($querySelected, $boundParams);

            // Process and return data
            $filterData = [];
            foreach ($data as $row) {
                $filterData[] = (array) $row;
            }

            return response() -> json([
                'status' => true,
                'message' => 'Filter Paket Destinasi Berhasil Didapat.',
                'filter' => $filter,
                'data' => $filterData
            ], 200);
        } catch (\Exception $e) {
            // Handle the exception
            return response()->json([
                'status' => false,
                'message' => 'Gagal mendapatkan paket destinasi. ' .$e -> getMessage(). '', // User-friendly error message,
                'filter' => $filter,
                'data' => []
            ], 500); // Internal Server Error status code
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
