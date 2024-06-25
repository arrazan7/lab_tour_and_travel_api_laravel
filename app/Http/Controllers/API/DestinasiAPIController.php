<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use App\Models\Destinasi;
use App\Models\DestinasiTutup;
use App\Models\Tema;
use App\Models\TemaDestinasi;

class DestinasiAPIController extends Controller
{
    /**
     * Display a listing of the resource.
     */
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

    /**
     * Display a listing of the resource.
     */
    public function indexShort()
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
            // Kembalikan data destinasi dalam format JSON dengan pesan sukses
            return response()->json([
                'status' => true,
                'message' => 'Get List Destinasi Successfully.',
                'data' => $destinasi
            ], 200);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(int $id_destinasi)
    {
        // Mencari data destinasi berdasarkan id_destinasi
        $destinasi = Destinasi::where('id_destinasi', $id_destinasi) -> get() -> first();

        // Memeriksa apakah data ditemukan
        if (!$destinasi) {
            return response() -> json([
                'status' => false,
                'message' => 'Get List Destinasi by Id ' . $id_destinasi . ' Failed.',
                'data' => []
            ], 404);
        }
        else {
            // Mencari tema destinasi
            $temaDestinasi = TemaDestinasi::where('id_destinasi', $id_destinasi) -> get();
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
            $destinasiTutup = DestinasiTutup::where('id_destinasi', $id_destinasi) -> get();
            $tutupData = []; // Membuat array kosong data hari tutup destinasi
            foreach ($destinasiTutup as $tutupRow) {
                $tutupData[] = [
                    'id_destinasitutup' => $tutupRow -> id_destinasitutup,
                    'id_destinasi' => $tutupRow -> id_destinasi,
                    'hari_tutup' => $tutupRow -> hari_tutup
                ]; // Mengisi data hari tutup destinasi
            };

            $destinasiData = [
                'id_destinasi' => $destinasi -> id_destinasi,
                'nama_destinasi' => $destinasi -> nama_destinasi,
                'jenis' => $destinasi -> jenis,
                'kota' => $destinasi -> kota,
                'jam_buka' => $destinasi -> jam_buka,
                'jam_tutup' => $destinasi -> jam_tutup,
                'jam_lokasi' => $destinasi -> jam_lokasi,
                'harga_wni' => $destinasi -> harga_wni,
                'harga_wna' => $destinasi -> harga_wna,
                'foto' => $destinasi -> foto,
                'koordinat' => $destinasi -> koordinat,
                'deskripsi' => $destinasi -> deskripsi,
                'rating' => $destinasi -> rating,
                'tema' => $temaData, // Menyisipkan data tema destinasi
                'tutup' => $tutupData, // Menyisipkan data hari tutup destinasi
            ]; // Menyisipkan data destinasi ke array

            return response() -> json([
                'status' => true,
                'message' => 'Get List Destinasi by Id ' . $id_destinasi . ' Successfully.',
                'data' => $destinasiData
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
        $requiredFields = [
            'nama_destinasi',
            'jenis',
            'kota',
            'jam_buka',
            'jam_tutup',
            'jam_lokasi',
            'harga_wni',
            'harga_wna'
        ];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                return response() -> json([
                    'status' => false,
                    'message' => "Input data `{$field}` tidak boleh kosong.",
                    'data' => []
                ], 400);
                exit;
            }
            else {
                // Menghindari null
                // upload image
                if ($request -> hasFile('foto')) {
                    $extension = $request -> file('foto') -> getClientOriginalExtension();
                    $basename = uniqid() . time();

                    $namaFileFoto = "{$basename}.{$extension}";
                } else {
                    $namaFileFoto = '';
                }
                if (empty($data['koordinat'])) {
                    $data['koordinat'] = "";
                }
                if (empty($data['deskripsi'])) {
                    $data['deskripsi'] = "";
                }

                // Prepare parameterized stored insert destinasi
                // INSERT INTO destinasi VALUES (0, 'Pasar Kotagede', 'wisata', 'Yogyakarta', '00:00', '24:00', 'WIB', 25000, 25000, '', '', '', 10),
                $storedInsertDestinasi = "INSERT INTO destinasi VALUES (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 10)";
                $boundParamsDestinasi = [
                    $data['nama_destinasi'],
                    $data['jenis'],
                    $data['kota'],
                    $data['jam_buka'],
                    $data['jam_tutup'],
                    $data['jam_lokasi'],
                    $data['harga_wni'],
                    $data['harga_wna'],
                    $namaFileFoto,
                    $data['koordinat'],
                    $data['deskripsi']
                ];

                // Execute stored insert using try-catch block
                try {
                    DB::statement($storedInsertDestinasi, $boundParamsDestinasi);

                    // save image jika ada
                    if ($request -> hasFile('foto')) {
                        $pathFoto = $request -> file('foto') -> storeAs('public/destinasi', $namaFileFoto);
                    }

                    $destinasi = Destinasi::where('nama_destinasi', $data['nama_destinasi'])
                    ->where('jenis', $data['jenis'])
                    ->where('kota', $data['kota'])
                    ->get()
                    ->first();

                    foreach (json_decode($data['id_tema'], true) as $id_tema) {
                        // Prepare parameterized stored insert tema destinasi
                        $storedInsertTema = "INSERT INTO tema_destinasi VALUES (0, ?, ?)";
                        $boundParamsTema = [
                            $destinasi -> id_destinasi,
                            $id_tema
                        ];

                        try {
                            DB::statement($storedInsertTema, $boundParamsTema);
                        } catch (\Exception $e) {
                            return response() -> json([
                                'status' => false,
                                'message' => 'Gagal menambahkan tema destinasi. ' .$e. '', // User-friendly error message,
                                'data' => []
                            ], 500);
                            exit;
                        }
                    };

                    foreach (json_decode($data['hari_tutup'], true) as $nama_hari) {
                        // Prepare parameterized stored insert tema destinasi
                        $storedInsertTutup = "INSERT INTO destinasi_tutup VALUES (0, ?, ?)";
                        $boundParamsTutup = [
                            $destinasi -> id_destinasi,
                            $nama_hari
                        ];

                        try {
                            DB::statement($storedInsertTutup, $boundParamsTutup);
                        } catch (\Exception $e) {
                            return response() -> json([
                                'status' => false,
                                'message' => 'Gagal menambahkan hari destinasi tutup. ' .$e. '', // User-friendly error message,
                                'data' => []
                            ], 500);
                            exit;
                        }
                    };

                    return response() -> json([
                        'status' => true,
                        'message' => 'Berhasil menambahkan destinasi.', // User-friendly error message,
                        'data' => $data
                    ], 200);

                } catch (\Exception $e) {
                    return response() -> json([
                        'status' => false,
                        'message' => 'Gagal menambahkan destinasi. ' .$e. '', // User-friendly error message,
                        'data' => []
                    ], 500);
                }
            }
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request)
    {
        // Dapatkan data yang dikirim dari Laravel UI
        $data = $request -> all();

        // Mencari data destinasi berdasarkan id_destinasi
        $destinasi = Destinasi::where('id_destinasi', $data['id_destinasi']) -> get() -> first();

        // Memeriksa apakah data ditemukan
        if (!$destinasi) {
            return response() -> json([
                'status' => false,
                'message' => 'Get List Destinasi by Id ' . $data['id_destinasi'] . ' Failed.',
                'data' => []
            ], 404);
        }
        else {
            // Mencari tema destinasi
            $temaDestinasi = TemaDestinasi::where('id_destinasi', $data['id_destinasi']) -> get();
            $temaData = []; // Membuat array kosong data tema destinasi
            foreach ($temaDestinasi as $temaRow) {
                $temaData[] = $temaRow -> id_tema; // Mengisi data tema destinasi
            };

            // Mencari hari tutup
            $destinasiTutup = DestinasiTutup::where('id_destinasi', $data['id_destinasi']) -> get();
            $tutupData = []; // Membuat array kosong data hari tutup destinasi
            foreach ($destinasiTutup as $tutupRow) {
                $tutupData[] = $tutupRow -> hari_tutup; // Mengisi data hari tutup destinasi
            };

            $destinasiDatabase = [
                'id_destinasi' => $destinasi -> id_destinasi,
                'nama_destinasi' => $destinasi -> nama_destinasi,
                'jenis' => $destinasi -> jenis,
                'kota' => $destinasi -> kota,
                'jam_buka' => $destinasi -> jam_buka,
                'jam_tutup' => $destinasi -> jam_tutup,
                'jam_lokasi' => $destinasi -> jam_lokasi,
                'harga_wni' => $destinasi -> harga_wni,
                'harga_wna' => $destinasi -> harga_wna,
                'foto' => $destinasi -> foto,
                'koordinat' => $destinasi -> koordinat,
                'deskripsi' => $destinasi -> deskripsi,
                'rating' => $destinasi -> rating,
                'hari_tutup' => $tutupData, // Menyisipkan data hari tutup destinasi
                'id_tema' => $temaData // Menyisipkan data tema destinasi
            ]; // Menyisipkan data destinasi ke array

            // Menghindari null
            if (empty($data['koordinat'])) {
                $data['koordinat'] = "";
            }
            if (empty($data['deskripsi'])) {
                $data['deskripsi'] = "";
            }
            if ($request -> hasFile('foto')) {
                // foto perlu diperbarui
                $extension = $request -> file('foto') -> getClientOriginalExtension();
                $basename = uniqid() . time();

                $namaFileFoto = "{$basename}.{$extension}";
            }
            else {
                $namaFileFoto = $destinasiDatabase['foto'];
            }

            $storedQueryUpdate = "UPDATE destinasi SET
                nama_destinasi = :nama_destinasi,
                jenis = :jenis,
                kota = :kota,
                jam_buka = :jam_buka,
                jam_tutup = :jam_tutup,
                jam_lokasi = :jam_lokasi,
                harga_wni = :harga_wni,
                harga_wna = :harga_wna,
                foto = :foto,
                koordinat = :koordinat,
                deskripsi = :deskripsi
            WHERE id_destinasi = :id_destinasi";

            $boundParams = [
                ':nama_destinasi' => $data['nama_destinasi'],
                ':jenis' => $data['jenis'],
                ':kota' => $data['kota'],
                ':jam_buka' => $data['jam_buka'],
                ':jam_tutup' => $data['jam_tutup'],
                ':jam_lokasi' => $data['jam_lokasi'],
                ':harga_wni' => $data['harga_wni'],
                ':harga_wna' => $data['harga_wna'],
                ':foto' => $namaFileFoto,
                ':koordinat' => $data['koordinat'],
                ':deskripsi' => $data['deskripsi'],
                ':id_destinasi' => $data['id_destinasi'],
            ];

            // Execute stored query update using try-catch block
            try {
                DB::statement($storedQueryUpdate, $boundParams);
            } catch (\Exception $e) {
                return response() -> json([
                    'status' => false,
                    'message' => 'Gagal memperbarui data Destinasi. Message: ' .$e. '', // User-friendly error message,
                    'data' => []
                ], 500);
            }

            // save new image jika ada
            if ($request -> hasFile('foto')) {
                // delete old image
                File::delete(public_path() ."/storage/destinasi/".$destinasiDatabase['foto']);
                // save new image
                $pathFoto = $request -> file('foto') -> storeAs('public/destinasi', $namaFileFoto);
            }

            // Menghapus id_tema pada database yang tidak ada di data form
            foreach ($destinasiDatabase['id_tema'] as $id_temaDatabase) {
                if (!in_array($id_temaDatabase, $data['id_tema'])) {
                    // Prepare parameterized stored delete
                    $storedQueryDelete = "DELETE FROM tema_destinasi WHERE id_destinasi = ? AND id_tema = ?";
                    $boundParams = [
                        $data['id_destinasi'],
                        $id_temaDatabase
                    ];

                    // Execute stored query update using try-catch block
                    try {
                        DB::statement($storedQueryDelete, $boundParams);
                    } catch (\Exception $e) {
                        return response() -> json([
                            'status' => false,
                            'message' => 'Gagal menghapus tema Destinasi. Message: ' .$e. '', // User-friendly error message,
                            'data' => []
                        ], 500);
                    }
                }
            };

            // Menambah id_tema pada database berdasarkan id_tema baru di data form
            foreach (json_decode($data['id_tema'], true) as $id_temaForm) {
                if (!in_array($id_temaForm, $destinasiDatabase['id_tema'])) {
                    // Prepare parameterized stored insert tema destinasi
                    $storedInsertTema = "INSERT INTO tema_destinasi VALUES (0, ?, ?)";
                    $boundParamsTema = [
                        $data['id_destinasi'],
                        $id_temaForm
                    ];

                    try {
                        DB::statement($storedInsertTema, $boundParamsTema);
                    } catch (\Exception $e) {
                        return response() -> json([
                            'status' => false,
                            'message' => 'Gagal menambahkan tema destinasi. ' .$e. '', // User-friendly error message,
                            'data' => []
                        ], 500);
                    }
                }
            };

            // Menghapus hari_tutup pada database yang tidak ada di data form
            foreach ($destinasiDatabase['hari_tutup'] as $hari_tutupDatabase) {
                if (!in_array($hari_tutupDatabase, $data['hari_tutup'])) {
                    // Prepare parameterized stored delete
                    $storedQueryDelete = "DELETE FROM destinasi_tutup WHERE id_destinasi = ? AND hari_tutup = ?";
                    $boundParams = [
                        $data['id_destinasi'],
                        $hari_tutupDatabase
                    ];

                    // Execute stored query update using try-catch block
                    try {
                        DB::statement($storedQueryDelete, $boundParams);
                    } catch (\Exception $e) {
                        return response() -> json([
                            'status' => false,
                            'message' => 'Gagal menghapus hari tutup Destinasi. Message: ' .$e. '', // User-friendly error message,
                            'data' => []
                        ], 500);
                    }
                }
            };

            // Menambah hari_tutup pada database berdasarkan hari_tutup baru di data form
            foreach (json_decode($data['hari_tutup'], true) as $hari_tutupForm) {
                if (!in_array($hari_tutupForm, $destinasiDatabase['hari_tutup'])) {
                    // Prepare parameterized stored insert destinasi tutup
                    $storedInsertTutup = "INSERT INTO destinasi_tutup VALUES (0, ?, ?)";
                    $boundParamsTutup = [
                        $data['id_destinasi'],
                        $hari_tutupForm
                    ];

                    try {
                        DB::statement($storedInsertTutup, $boundParamsTutup);
                    } catch (\Exception $e) {
                        return response() -> json([
                            'status' => false,
                            'message' => 'Gagal menambahkan hari tutup destinasi. ' .$e. '', // User-friendly error message,
                            'data' => []
                        ], 500);
                    }
                }
            };

            return response() -> json([
                'status' => true,
                'message' => 'Update Destinasi by Id ' . $data['id_destinasi'] . ' Successfully.',
                'data' => $data
            ], 200); // Mengembalikan respons JSON
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request)
    {
        // Dapatkan id_destinasi dari request
        $id_destinasi = $request->input('id_destinasi');

        // Mencari data destinasi berdasarkan id_destinasi
        $destinasi = Destinasi::where('id_destinasi', $id_destinasi) -> get() -> first();
        $old_foto = $destinasi -> foto;

        // Hapus tema destinasi. Prepare parameterized stored delete
        $queryTema = "DELETE FROM tema_destinasi WHERE id_destinasi = ?";
        $paramTema = [
            $id_destinasi
        ];
        // Execute stored query update using try-catch block
        try {
            DB::statement($queryTema, $paramTema);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal menghapus tema Destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }

        // Hapus destinasi tutup. Prepare parameterized stored delete
        $queryTutup = "DELETE FROM destinasi_tutup WHERE id_destinasi = ?";
        $paramTutup = [
            $id_destinasi
        ];
        // Execute stored query update using try-catch block
        try {
            DB::statement($queryTutup, $paramTutup);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal menghapus hari tutup Destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }

        // Hapus destinasi
        $queryDestinasi = "DELETE FROM destinasi WHERE id_destinasi = ?";
        $paramDestinasi = [
            $id_destinasi
        ];
        // Execute stored query update using try-catch block
        try {
            DB::statement($queryDestinasi, $paramDestinasi);
        } catch (\Exception $e) {
            return response() -> json([
                'status' => false,
                'message' => 'Gagal menghapus hari Destinasi. Message: ' .$e. '', // User-friendly error message,
                'data' => []
            ], 500);
        }

        // delete old image
        if ($destinasi -> foto) {
            //delete old image
            File::delete(public_path() ."/storage/destinasi/".$old_foto);
        }

        return response() -> json([
            'status' => true,
            'message' => 'Jadwal Destinasi Berhasil Dihapus.',
            'data' => $id_destinasi
        ], 200);
    }
}
