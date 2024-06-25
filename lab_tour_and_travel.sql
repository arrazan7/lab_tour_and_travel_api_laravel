-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 24, 2024 at 01:11 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lab_tour_and_travel`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_jadwal_destinasi` (IN `proce_id_paketdestinasi` INT, IN `proce_hari_ke` INT, IN `proce_destinasi_ke` INT)   BEGIN
	IF proce_destinasi_ke = 1 THEN
		DELETE FROM jadwal_destinasi
		WHERE id_paketdestinasi = proce_id_paketdestinasi AND 
		hari_ke = proce_hari_ke AND destinasi_ke = 1;
        UPDATE jadwal_destinasi SET jarak_tempuh = 0, waktu_tempuh = 0, waktu_sebenarnya = 0
		WHERE id_paketdestinasi = proce_id_paketdestinasi AND 
		hari_ke = proce_hari_ke AND destinasi_ke = 2;
	ELSE
		DELETE FROM jadwal_destinasi
		WHERE id_paketdestinasi = proce_id_paketdestinasi AND 
		hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke;
    END IF;
	
    UPDATE jadwal_destinasi SET destinasi_ke = destinasi_ke - 1 
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke > proce_destinasi_ke;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_tema_destinasi` ()   BEGIN
    DECLARE id_destinasi INT DEFAULT 12;

    WHILE id_destinasi <= 207 DO
        -- 3 rows
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 1);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 11);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 5);
        SET id_destinasi = id_destinasi + 1;

        -- 4 rows
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 2);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 10);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 6);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 7);
        SET id_destinasi = id_destinasi + 1;

        -- 3 rows
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 14);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 3);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 13);
        SET id_destinasi = id_destinasi + 1;

        -- 4 rows
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 8);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 4);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 12);
        INSERT INTO tema_destinasi VALUES (0, id_destinasi, 9);
        SET id_destinasi = id_destinasi + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `jadwal_destinasi` (IN `id_paketdestinasi` INT, IN `hari` VARCHAR(20), IN `koordinat_berangkat` VARCHAR(100), IN `koordinat_tiba` VARCHAR(100), IN `jarak_tempuh` DOUBLE, IN `waktu_tempuh` INT, IN `id_destinasi` INT, IN `jam_mulai` TIME, IN `jam_selesai` TIME, IN `jam_lokasi` CHAR(5), IN `catatan` TEXT)   BEGIN
    INSERT INTO jadwal_destinasi
    VALUES (0, id_paketdestinasi, hari, 0, 0, koordinat_berangkat, koordinat_tiba, jarak_tempuh, waktu_tempuh, 0, 
    id_destinasi, jam_mulai, jam_selesai, jam_lokasi, catatan);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `paket_destinasi` (IN `id_profile` INT, IN `nama_paket` VARCHAR(30), IN `foto` VARCHAR(200))   BEGIN
    INSERT INTO paket_destinasi
    VALUES (0, id_profile, nama_paket, 0, 0, 0, 0, foto, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_jam_mulai` (IN `proce_id_paketdestinasi` INT, IN `proce_hari_ke` INT, IN `proce_destinasi_ke` INT, IN `proce_jam_mulai` TIME)   BEGIN
    DECLARE old_jam_mulai TIME;
    DECLARE perubahan_jam_mulai INT;
    DECLARE jam_selesai_sebelumnya INT;
    
	-- Saat jam_mulai berubah, maka jam_selesai destinasi sebelumnya akan berpengaruh maju ataupun mundur 
    -- tergantung seberapa banyak perubahan menit jam_mulainya.
    SET old_jam_mulai = (SELECT jam_mulai FROM jadwal_destinasi 
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke);
    
    UPDATE jadwal_destinasi SET jam_mulai = proce_jam_mulai
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke;
    IF proce_destinasi_ke != 1 THEN
		SET perubahan_jam_mulai = TIME_TO_SEC(TIMEDIFF(proce_jam_mulai, old_jam_mulai));
		SET jam_selesai_sebelumnya = (SELECT TIME_TO_SEC(jam_selesai) FROM jadwal_destinasi
		WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke - 1);
		UPDATE jadwal_destinasi SET jam_selesai = SEC_TO_TIME(jam_selesai_sebelumnya + perubahan_jam_mulai)
		WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke - 1;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_jam_selesai` (IN `proce_id_paketdestinasi` INT, IN `proce_hari_ke` INT, IN `proce_destinasi_ke` INT, IN `proce_jam_selesai` TIME)   BEGIN
	DECLARE last_destinasi_ke INT;
    DECLARE old_jam_selesai TIME;
    DECLARE perubahan_jam_selesai INT;
    DECLARE jam_mulai_setelahnya INT;
    
    SET last_destinasi_ke = (SELECT MAX(destinasi_ke) FROM jadwal_destinasi 
    WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke ORDER BY hari_ke);
    SET old_jam_selesai = (SELECT jam_selesai FROM jadwal_destinasi 
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke);
    
    -- Saat jam_selesai berubah, maka jam_mulai destinasi setelahnya akan berpengaruh maju ataupun mundur 
    -- tergantung seberapa banyak perubahan menit jam_selesainya.
    IF proce_destinasi_ke != last_destinasi_ke THEN
		SET perubahan_jam_selesai = TIME_TO_SEC(TIMEDIFF(proce_jam_selesai, old_jam_selesai));
		SET jam_mulai_setelahnya = (SELECT TIME_TO_SEC(jam_mulai) FROM jadwal_destinasi
		WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke + 1);
		UPDATE jadwal_destinasi SET jam_mulai = SEC_TO_TIME(jam_mulai_setelahnya + perubahan_jam_selesai)
		WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke + 1;
    END IF;
    UPDATE jadwal_destinasi SET jam_selesai = proce_jam_selesai
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_waktu_tempuh` (IN `proce_id_paketdestinasi` INT, IN `proce_hari_ke` INT, IN `proce_destinasi_ke` INT, IN `proce_waktu_tempuh` TIME)   BEGIN
	DECLARE hitung_waktu_sebenarnya INT DEFAULT 0;
    DECLARE old_waktu_sebenarnya INT;
    DECLARE old_jam_mulai TIME;
    DECLARE perubahan_waktu_sebenarnya INT;
    
	-- Menghitung lagi waktu_sebenarnya akibat dari perubahan waktu_tempuh.
    -- Mengotomatiskan nilai waktu_sebenarnya
    UPDATE jadwal_destinasi SET waktu_tempuh = proce_waktu_tempuh
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke;
	SET hitung_waktu_sebenarnya = proce_waktu_tempuh;
	IF (hitung_waktu_sebenarnya % 10) < 5 AND (hitung_waktu_sebenarnya % 10) != 0 THEN
		SET hitung_waktu_sebenarnya = hitung_waktu_sebenarnya + (5 - (hitung_waktu_sebenarnya % 10)); -- Membulatkan ke atas jika digit terakhir < 5
	END IF;
	IF (hitung_waktu_sebenarnya % 10) > 5 THEN
		SET hitung_waktu_sebenarnya = hitung_waktu_sebenarnya + (10 - (hitung_waktu_sebenarnya % 10)); -- Membulatkan ke puluhan jika digit terakhir > 5
	END IF;
    
    SET old_waktu_sebenarnya = (SELECT waktu_sebenarnya FROM jadwal_destinasi 
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke);
    SET old_jam_mulai = (SELECT jam_mulai FROM jadwal_destinasi 
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke);
    SET perubahan_waktu_sebenarnya = hitung_waktu_sebenarnya - old_waktu_sebenarnya;
    UPDATE jadwal_destinasi SET waktu_sebenarnya = hitung_waktu_sebenarnya
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke;
    UPDATE jadwal_destinasi SET jam_mulai = SEC_TO_TIME(TIME_TO_SEC(old_jam_mulai) + (perubahan_waktu_sebenarnya * 60))
	WHERE id_paketdestinasi = proce_id_paketdestinasi AND hari_ke = proce_hari_ke AND destinasi_ke = proce_destinasi_ke;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `destinasi`
--

CREATE TABLE `destinasi` (
  `id_destinasi` int(11) NOT NULL,
  `nama_destinasi` varchar(100) NOT NULL,
  `jenis` varchar(10) DEFAULT NULL CHECK (`jenis` in ('wisata','resto')),
  `kota` varchar(30) NOT NULL,
  `jam_buka` time NOT NULL,
  `jam_tutup` time NOT NULL,
  `jam_lokasi` char(5) DEFAULT NULL CHECK (`jam_lokasi` in ('WIB','WITA','WIT')),
  `harga_wni` int(11) NOT NULL,
  `harga_wna` int(11) NOT NULL,
  `foto` varchar(200) DEFAULT NULL,
  `koordinat` varchar(100) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL,
  `rating` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `destinasi`
--

INSERT INTO `destinasi` (`id_destinasi`, `nama_destinasi`, `jenis`, `kota`, `jam_buka`, `jam_tutup`, `jam_lokasi`, `harga_wni`, `harga_wna`, `foto`, `koordinat`, `deskripsi`, `rating`) VALUES
(1, 'Pasar Kotagede', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 25000, 25000, '66789391789781719178129.jpeg', '', '', 10),
(2, 'Slasar Malioboro', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 30000, 30000, '667893ab33b771719178155.jpg', '', '', 10),
(3, 'Pasar Kranggan', 'wisata', 'Yogyakarta', '05:00:00', '18:00:00', 'WIB', 5000, 5000, '6678958b72dfc1719178635.jpg', '', '', 10),
(4, 'Masjid Soko Tunggal', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678960d135fb1719178765.jpg', '', '', 10),
(5, 'Masjid Gedhe Kauman', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '667895f5714601719178741.jpg', '', '', 10),
(6, 'Vihara Buddha Prabha/Fuk Ling Miau Temple', 'wisata', 'Yogyakarta', '09:00:00', '17:00:00', 'WIB', 5000, 5000, '667895e7e286c1719178727.jpeg', '', '', 10),
(7, 'Klenteng Poncowinatan/Tjen Ling Kiong', 'wisata', 'Yogyakarta', '08:00:00', '16:00:00', 'WIB', 5000, 5000, '667895d8e5f4e1719178712.jpg', '', '', 10),
(8, 'Candi Donotirto', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '667895c8eb3211719178696.jpg', '', '', 10),
(9, 'Sasana Wiratama', 'wisata', 'Yogyakarta', '08:00:00', '14:00:00', 'WIB', 5000, 5000, '667895b1d65cc1719178673.jpeg', '', '', 10),
(10, 'Museum Sri Sultan Hamengkubuwono IX', 'wisata', 'Yogyakarta', '08:30:00', '15:00:00', 'WIB', 7000, 7000, '667895a2bb9cd1719178658.jpg', '', '', 10),
(11, 'Museum Gembira Loka Zoo', 'wisata', 'Yogyakarta', '07:30:00', '17:30:00', 'WIB', 30000, 30000, '667896392b88c1719178809.jpg', '', '', 10),
(12, 'Museum Pusat TNI AD Dharma Wiratama', 'wisata', 'Yogyakarta', '08:00:00', '15:00:00', 'WIB', 5000, 5000, '6678965c322751719178844.jpeg', '', '', 10),
(13, 'Museum Dewantara Kirti Griya', 'wisata', 'Yogyakarta', '08:00:00', '13:00:00', 'WIB', 5000, 5000, '6678966b0d9b91719178859.png', '', '', 10),
(14, 'Museum Sasmitaloka Panglima Besar Jenderal Sudirman', 'wisata', 'Yogyakarta', '08:00:00', '15:00:00', 'WIB', 5000, 5000, '6678967b0a7041719178875.jpg', '', '', 10),
(15, 'Museum Biologi UGM', 'wisata', 'Yogyakarta', '08:00:00', '16:00:00', 'WIB', 5000, 5000, '6678968926d731719178889.jpg', '', '', 10),
(16, 'Museum Dr. Yap Prawirohusodo', 'wisata', 'Yogyakarta', '09:00:00', '14:30:00', 'WIB', 5000, 5000, '667896c7549c81719178951.jpg', '', '', 10),
(17, 'Museum Kereta Keraton Yogyakarta', 'wisata', 'Yogyakarta', '09:00:00', '16:00:00', 'WIB', 5000, 5000, '667896b8d327d1719178936.jpg', '', '', 10),
(18, 'Museum Monumen Pangeran Diponegoro Sasana Wiratama', 'wisata', 'Yogyakarta', '08:00:00', '14:00:00', 'WIB', 5000, 5000, '667896aa474791719178922.png', '', '', 10),
(19, 'Museum Perjuangan', 'wisata', 'Yogyakarta', '07:30:00', '16:00:00', 'WIB', 5000, 5000, '66789b952e2f61719180181.jpeg', '', '', 10),
(20, 'Kampung Wisata Rejowinangun', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '66789bc4d5da81719180228.jpg', '', '', 10),
(21, 'Kampung Wisata Pandeyan', 'wisata', 'Yogyakarta', '08:00:00', '22:00:00', 'WIB', 5000, 5000, '66789bd3d554a1719180243.jpg', '', '', 10),
(22, 'Kampung Ketandan', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '66789be191c211719180257.png', '', '', 10),
(23, 'Kampoeng Cyber Yogyakarta', 'wisata', 'Yogyakarta', '09:00:00', '17:00:00', 'WIB', 5000, 5000, '66789bf049a221719180272.jpeg', '', '', 10),
(24, 'Sasono Hinggil Dwi Abad', 'wisata', 'Yogyakarta', '09:00:00', '17:00:00', 'WIB', 5000, 5000, '66789bfd7453d1719180285.jpg', '', '', 10),
(25, 'Pura Pakualaman', 'wisata', 'Yogyakarta', '08:00:00', '15:00:00', 'WIB', 5000, 5000, '66789c0ac6e871719180298.png', '', '', 10),
(26, 'Situs Warungboto', 'wisata', 'Yogyakarta', '08:00:00', '17:00:00', 'WIB', 5000, 5000, '66789c1acb16f1719180314.jpg', '', '', 10),
(27, 'Plengkung Gading', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '66789c281cce91719180328.jpg', '', '', 10),
(28, 'Pasar Klithikan Pakuncen', 'wisata', 'Yogyakarta', '10:00:00', '22:00:00', 'WIB', 5000, 5000, '66789c359b2f61719180341.jpeg', '', '', 10),
(29, 'Museum Sonobudoyo', 'wisata', 'Yogyakarta', '08:00:00', '16:00:00', 'WIB', 5000, 5000, '66789c431417c1719180355.jpg', '', '', 10),
(30, 'Jogja National Museum', 'wisata', 'Yogyakarta', '09:00:00', '16:30:00', 'WIB', 50000, 50000, '66789c52ba1041719180370.jpg', '', '', 10),
(31, 'Kampung Wisata Sosromenduran', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '66789c88202c71719180424.jpg', '', '', 10),
(32, 'Masjid Jogokariyan', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '66789c94adc831719180436.jpg', '', '', 10),
(33, 'Mandira Baruga (Ramayana Ballet Purawisata)', 'wisata', 'Yogyakarta', '14:00:00', '23:00:00', 'WIB', 45000, 45000, '66789ca2c75461719180450.jpg', '', '', 10),
(34, 'Embung Langensari', 'wisata', 'Yogyakarta', '07:00:00', '18:00:00', 'WIB', 5000, 5000, '66789cbeb93e31719180478.jpeg', '', '', 10),
(35, 'Omah UGM', 'wisata', 'Yogyakarta', '09:00:00', '17:00:00', 'WIB', 5000, 5000, '66789ccb4a6e51719180491.jpg', '', '', 10),
(36, 'Museum Sandi (Indonesian Cryptology Museum)', 'wisata', 'Yogyakarta', '09:00:00', '15:00:00', 'WIB', 5000, 5000, '66789cd8192351719180504.jpg', '', '', 10),
(37, 'Selfie Park Taman Pule', 'wisata', 'Yogyakarta', '09:00:00', '16:30:00', 'WIB', 10000, 10000, '66789ce40499e1719180516.png', '', '', 10),
(38, 'Museum Benteng Vredeburg', 'wisata', 'Yogyakarta', '07:30:00', '16:00:00', 'WIB', 10000, 10000, '66789cf11cd0b1719180529.jpg', '', '', 10),
(39, 'Taman Sari', 'wisata', 'Yogyakarta', '09:00:00', '15:00:00', 'WIB', 10000, 10000, '66789cff2aba91719180543.jpg', '', '', 10),
(40, 'Titik Nol Km Jogja', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 10000, 10000, '66789d0e2e33d1719180558.jpg', '', '', 10),
(41, 'Taman Pintar', 'wisata', 'Yogyakarta', '08:30:00', '16:00:00', 'WIB', 30000, 30000, '66789d1d68fcf1719180573.jpg', '', '', 10),
(42, 'Kerajinan Perak Kota Gede', 'wisata', 'Yogyakarta', '08:00:00', '16:00:00', 'WIB', 10000, 10000, '66789d2a0b8f91719180586.jpg', '', '', 10),
(43, 'Tugu Jogja', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 10000, 10000, '66789d3654af81719180598.jpg', '', '', 10),
(44, 'Alun-Alun Selatan', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '66789d78c2c461719180664.jpeg', '', '', 10),
(45, 'Malioboro', 'wisata', 'Yogyakarta', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '66789d8564c221719180677.jpg', '', '', 10),
(46, 'Kebun Binatang Gembira Loka', 'wisata', 'Yogyakarta', '08:45:00', '17:30:00', 'WIB', 80000, 80000, '66789d927ef881719180690.jpg', '', '', 10),
(47, 'Pasar Beringharjo', 'wisata', 'Yogyakarta', '08:30:00', '21:00:00', 'WIB', 5000, 5000, '66789da0444e71719180704.jpg', '', '', 10),
(48, 'Keraton Yogyakarta', 'wisata', 'Yogyakarta', '11:00:00', '17:00:00', 'WIB', 10000, 10000, '66789dac51abb1719180716.jpg', '', '', 10),
(49, 'Gardu Pandang Merapi', 'wisata', 'Sleman', '07:00:00', '17:00:00', 'WIB', 10000, 10000, '66789dba9f8e91719180730.jpg', '', '', 10),
(50, 'Wisata Lava Merapi dan Batu Alien', 'wisata', 'Sleman', '00:00:00', '24:00:00', 'WIB', 10000, 10000, '66789dc6a8dc71719180742.jpg', '', '', 10),
(51, 'Taman Lampion Kaliurang', 'wisata', 'Sleman', '17:00:00', '22:00:00', 'WIB', 30000, 30000, '66789dd274ec81719180754.jpg', '', '', 10),
(52, 'Omah Petroek', 'wisata', 'Sleman', '10:00:00', '19:00:00', 'WIB', 5000, 5000, '66789ddebb9551719180766.jpg', '', '', 10),
(53, 'Pasar Tradisi Majapahit', 'wisata', 'Sleman', '07:00:00', '13:00:00', 'WIB', 20000, 20000, '66789deea33181719180782.jpeg', '', '', 10),
(54, 'Ledok Sambi', 'wisata', 'Sleman', '09:00:00', '17:00:00', 'WIB', 50000, 50000, '66789dfd940df1719180797.jpg', '', '', 10),
(55, 'Desa Ekowisata Pancoh', 'wisata', 'Sleman', '08:00:00', '20:00:00', 'WIB', 15000, 15000, '66789e0a001c81719180810.jpg', '', '', 10),
(56, 'Desa Wisata Pulesari', 'wisata', 'Sleman', '07:00:00', '18:00:00', 'WIB', 60000, 60000, '66789e17044af1719180823.jpg', '', '', 10),
(57, 'Desa Wisata Kembangarum', 'wisata', 'Sleman', '08:00:00', '16:00:00', 'WIB', 25000, 25000, '66789e24455481719180836.jpg', '', '', 10),
(58, 'Desa Wisata Pentingsari', 'wisata', 'Sleman', '00:00:00', '24:00:00', 'WIB', 50000, 50000, '66789e309edca1719180848.jpg', '', '', 10),
(59, 'Puri Mataram', 'wisata', 'Sleman', '08:00:00', '21:00:00', 'WIB', 35000, 35000, '66789e3d2f2131719180861.jpeg', '', '', 10),
(60, 'Tlogo Putri Kaliurang', 'wisata', 'Sleman', '07:00:00', '16:00:00', 'WIB', 10000, 10000, '66789e49185301719180873.jpg', '', '', 10),
(61, 'Jogja Exotarium', 'wisata', 'Sleman', '08:30:00', '16:00:00', 'WIB', 50000, 50000, '66789e671cf971719180903.jpg', '', '', 10),
(62, 'Grojogan Watu Purbo', 'wisata', 'Sleman', '07:00:00', '17:00:00', 'WIB', 5000, 5000, '66789e733358b1719180915.jpg', '', '', 10),
(63, 'Tlogo Muncar', 'wisata', 'Sleman', '09:00:00', '15:00:00', 'WIB', 10000, 10000, '66789e8036fc21719180928.jpg', '', '', 10),
(64, 'Trans Studio Mini Maguwo', 'wisata', 'Sleman', '10:00:00', '20:00:00', 'WIB', 110000, 110000, '66789e8f9277c1719180943.jpg', '', '', 10),
(65, 'Desa Wisata Rumah Domes/Teletubbies', 'wisata', 'Sleman', '07:00:00', '17:00:00', 'WIB', 5000, 5000, '66789e9c915171719180956.jpg', '', '', 10),
(66, 'Goa Jepang', 'wisata', 'Sleman', '08:00:00', '17:00:00', 'WIB', 5000, 5000, '66789eaf261a31719180975.png', '', '', 10),
(67, 'Plunyon Kalikuning', 'wisata', 'Sleman', '07:00:00', '16:00:00', 'WIB', 10000, 10000, '66789ec7d2bf51719180999.jpg', '', '', 10),
(68, 'Ramayana Ballet Prambanan', 'wisata', 'Sleman', '19:30:00', '21:00:00', 'WIB', 150000, 150000, '6678a4abbfac91719182507.jpeg', '', '', 10),
(69, 'Desa Wisata Kaliurang Timur', 'wisata', 'Sleman', '00:00:00', '24:00:00', 'WIB', 20000, 20000, '6678a4b7f1b3c1719182519.jpg', '', '', 10),
(70, 'Candi Sari', 'wisata', 'Sleman', '08:00:00', '15:00:00', 'WIB', 5000, 5000, '6678a4c5147c91719182533.jpg', '', '', 10),
(71, 'Candi Kalasan', 'wisata', 'Sleman', '07:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a4d2102d91719182546.jpg', '', '', 10),
(72, 'Spot Riyadi', 'wisata', 'Sleman', '06:00:00', '20:00:00', 'WIB', 5000, 5000, '6678a4df96e281719182559.jpg', '', '', 10),
(73, 'Sindu Kusuma Edupark (SKE)', 'wisata', 'Sleman', '09:00:00', '17:00:00', 'WIB', 40000, 40000, '6678a4ef576871719182575.jpeg', '', '', 10),
(74, 'Green Kayen', 'wisata', 'Sleman', '00:00:00', '24:00:00', 'WIB', 10000, 10000, '6678a4fc7aa4d1719182588.jpg', '', '', 10),
(75, 'Blue Lagoon', 'wisata', 'Sleman', '08:00:00', '17:00:00', 'WIB', 10000, 10000, '6678a50a21e2f1719182602.jpg', '', '', 10),
(76, 'Omah Salak Sleman', 'wisata', 'Sleman', '08:00:00', '16:00:00', 'WIB', 10000, 10000, '6678a516686541719182614.jpeg', '', '', 10),
(77, 'Candi Abang', 'wisata', 'Sleman', '07:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a5234ddb11719182627.jpg', '', '', 10),
(78, 'Candi Sambisari', 'wisata', 'Sleman', '07:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a5302f1fd1719182640.jpg', '', '', 10),
(79, 'Hobbit House', 'wisata', 'Sleman', '06:00:00', '18:00:00', 'WIB', 10000, 10000, '6678a53f184dc1719182655.jpeg', '', '', 10),
(80, 'Bunker Kaliadem', 'wisata', 'Sleman', '00:00:00', '24:00:00', 'WIB', 10000, 10000, '6678a54b6d6891719182667.png', '', '', 10),
(81, 'Stonehenge', 'wisata', 'Sleman', '07:30:00', '18:00:00', 'WIB', 15000, 15000, '6678a557a65211719182679.jpg', '', '', 10),
(82, 'Agrowisata Bhumi Merapi', 'wisata', 'Sleman', '09:00:00', '17:00:00', 'WIB', 30000, 30000, '6678a5646db321719182692.jpg', '', '', 10),
(83, 'Museum Gunungapi Merapi', 'wisata', 'Sleman', '08:00:00', '14:00:00', 'WIB', 5000, 5000, '6678a570e49f81719182704.jpg', '', '', 10),
(84, 'Kalikuning Park', 'wisata', 'Sleman', '08:00:00', '17:00:00', 'WIB', 15000, 15000, '6678a57cd358a1719182716.jpg', '', '', 10),
(85, 'Studio Alam Gamplong', 'wisata', 'Sleman', '09:00:00', '17:00:00', 'WIB', 10000, 10000, '6678a58996bb31719182729.png', '', '', 10),
(86, 'Taman Wisata Kaliurang', 'wisata', 'Sleman', '09:00:00', '16:00:00', 'WIB', 10000, 10000, '6678a68a791f61719182986.jpeg', '', '', 10),
(87, 'Candi Banyunibo', 'wisata', 'Sleman', '06:00:00', '17:30:00', 'WIB', 5000, 5000, '6678a698a30c51719183000.jpg', '', '', 10),
(88, 'The Lost World Castle', 'wisata', 'Sleman', '07:00:00', '18:00:00', 'WIB', 30000, 30000, '6678a6a5c55511719183013.jpg', '', '', 10),
(89, 'Volcano Tour Jeep Merapi', 'wisata', 'Sleman', '07:00:00', '16:00:00', 'WIB', 350000, 350000, '6678a6b41a18f1719183028.png', '', '', 10),
(90, 'Lava Bantal', 'wisata', 'Sleman', '09:00:00', '17:00:00', 'WIB', 15000, 15000, '6678a6c2569e41719183042.jpeg', '', '', 10),
(91, 'Candi Ratu Boko', 'wisata', 'Sleman', '06:00:00', '17:00:00', 'WIB', 50000, 50000, '6678a6ceca6601719183054.jpg', '', '', 10),
(92, 'Candi Ijo', 'wisata', 'Sleman', '06:00:00', '17:00:00', 'WIB', 10000, 10000, '6678a6db849e01719183067.png', '', '', 10),
(93, 'Tebing Breksi', 'wisata', 'Sleman', '10:00:00', '18:00:00', 'WIB', 20000, 20000, '6678a6e82afd51719183080.jpg', '', '', 10),
(94, 'Monumen Jogja Kembali', 'wisata', 'Sleman', '09:00:00', '12:00:00', 'WIB', 20000, 20000, '6678a6f4779201719183092.jpg', '', '', 10),
(95, 'Museum Ullen Sentalu', 'wisata', 'Sleman', '08:30:00', '15:00:00', 'WIB', 50000, 50000, '6678a703523141719183107.jpeg', '', '', 10),
(96, 'Merapi Park', 'wisata', 'Sleman', '09:00:00', '17:00:00', 'WIB', 30000, 30000, '6678a712cb1601719183122.jpg', '', '', 10),
(97, 'Taman Pelangi', 'wisata', 'Sleman', '17:00:00', '23:00:00', 'WIB', 20000, 20000, '6678a722114421719183138.jpg', '', '', 10),
(98, 'Bukit Klangon', 'wisata', 'Sleman', '07:00:00', '17:00:00', 'WIB', 10000, 10000, '6678a72e90f281719183150.jpg', '', '', 10),
(99, 'Museum Affandi', 'wisata', 'Sleman', '09:00:00', '16:00:00', 'WIB', 25000, 25000, '6678a73ab0cab1719183162.jpg', '', '', 10),
(100, 'Candi Prambanan', 'wisata', 'Sleman', '08:00:00', '17:00:00', 'WIB', 60000, 60000, '6678a747525251719183175.jpg', '', '', 10),
(101, 'Jogja Bay Waterpark', 'wisata', 'Sleman', '09:00:00', '16:00:00', 'WIB', 100000, 100000, '6678a791e41101719183249.jpeg', '', '', 10),
(102, 'Taman Bunga Matahari', 'wisata', 'Bantul', '08:00:00', '16:00:00', 'WIB', 60000, 60000, '6678a79ef03541719183262.jpg', '', '', 10),
(103, 'Taman Batu Kapal', 'wisata', 'Bantul', '06:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a7ab5588a1719183275.jpg', '', '', 10),
(104, 'Wisata Kebun Buah Naga Wonoroto', 'wisata', 'Bantul', '09:00:00', '16:00:00', 'WIB', 15000, 15000, '6678a7b8753251719183288.png', '', '', 10),
(105, 'Kampung Edukasi Watu Lumbung', 'wisata', 'Bantul', '08:00:00', '23:00:00', 'WIB', 5000, 5000, '6678a7c4cd47f1719183300.jpg', '', '', 10),
(106, 'Gunung Mungker', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a7d1bada81719183313.jpg', '', '', 10),
(107, 'Taman Puspa Gading Tegaldowo', 'wisata', 'Bantul', '08:00:00', '18:00:00', 'WIB', 10000, 10000, '6678a7ddedae01719183325.jpg', '', '', 10),
(108, 'Embung Potorono', 'wisata', 'Bantul', '09:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a7ea6ca0d1719183338.jpg', '', '', 10),
(109, 'Galaxy Waterpark Jogja', 'wisata', 'Bantul', '09:00:00', '17:00:00', 'WIB', 20000, 20000, '6678a7f7845fb1719183351.jpg', '', '', 10),
(110, 'Taman Bunga Asri', 'wisata', 'Bantul', '08:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a805d8c281719183365.jpg', '', '', 10),
(111, 'Puncak Sosok Bawuran', 'wisata', 'Bantul', '15:00:00', '23:00:00', 'WIB', 5000, 5000, '6678a81200b841719183378.jpeg', '', '', 10),
(112, 'Watu Lawang', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a81e32cc01719183390.jpg', '', '', 10),
(113, 'Pantai Depok', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 10000, 10000, '6678a82e586441719183406.jpg', '', '', 10),
(114, 'Puncak Bucu', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a83c492741719183420.jpg', '', '', 10),
(115, 'Puncak Gebang', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a8493c0f11719183433.jpg', '', '', 10),
(116, 'Makam Raja Imogiri', 'wisata', 'Bantul', '10:00:00', '13:00:00', 'WIB', 10000, 10000, '6678a85c123d41719183452.jpg', '', '', 10),
(117, 'Pantai Baros', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 10000, 10000, '6678a86a45e501719183466.jpg', '', '', 10),
(118, 'Pantai Baru', 'wisata', 'Bantul', '06:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a876a70591719183478.jpg', '', '', 10),
(119, 'Grojogan Pucung', 'wisata', 'Bantul', '08:00:00', '16:00:00', 'WIB', 5000, 5000, '6678a8845fb611719183492.jpg', '', '', 10),
(120, 'Curug Banyunibo', 'wisata', 'Bantul', '08:00:00', '16:00:00', 'WIB', 5000, 5000, '6678a890db47e1719183504.jpeg', '', '', 10),
(121, 'Air Terjun Tuwondo', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a8c11939d1719183553.jpg', '', '', 10),
(122, 'Taman Tino Sidin', 'wisata', 'Bantul', '09:00:00', '15:00:00', 'WIB', 5000, 5000, '6678a8cced09b1719183564.jpg', '', '', 10),
(123, 'Pintu Langit Dahromo', 'wisata', 'Bantul', '08:00:00', '22:00:00', 'WIB', 5000, 5000, '6678a8d96d9261719183577.jpg', '', '', 10),
(124, 'Museum Pusat TNI AU Dirgantara Mandala', 'wisata', 'Bantul', '08:00:00', '16:00:00', 'WIB', 7000, 7000, '6678a8e54cb2b1719183589.jpg', '', '', 10),
(125, 'Pantai Pandansimo', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a8f29506e1719183602.jpg', '', '', 10),
(126, 'Desa Wisata Tembi', 'wisata', 'Bantul', '08:00:00', '20:00:00', 'WIB', 50000, 50000, '6678a8ffa12541719183615.jpeg', '', '', 10),
(127, 'Pasar Seni Gabusan', 'wisata', 'Bantul', '09:00:00', '19:00:00', 'WIB', 10000, 10000, '6678a90bd72781719183627.jpg', '', '', 10),
(128, 'Tirta Tamansari Waterbyur', 'wisata', 'Bantul', '07:00:00', '16:00:00', 'WIB', 10000, 10000, '6678a91777fa01719183639.jpg', '', '', 10),
(129, 'Kedung Pengilon', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a923508e51719183651.jpg', '', '', 10),
(130, 'Bukit Bego Imogiri', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a92f2f5ef1719183663.jpg', '', '', 10),
(131, 'Pemandian Air Panas Parang Wedang', 'wisata', 'Bantul', '07:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a9556ca921719183701.jpg', '', '', 10),
(132, 'Curug Pulosari', 'wisata', 'Bantul', '08:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a964c13e41719183716.jpg', '', '', 10),
(133, 'Watu Goyang', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a97cd0c391719183740.png', '', '', 10),
(134, 'Tebing Watu Mabur', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a98b126191719183755.jpg', '', '', 10),
(135, 'Pantai Samas', 'wisata', 'Bantul', '07:00:00', '17:00:00', 'WIB', 5000, 5000, '66789f4cf17f81719181132.jpeg', '', '', 10),
(136, 'Pantai Pandansari', 'wisata', 'Bantul', '06:00:00', '17:00:00', 'WIB', 5000, 5000, '66789f5b038aa1719181147.jpg', '', '', 10),
(137, 'Pantai Kuwaru', 'wisata', 'Bantul', '05:00:00', '18:00:00', 'WIB', 5000, 5000, '66789f687bb4c1719181160.jpg', '', '', 10),
(138, 'Kampung Batik Giriloyo', 'wisata', 'Bantul', '08:00:00', '16:00:00', 'WIB', 200000, 200000, '66789f75573db1719181173.jpg', '', '', 10),
(139, 'Goa Selarong', 'wisata', 'Bantul', '08:00:00', '17:00:00', 'WIB', 5000, 5000, '66789f83994ed1719181187.jpg', '', '', 10),
(140, 'Goa Cerme', 'wisata', 'Bantul', '07:00:00', '18:00:00', 'WIB', 5000, 5000, '66789f93521ac1719181203.jpeg', '', '', 10),
(141, 'Balong Waterpark', 'wisata', 'Bantul', '09:00:00', '16:30:00', 'WIB', 15000, 15000, '66789fa147e8d1719181217.jpg', '', '', 10),
(142, 'Air Terjun Randusari', 'wisata', 'Bantul', '05:30:00', '18:00:00', 'WIB', 5000, 5000, '66789faedcc3e1719181230.jpg', '', '', 10),
(143, 'Karst Tubing Sedayu', 'wisata', 'Bantul', '08:00:00', '17:00:00', 'WIB', 40000, 40000, '66789fbc87ec31719181244.jpeg', '', '', 10),
(144, 'Bukit Mojo Gumelem', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 20000, 20000, '66789fc96cfee1719181257.jpg', '', '', 10),
(145, 'Pantai Goa Cemara', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '66789fd8cd4d11719181272.jpg', '', '', 10),
(146, 'Kids Fun', 'wisata', 'Bantul', '08:00:00', '18:00:00', 'WIB', 100000, 100000, '66789fe5dfbf81719181285.jpeg', '', '', 10),
(147, 'Hutan Pinus Pengger', 'wisata', 'Bantul', '08:00:00', '21:00:00', 'WIB', 10000, 10000, '66789ff2cb57a1719181298.png', '', '', 10),
(148, 'Air Terjun Lepo Dlingo', 'wisata', 'Bantul', '06:00:00', '17:00:00', 'WIB', 5000, 5000, '66789ffec78eb1719181310.jpg', '', '', 10),
(149, 'Jurang Tembelan Kanigoro', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a00c82dfd1719181324.jpg', '', '', 10),
(150, 'Bukit Lintang Sewu', 'wisata', 'Bantul', '08:00:00', '21:00:00', 'WIB', 10000, 10000, '6678a01a4c6741719181338.jpg', '', '', 10),
(151, 'Puncak Kebun Buah Mangunan', 'wisata', 'Bantul', '05:00:00', '17:00:00', 'WIB', 10000, 10000, '6678a028d5c9a1719181352.jpg', '', '', 10),
(152, 'Bukit Panguk Kediwung', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 15000, 15000, '6678a0354c3101719181365.png', '', '', 10),
(153, 'Pantai Parangtritis', 'wisata', 'Bantul', '00:00:00', '24:00:00', 'WIB', 20000, 20000, '6678a083044dd1719181443.jpeg', '', '', 10),
(154, 'Gumuk Pasir', 'wisata', 'Bantul', '07:00:00', '18:00:00', 'WIB', 10000, 10000, '6678a0914abbf1719181457.jpg', '', '', 10),
(155, 'Puncak Becici', 'wisata', 'Bantul', '08:00:00', '22:00:00', 'WIB', 10000, 10000, '6678a0aa7e2821719181482.jpg', '', '', 10),
(156, 'Seribu Batu Songgo Langit', 'wisata', 'Bantul', '06:00:00', '21:00:00', 'WIB', 10000, 10000, '6678a0b8d8c811719181496.png', '', '', 10),
(157, 'Hutan Pinus Mangunan', 'wisata', 'Bantul', '08:30:00', '17:00:00', 'WIB', 5000, 5000, '6678a0c67b9ef1719181510.jpeg', '', '', 10),
(158, 'Pantai Mlarangan Asri', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a0d51953b1719181525.jpg', '', '', 10),
(159, 'Goa Kidang Kencono', 'wisata', 'Kulon Progo', '08:00:00', '16:00:00', 'WIB', 5000, 5000, '6678a0e249d121719181538.png', '', '', 10),
(160, 'Pronosutan View', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a0ef49a711719181551.jpg', '', '', 10),
(161, 'Taman Bambu Air Waduk Sermo', 'wisata', 'Kulon Progo', '07:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a0fc2bc6e1719181564.jpg', '', '', 10),
(162, 'Kebun Bunga Matahari Pantai Glagah', 'wisata', 'Kulon Progo', '06:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a10adb01a1719181578.jpeg', '', '', 10),
(163, 'Puncak Kuda Sembrani', 'wisata', 'Kulon Progo', '06:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a116ee3691719181590.jpg', '', '', 10),
(164, 'Puncak Moyeng', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a123a07ba1719181603.jpg', '', '', 10),
(165, 'Wisata Gunung Kuniran', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a130a08ce1719181616.jpg', '', '', 10),
(166, 'Pantai Pasir Kadilangu', 'wisata', 'Kulon Progo', '06:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a13c68acb1719181628.jpg', '', '', 10),
(167, 'Arus Progo Rafting', 'wisata', 'Kulon Progo', '06:00:00', '18:00:00', 'WIB', 1000000, 1000000, '6678a1494f64e1719181641.jpg', '', '', 10),
(168, 'Mangrove Jembatan Api-Api (MJAA)', 'wisata', 'Kulon Progo', '06:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a15a38f3f1719181658.jpeg', '', '', 10),
(169, 'Puncak Bukit Cendana', 'wisata', 'Kulon Progo', '08:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a166106b41719181670.jpg', '', '', 10),
(170, 'Embung Bogor', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a172224841719181682.jpg', '', '', 10),
(171, 'Puncak Saka', 'wisata', 'Kulon Progo', '09:00:00', '22:00:00', 'WIB', 5000, 5000, '6678a1811f5ce1719181697.png', '', '', 10),
(172, 'Embung Banjaroya', 'wisata', 'Kulon Progo', '08:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a1903a8821719181712.jpg', '', '', 10),
(173, 'Curug Siluwok', 'wisata', 'Kulon Progo', '08:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a1e57533d1719181797.jpg', '', '', 10),
(174, 'Canting Mas Puncak Dipowono', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 12000, 12000, '6678a1f309c351719181811.jpg', '', '', 10),
(175, 'Bukit Isis', 'wisata', 'Kulon Progo', '06:00:00', '17:30:00', 'WIB', 5000, 5000, '6678a201102461719181825.jpg', '', '', 10),
(176, 'Alun-alun Wates (Alwa)', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a2170b0981719181847.jpg', '', '', 10),
(177, 'Taman Bendungan Kamijoro', 'wisata', 'Kulon Progo', '07:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a2242c0db1719181860.jpg', '', '', 10),
(178, 'Waduk Mini Kleco', 'wisata', 'Kulon Progo', '05:30:00', '19:00:00', 'WIB', 5000, 5000, '6678a231c0b2b1719181873.jpeg', '', '', 10),
(179, 'Gua Maria Lawangsih', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a23ead1641719181886.jpg', '', '', 10),
(180, 'Air Terjun Sidoharjo', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a24b4f1861719181899.jpg', '', '', 10),
(181, 'Gua Maria Sendangsono', 'wisata', 'Kulon Progo', '09:00:00', '21:00:00', 'WIB', 5000, 5000, '6678a258be5b41719181912.jpg', '', '', 10),
(182, 'Air Terjun Kedung Ingas', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a265eca601719181925.jpg', '', '', 10),
(183, 'Pemandian Clereng', 'wisata', 'Kulon Progo', '08:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a275e0b381719181941.jpg', '', '', 10),
(184, 'Pantai Trisik', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a2832f2ac1719181955.jpg', '', '', 10),
(185, 'Pantai Congot', 'wisata', 'Kulon Progo', '07:00:00', '17:00:00', 'WIB', 6000, 6000, '6678a290af5661719181968.jpg', '', '', 10),
(186, 'Wisata Alam Kedung Kemin & Kedung Luweng', 'wisata', 'Kulon Progo', '05:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a29d6e06e1719181981.jpg', '', '', 10),
(187, 'Wisata Alam Kedung Banteng', 'wisata', 'Kulon Progo', '08:00:00', '16:00:00', 'WIB', 5000, 5000, '6678a2aa935381719181994.jpeg', '', '', 10),
(188, 'Agrowisata Krisan Gerbosari', 'wisata', 'Kulon Progo', '08:00:00', '23:00:00', 'WIB', 5000, 5000, '6678a2b9ced581719182009.jpg', '', '', 10),
(189, 'Tebing Gunung Gajah', 'wisata', 'Kulon Progo', '09:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a2c73126c1719182023.jpg', '', '', 10),
(190, 'Goa Kiskendo', 'wisata', 'Kulon Progo', '09:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a2d4ce55c1719182036.jpg', '', '', 10),
(191, 'Goa Kebon Krembangan', 'wisata', 'Kulon Progo', '08:00:00', '17:00:00', 'WIB', 6000, 6000, '6678a2e2464be1719182050.jpg', '', '', 10),
(192, 'Bendungan Kayangan', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a2ef17e6e1719182063.jpg', '', '', 10),
(193, 'Ayunan Langit Watu Jaran kulonprogo', 'wisata', 'Kulon Progo', '09:00:00', '17:00:00', 'WIB', 10000, 10000, '6678a2fba3c701719182075.jpeg', '', '', 10),
(194, 'Pantai Bugel', 'wisata', 'Kulon Progo', '08:00:00', '17:00:00', 'WIB', 5000, 5000, '6678a307a9b531719182087.jpg', '', '', 10),
(195, 'Air Terjun Grojogan Sewu', 'wisata', 'Kulon Progo', '08:00:00', '16:00:00', 'WIB', 5000, 5000, '6678a314a91561719182100.jpg', '', '', 10),
(196, 'Puncak Suroloyo', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a34f94f501719182159.jpg', '', '', 10),
(197, 'Air Terjun Kembang Soka', 'wisata', 'Kulon Progo', '07:00:00', '17:00:00', 'WIB', 11000, 11000, '6678a35ccdf291719182172.jpg', '', '', 10),
(198, 'Kebun Teh Nglinggo', 'wisata', 'Kulon Progo', '07:00:00', '18:00:00', 'WIB', 6000, 6000, '6678a36d1cc0e1719182189.jpg', '', '', 10),
(199, 'Goa Sriti', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a37bb94eb1719182203.jpg', '', '', 10),
(200, 'Puncak Widosari', 'wisata', 'Kulon Progo', '05:00:00', '18:00:00', 'WIB', 5000, 5000, '6678a387efe8e1719182215.png', '', '', 10),
(201, 'Bukit Wisata Pulepayung', 'wisata', 'Kulon Progo', '15:00:00', '22:00:00', 'WIB', 20000, 20000, '6678a3944feb71719182228.jpg', '', '', 10),
(202, 'Hutan Mangrove Wanatirta', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 5000, 5000, '6678a3a3e534e1719182243.jpeg', '', '', 10),
(203, 'Sungai Mudal', 'wisata', 'Kulon Progo', '08:30:00', '15:15:00', 'WIB', 10000, 10000, '6678a3b105d291719182257.jpg', '', '', 10),
(204, 'Pantai Glagah', 'wisata', 'Kulon Progo', '00:00:00', '24:00:00', 'WIB', 20000, 20000, '6678a3bdd19d21719182269.jpg', '', '', 10),
(205, 'Waduk Sermo', 'wisata', 'Kulon Progo', '07:00:00', '17:00:00', 'WIB', 6000, 6000, '6678a3ca232221719182282.jpg', '', '', 10),
(206, 'Air Terjun Kedung Pedut', 'wisata', 'Kulon Progo', '07:00:00', '17:00:00', 'WIB', 11000, 11000, '6678a3d7afb421719182295.jpg', '', '', 10),
(207, 'Kalibiru', 'wisata', 'Kulon Progo', '08:00:00', '17:00:00', 'WIB', 15000, 15000, '6678a3e58ff531719182309.jpeg', '', '', 10);

-- --------------------------------------------------------

--
-- Table structure for table `destinasi_tutup`
--

CREATE TABLE `destinasi_tutup` (
  `id_destinasitutup` int(11) NOT NULL,
  `id_destinasi` int(11) NOT NULL,
  `hari_tutup` varchar(20) DEFAULT NULL CHECK (`hari_tutup` in ('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `destinasi_tutup`
--

INSERT INTO `destinasi_tutup` (`id_destinasitutup`, `id_destinasi`, `hari_tutup`) VALUES
(1, 1, 'Senin'),
(2, 2, 'Selasa'),
(3, 3, 'Rabu'),
(4, 4, 'Kamis'),
(5, 5, 'Jumat'),
(6, 6, 'Sabtu'),
(7, 7, 'Minggu'),
(8, 8, 'Senin'),
(9, 8, 'Selasa'),
(10, 9, 'Selasa'),
(11, 9, 'Rabu'),
(12, 10, 'Rabu'),
(13, 10, 'Kamis'),
(14, 11, 'Kamis'),
(15, 11, 'Jumat'),
(16, 12, 'Jumat'),
(17, 12, 'Sabtu'),
(18, 13, 'Sabtu'),
(19, 13, 'Minggu'),
(20, 14, 'Minggu'),
(21, 14, 'Senin'),
(22, 15, 'Senin'),
(23, 16, 'Selasa'),
(24, 17, 'Rabu'),
(25, 18, 'Kamis'),
(26, 19, 'Jumat'),
(27, 20, 'Sabtu'),
(28, 21, 'Minggu');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jadwal_destinasi`
--

CREATE TABLE `jadwal_destinasi` (
  `id_jadwaldestinasi` int(11) NOT NULL,
  `id_paketdestinasi` int(11) NOT NULL,
  `hari` varchar(20) DEFAULT NULL CHECK (`hari` in ('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu')),
  `hari_ke` int(11) NOT NULL,
  `destinasi_ke` int(11) NOT NULL,
  `koordinat_berangkat` varchar(100) DEFAULT NULL,
  `koordinat_tiba` varchar(100) DEFAULT NULL,
  `jarak_tempuh` double NOT NULL,
  `waktu_tempuh` int(11) NOT NULL,
  `waktu_sebenarnya` int(11) NOT NULL,
  `id_destinasi` int(11) NOT NULL,
  `jam_mulai` time NOT NULL,
  `jam_selesai` time NOT NULL,
  `jam_lokasi` char(5) DEFAULT NULL CHECK (`jam_lokasi` in ('WIB','WITA','WIT')),
  `catatan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jadwal_destinasi`
--

INSERT INTO `jadwal_destinasi` (`id_jadwaldestinasi`, `id_paketdestinasi`, `hari`, `hari_ke`, `destinasi_ke`, `koordinat_berangkat`, `koordinat_tiba`, `jarak_tempuh`, `waktu_tempuh`, `waktu_sebenarnya`, `id_destinasi`, `jam_mulai`, `jam_selesai`, `jam_lokasi`, `catatan`) VALUES
(1, 1, 'Rabu', 1, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(2, 1, 'Rabu', 1, 2, '', '', 4.4, 20, 20, 2, '08:20:00', '10:40:00', 'WIB', ''),
(3, 1, 'Rabu', 1, 3, '', '', 4.9, 19, 20, 4, '11:00:00', '13:20:00', 'WIB', ''),
(4, 1, 'Rabu', 1, 4, '', '', 4.1, 51, 55, 5, '14:15:00', '16:35:00', 'WIB', ''),
(5, 2, 'Senin', 1, 1, '', '', 0, 0, 0, 2, '06:00:00', '08:00:00', 'WIB', ''),
(6, 2, 'Senin', 1, 2, '', '', 4.4, 20, 20, 3, '08:20:00', '10:40:00', 'WIB', ''),
(7, 2, 'Senin', 1, 3, '', '', 4.9, 19, 20, 4, '11:00:00', '13:20:00', 'WIB', ''),
(8, 2, 'Senin', 1, 4, '', '', 4.1, 51, 55, 5, '14:15:00', '16:35:00', 'WIB', ''),
(9, 2, 'Selasa', 2, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(10, 2, 'Selasa', 2, 2, '', '', 4.4, 20, 20, 7, '10:20:00', '11:40:00', 'WIB', ''),
(11, 2, 'Selasa', 2, 3, '', '', 4.9, 19, 20, 10, '12:00:00', '13:20:00', 'WIB', ''),
(12, 2, 'Selasa', 2, 4, '', '', 4.1, 51, 55, 11, '14:15:00', '16:35:00', 'WIB', ''),
(13, 3, 'Minggu', 1, 1, '', '', 0, 0, 0, 17, '09:00:00', '11:00:00', 'WIB', ''),
(14, 3, 'Minggu', 1, 2, '', '', 4.4, 20, 20, 18, '11:20:00', '13:40:00', 'WIB', ''),
(15, 3, 'Minggu', 1, 3, '', '', 4.9, 19, 20, 19, '14:00:00', '15:20:00', 'WIB', ''),
(16, 3, 'Minggu', 1, 4, '', '', 4.1, 51, 55, 20, '16:15:00', '17:15:00', 'WIB', ''),
(17, 3, 'Senin', 2, 1, '', '', 0, 0, 0, 2, '09:00:00', '11:00:00', 'WIB', ''),
(18, 3, 'Senin', 2, 2, '', '', 4.4, 20, 20, 3, '11:20:00', '13:40:00', 'WIB', ''),
(19, 3, 'Senin', 2, 3, '', '', 4.9, 19, 20, 4, '14:00:00', '15:20:00', 'WIB', ''),
(20, 3, 'Senin', 2, 4, '', '', 4.1, 51, 55, 5, '16:15:00', '17:15:00', 'WIB', ''),
(21, 3, 'Selasa', 3, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(22, 3, 'Selasa', 3, 2, '', '', 4.4, 20, 20, 7, '10:20:00', '11:40:00', 'WIB', ''),
(23, 3, 'Selasa', 3, 3, '', '', 4.9, 19, 20, 10, '12:00:00', '13:20:00', 'WIB', ''),
(24, 3, 'Selasa', 3, 4, '', '', 4.1, 51, 55, 11, '14:15:00', '16:35:00', 'WIB', ''),
(25, 4, 'Rabu', 1, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(26, 4, 'Rabu', 1, 2, '', '', 4.4, 20, 20, 2, '08:20:00', '10:40:00', 'WIB', ''),
(27, 4, 'Rabu', 1, 3, '', '', 4.9, 19, 20, 4, '11:00:00', '13:20:00', 'WIB', ''),
(28, 4, 'Rabu', 1, 4, '', '', 4.1, 51, 55, 5, '14:15:00', '16:35:00', 'WIB', ''),
(29, 4, 'Kamis', 2, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(30, 4, 'Kamis', 2, 2, '', '', 7.2, 25, 25, 7, '10:25:00', '11:45:00', 'WIB', ''),
(31, 4, 'Kamis', 2, 3, '', '', 3.7, 31, 35, 8, '12:20:00', '14:40:00', 'WIB', ''),
(32, 4, 'Kamis', 2, 4, '', '', 2.2, 10, 10, 5, '14:50:00', '17:10:00', 'WIB', ''),
(33, 4, 'Jumat', 3, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(34, 4, 'Jumat', 3, 2, '', '', 9.5, 30, 30, 2, '08:30:00', '10:50:00', 'WIB', ''),
(35, 4, 'Jumat', 3, 3, '', '', 7.3, 13, 15, 3, '11:05:00', '13:25:00', 'WIB', ''),
(36, 4, 'Jumat', 3, 4, '', '', 7, 10, 10, 4, '13:35:00', '15:55:00', 'WIB', ''),
(37, 4, 'Sabtu', 4, 1, '', '', 0, 0, 0, 4, '09:00:00', '10:00:00', 'WIB', ''),
(38, 4, 'Sabtu', 4, 2, '', '', 3.1, 10, 10, 4, '10:10:00', '11:10:00', 'WIB', ''),
(39, 4, 'Sabtu', 4, 3, '', '', 1.6, 5, 5, 5, '11:15:00', '12:15:00', 'WIB', ''),
(40, 4, 'Sabtu', 4, 4, '', '', 4.3, 15, 15, 7, '12:30:00', '13:30:00', 'WIB', ''),
(41, 4, 'Sabtu', 4, 5, '', '', 2.6, 13, 15, 8, '13:45:00', '14:45:00', 'WIB', ''),
(42, 5, 'Senin', 1, 1, '', '', 0, 0, 0, 2, '06:00:00', '08:00:00', 'WIB', ''),
(43, 5, 'Senin', 1, 2, '', '', 4.4, 20, 20, 3, '08:20:00', '10:40:00', 'WIB', ''),
(44, 5, 'Senin', 1, 3, '', '', 4.9, 19, 20, 4, '11:00:00', '13:20:00', 'WIB', ''),
(45, 5, 'Senin', 1, 4, '', '', 4.1, 51, 55, 5, '14:15:00', '16:35:00', 'WIB', ''),
(46, 5, 'Selasa', 2, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(47, 5, 'Selasa', 2, 2, '', '', 4.4, 20, 20, 7, '10:20:00', '11:40:00', 'WIB', ''),
(48, 5, 'Selasa', 2, 3, '', '', 4.9, 19, 20, 10, '12:00:00', '13:20:00', 'WIB', ''),
(49, 5, 'Selasa', 2, 4, '', '', 4.1, 51, 55, 11, '14:15:00', '16:35:00', 'WIB', ''),
(50, 5, 'Rabu', 3, 1, '', '', 0, 0, 0, 12, '08:00:00', '09:00:00', 'WIB', ''),
(51, 5, 'Rabu', 3, 2, '', '', 4.4, 20, 20, 13, '09:20:00', '10:40:00', 'WIB', ''),
(52, 5, 'Rabu', 3, 3, '', '', 4.9, 19, 20, 14, '11:00:00', '13:20:00', 'WIB', ''),
(53, 5, 'Rabu', 3, 4, '', '', 4.1, 51, 55, 15, '14:15:00', '15:35:00', 'WIB', ''),
(54, 5, 'Kamis', 4, 1, '', '', 0, 0, 0, 16, '09:00:00', '10:00:00', 'WIB', ''),
(55, 5, 'Kamis', 4, 2, '', '', 4.4, 20, 20, 17, '10:20:00', '11:40:00', 'WIB', ''),
(56, 5, 'Kamis', 4, 3, '', '', 4.9, 19, 20, 19, '12:00:00', '13:20:00', 'WIB', ''),
(57, 5, 'Kamis', 4, 4, '', '', 4.1, 51, 55, 20, '14:15:00', '16:35:00', 'WIB', ''),
(58, 5, 'Jumat', 5, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(59, 5, 'Jumat', 5, 2, '', '', 9.5, 30, 30, 2, '08:30:00', '10:50:00', 'WIB', ''),
(60, 5, 'Jumat', 5, 3, '', '', 7.3, 13, 15, 3, '11:05:00', '13:25:00', 'WIB', ''),
(61, 5, 'Jumat', 5, 4, '', '', 7, 10, 10, 4, '13:35:00', '15:55:00', 'WIB', ''),
(62, 6, 'Minggu', 1, 1, '', '', 0, 0, 0, 17, '09:00:00', '11:00:00', 'WIB', ''),
(63, 6, 'Minggu', 1, 2, '', '', 4.4, 20, 20, 18, '11:20:00', '13:40:00', 'WIB', ''),
(64, 6, 'Minggu', 1, 3, '', '', 4.9, 19, 20, 19, '14:00:00', '15:20:00', 'WIB', ''),
(65, 6, 'Minggu', 1, 4, '', '', 4.1, 51, 55, 20, '16:15:00', '17:15:00', 'WIB', ''),
(66, 6, 'Senin', 2, 1, '', '', 0, 0, 0, 2, '09:00:00', '11:00:00', 'WIB', ''),
(67, 6, 'Senin', 2, 2, '', '', 4.4, 20, 20, 3, '11:20:00', '13:40:00', 'WIB', ''),
(68, 6, 'Senin', 2, 3, '', '', 4.9, 19, 20, 4, '14:00:00', '15:20:00', 'WIB', ''),
(69, 6, 'Senin', 2, 4, '', '', 4.1, 51, 55, 5, '16:15:00', '17:15:00', 'WIB', ''),
(70, 6, 'Selasa', 3, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(71, 6, 'Selasa', 3, 2, '', '', 4.4, 20, 20, 7, '10:20:00', '11:40:00', 'WIB', ''),
(72, 6, 'Selasa', 3, 3, '', '', 4.9, 19, 20, 10, '12:00:00', '13:20:00', 'WIB', ''),
(73, 6, 'Selasa', 3, 4, '', '', 4.1, 51, 55, 11, '14:15:00', '16:35:00', 'WIB', ''),
(74, 6, 'Rabu', 4, 1, '', '', 0, 0, 0, 12, '08:00:00', '09:00:00', 'WIB', ''),
(75, 6, 'Rabu', 4, 2, '', '', 4.4, 20, 20, 13, '09:20:00', '10:40:00', 'WIB', ''),
(76, 6, 'Rabu', 4, 3, '', '', 4.9, 19, 20, 14, '11:00:00', '13:20:00', 'WIB', ''),
(77, 6, 'Rabu', 4, 4, '', '', 4.1, 51, 55, 15, '14:15:00', '15:35:00', 'WIB', ''),
(78, 6, 'Kamis', 5, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(79, 6, 'Kamis', 5, 2, '', '', 7.2, 25, 25, 7, '10:25:00', '11:45:00', 'WIB', ''),
(80, 6, 'Kamis', 5, 3, '', '', 3.7, 31, 35, 8, '12:20:00', '14:40:00', 'WIB', ''),
(81, 6, 'Kamis', 5, 4, '', '', 2.2, 10, 10, 5, '14:50:00', '17:10:00', 'WIB', ''),
(82, 6, 'Jumat', 6, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(83, 6, 'Jumat', 6, 2, '', '', 9.5, 30, 30, 2, '08:30:00', '10:50:00', 'WIB', ''),
(84, 6, 'Jumat', 6, 3, '', '', 7.3, 13, 15, 3, '11:05:00', '13:25:00', 'WIB', ''),
(85, 6, 'Jumat', 6, 4, '', '', 7, 10, 10, 4, '13:35:00', '15:55:00', 'WIB', ''),
(86, 7, 'Minggu', 1, 1, '', '', 0, 0, 0, 17, '09:00:00', '11:00:00', 'WIB', ''),
(87, 7, 'Minggu', 1, 2, '', '', 4.4, 20, 20, 18, '11:20:00', '13:40:00', 'WIB', ''),
(88, 7, 'Minggu', 1, 3, '', '', 4.9, 19, 20, 19, '14:00:00', '15:20:00', 'WIB', ''),
(89, 7, 'Minggu', 1, 4, '', '', 4.1, 51, 55, 20, '16:15:00', '17:15:00', 'WIB', ''),
(90, 8, 'Minggu', 1, 1, '', '', 0, 0, 0, 17, '09:00:00', '11:00:00', 'WIB', ''),
(91, 8, 'Minggu', 1, 2, '', '', 4.4, 20, 20, 18, '11:20:00', '13:40:00', 'WIB', ''),
(92, 8, 'Minggu', 1, 3, '', '', 4.9, 19, 20, 19, '14:00:00', '15:20:00', 'WIB', ''),
(93, 8, 'Minggu', 1, 4, '', '', 4.1, 51, 55, 20, '16:15:00', '17:15:00', 'WIB', ''),
(94, 8, 'Senin', 2, 1, '', '', 0, 0, 0, 2, '09:00:00', '11:00:00', 'WIB', ''),
(95, 8, 'Senin', 2, 2, '', '', 4.4, 20, 20, 3, '11:20:00', '13:40:00', 'WIB', ''),
(96, 8, 'Senin', 2, 3, '', '', 4.9, 19, 20, 4, '14:00:00', '15:20:00', 'WIB', ''),
(97, 8, 'Senin', 2, 4, '', '', 4.1, 51, 55, 5, '16:15:00', '17:15:00', 'WIB', ''),
(98, 9, 'Minggu', 1, 1, '', '', 0, 0, 0, 17, '09:00:00', '11:00:00', 'WIB', ''),
(99, 9, 'Minggu', 1, 2, '', '', 4.4, 20, 20, 18, '11:20:00', '13:40:00', 'WIB', ''),
(100, 9, 'Minggu', 1, 3, '', '', 4.9, 19, 20, 19, '14:00:00', '15:20:00', 'WIB', ''),
(101, 9, 'Minggu', 1, 4, '', '', 4.1, 51, 55, 20, '16:15:00', '17:15:00', 'WIB', ''),
(102, 9, 'Senin', 2, 1, '', '', 0, 0, 0, 2, '09:00:00', '11:00:00', 'WIB', ''),
(103, 9, 'Senin', 2, 2, '', '', 4.4, 20, 20, 3, '11:20:00', '13:40:00', 'WIB', ''),
(104, 9, 'Senin', 2, 3, '', '', 4.9, 19, 20, 4, '14:00:00', '15:20:00', 'WIB', ''),
(105, 9, 'Senin', 2, 4, '', '', 4.1, 51, 55, 5, '16:15:00', '17:15:00', 'WIB', ''),
(106, 9, 'Selasa', 3, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(107, 9, 'Selasa', 3, 2, '', '', 4.4, 20, 20, 7, '10:20:00', '11:40:00', 'WIB', ''),
(108, 9, 'Selasa', 3, 3, '', '', 4.9, 19, 20, 10, '12:00:00', '13:20:00', 'WIB', ''),
(109, 9, 'Selasa', 3, 4, '', '', 4.1, 51, 55, 11, '14:15:00', '16:35:00', 'WIB', ''),
(110, 10, 'Rabu', 1, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(111, 10, 'Rabu', 1, 2, '', '', 4.4, 20, 20, 2, '08:20:00', '10:40:00', 'WIB', ''),
(112, 10, 'Rabu', 1, 3, '', '', 4.9, 19, 20, 4, '11:00:00', '13:20:00', 'WIB', ''),
(113, 10, 'Rabu', 1, 4, '', '', 4.1, 51, 55, 5, '14:15:00', '16:35:00', 'WIB', ''),
(114, 10, 'Kamis', 2, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(115, 10, 'Kamis', 2, 2, '', '', 7.2, 25, 25, 7, '10:25:00', '11:45:00', 'WIB', ''),
(116, 10, 'Kamis', 2, 3, '', '', 3.7, 31, 35, 8, '12:20:00', '14:40:00', 'WIB', ''),
(117, 10, 'Kamis', 2, 4, '', '', 2.2, 10, 10, 5, '14:50:00', '17:10:00', 'WIB', ''),
(118, 10, 'Jumat', 3, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(119, 10, 'Jumat', 3, 2, '', '', 9.5, 30, 30, 2, '08:30:00', '10:50:00', 'WIB', ''),
(120, 10, 'Jumat', 3, 3, '', '', 7.3, 13, 15, 3, '11:05:00', '13:25:00', 'WIB', ''),
(121, 10, 'Jumat', 3, 4, '', '', 7, 10, 10, 4, '13:35:00', '15:55:00', 'WIB', ''),
(122, 10, 'Sabtu', 4, 1, '', '', 0, 0, 0, 4, '09:00:00', '10:00:00', 'WIB', ''),
(123, 10, 'Sabtu', 4, 2, '', '', 3.1, 10, 10, 4, '10:10:00', '11:10:00', 'WIB', ''),
(124, 10, 'Sabtu', 4, 3, '', '', 1.6, 5, 5, 5, '11:15:00', '12:15:00', 'WIB', ''),
(125, 10, 'Sabtu', 4, 4, '', '', 4.3, 15, 15, 7, '12:30:00', '13:30:00', 'WIB', ''),
(126, 10, 'Sabtu', 4, 5, '', '', 2.6, 13, 15, 8, '13:45:00', '14:45:00', 'WIB', ''),
(127, 11, 'Sabtu', 1, 1, '', '', 0, 0, 0, 49, '09:00:00', '10:00:00', 'WIB', ''),
(128, 11, 'Sabtu', 1, 2, '', '', 3.1, 10, 10, 53, '10:10:00', '11:10:00', 'WIB', ''),
(129, 11, 'Sabtu', 1, 3, '', '', 1.6, 5, 5, 53, '11:15:00', '12:15:00', 'WIB', ''),
(130, 11, 'Sabtu', 1, 4, '', '', 4.3, 15, 15, 55, '12:30:00', '13:30:00', 'WIB', ''),
(131, 11, 'Sabtu', 1, 5, '', '', 2.6, 13, 15, 57, '13:45:00', '14:45:00', 'WIB', ''),
(132, 12, 'Senin', 1, 1, '', '', 0, 0, 0, 50, '09:00:00', '10:00:00', 'WIB', ''),
(133, 12, 'Senin', 1, 2, '', '', 3.1, 10, 10, 52, '10:10:00', '11:10:00', 'WIB', ''),
(134, 12, 'Senin', 1, 3, '', '', 1.6, 5, 5, 54, '11:15:00', '12:15:00', 'WIB', ''),
(135, 12, 'Senin', 1, 4, '', '', 4.3, 15, 15, 58, '12:30:00', '13:30:00', 'WIB', ''),
(136, 12, 'Senin', 1, 5, '', '', 2.6, 13, 15, 60, '13:45:00', '14:45:00', 'WIB', ''),
(137, 12, 'Selasa', 2, 1, '', '', 0, 0, 0, 61, '09:00:00', '10:00:00', 'WIB', ''),
(138, 12, 'Selasa', 2, 2, '', '', 3.1, 10, 10, 62, '10:10:00', '11:10:00', 'WIB', ''),
(139, 12, 'Selasa', 2, 3, '', '', 1.6, 5, 5, 63, '11:15:00', '12:15:00', 'WIB', ''),
(140, 12, 'Selasa', 2, 4, '', '', 4.3, 15, 15, 64, '12:30:00', '13:30:00', 'WIB', ''),
(141, 12, 'Selasa', 2, 5, '', '', 2.6, 13, 15, 65, '13:45:00', '14:45:00', 'WIB', ''),
(142, 13, 'Rabu', 1, 1, '', '', 0, 0, 0, 66, '09:00:00', '10:00:00', 'WIB', ''),
(143, 13, 'Rabu', 1, 2, '', '', 3.1, 10, 10, 74, '10:10:00', '11:10:00', 'WIB', ''),
(144, 13, 'Rabu', 1, 3, '', '', 1.6, 5, 5, 67, '11:15:00', '12:15:00', 'WIB', ''),
(145, 13, 'Rabu', 1, 4, '', '', 4.3, 15, 15, 75, '12:30:00', '13:30:00', 'WIB', ''),
(146, 13, 'Rabu', 1, 5, '', '', 2.6, 13, 15, 56, '13:45:00', '14:45:00', 'WIB', ''),
(147, 13, 'Kamis', 2, 1, '', '', 0, 0, 0, 50, '09:00:00', '10:00:00', 'WIB', ''),
(148, 13, 'Kamis', 2, 2, '', '', 3.1, 10, 10, 69, '10:10:00', '11:10:00', 'WIB', ''),
(149, 13, 'Kamis', 2, 3, '', '', 1.6, 5, 5, 76, '11:15:00', '12:15:00', 'WIB', ''),
(150, 13, 'Kamis', 2, 4, '', '', 4.3, 15, 15, 70, '12:30:00', '13:30:00', 'WIB', ''),
(151, 13, 'Kamis', 2, 5, '', '', 2.6, 13, 15, 77, '13:45:00', '14:45:00', 'WIB', ''),
(152, 13, 'Jumat', 3, 1, '', '', 0, 0, 0, 71, '09:00:00', '10:00:00', 'WIB', ''),
(153, 13, 'Jumat', 3, 2, '', '', 3.1, 10, 10, 78, '10:10:00', '11:10:00', 'WIB', ''),
(154, 13, 'Jumat', 3, 3, '', '', 1.6, 5, 5, 72, '11:15:00', '12:15:00', 'WIB', ''),
(155, 13, 'Jumat', 3, 4, '', '', 4.3, 15, 15, 79, '12:30:00', '13:30:00', 'WIB', ''),
(156, 13, 'Jumat', 3, 5, '', '', 2.6, 13, 15, 73, '13:45:00', '14:45:00', 'WIB', ''),
(157, 14, 'Kamis', 1, 1, '', '', 0, 0, 0, 80, '09:00:00', '10:00:00', 'WIB', ''),
(158, 14, 'Kamis', 1, 2, '', '', 3.1, 10, 10, 90, '10:10:00', '11:10:00', 'WIB', ''),
(159, 14, 'Kamis', 1, 3, '', '', 1.6, 5, 5, 81, '11:15:00', '12:15:00', 'WIB', ''),
(160, 14, 'Kamis', 1, 4, '', '', 4.3, 15, 15, 91, '12:30:00', '13:30:00', 'WIB', ''),
(161, 14, 'Kamis', 1, 5, '', '', 2.6, 13, 15, 82, '13:45:00', '14:45:00', 'WIB', ''),
(162, 14, 'Jumat', 2, 1, '', '', 0, 0, 0, 92, '09:00:00', '10:00:00', 'WIB', ''),
(163, 14, 'Jumat', 2, 2, '', '', 3.1, 10, 10, 83, '10:10:00', '11:10:00', 'WIB', ''),
(164, 14, 'Jumat', 2, 3, '', '', 1.6, 5, 5, 93, '11:15:00', '12:15:00', 'WIB', ''),
(165, 14, 'Jumat', 2, 4, '', '', 4.3, 15, 15, 84, '12:30:00', '13:30:00', 'WIB', ''),
(166, 14, 'Jumat', 2, 5, '', '', 2.6, 13, 15, 56, '13:45:00', '14:45:00', 'WIB', ''),
(167, 14, 'Sabtu', 3, 1, '', '', 0, 0, 0, 85, '09:00:00', '10:00:00', 'WIB', ''),
(168, 14, 'Sabtu', 3, 2, '', '', 3.1, 10, 10, 95, '10:10:00', '11:10:00', 'WIB', ''),
(169, 14, 'Sabtu', 3, 3, '', '', 1.6, 5, 5, 86, '11:15:00', '12:15:00', 'WIB', ''),
(170, 14, 'Sabtu', 3, 4, '', '', 4.3, 15, 15, 96, '12:30:00', '13:30:00', 'WIB', ''),
(171, 14, 'Sabtu', 3, 5, '', '', 2.6, 13, 15, 87, '13:45:00', '14:45:00', 'WIB', ''),
(172, 14, 'Minggu', 4, 1, '', '', 0, 0, 0, 56, '09:00:00', '10:00:00', 'WIB', ''),
(173, 14, 'Minggu', 4, 2, '', '', 3.1, 10, 10, 88, '10:10:00', '11:10:00', 'WIB', ''),
(174, 14, 'Minggu', 4, 3, '', '', 1.6, 5, 5, 98, '11:15:00', '12:15:00', 'WIB', ''),
(175, 14, 'Minggu', 4, 4, '', '', 4.3, 15, 15, 89, '12:30:00', '13:30:00', 'WIB', ''),
(176, 14, 'Minggu', 4, 5, '', '', 2.6, 13, 15, 99, '13:45:00', '14:45:00', 'WIB', ''),
(177, 15, 'Minggu', 1, 1, '', '', 0, 0, 0, 100, '09:00:00', '10:00:00', 'WIB', ''),
(178, 15, 'Minggu', 1, 2, '', '', 3.1, 10, 10, 101, '10:10:00', '11:10:00', 'WIB', ''),
(179, 15, 'Minggu', 1, 3, '', '', 1.6, 5, 5, 49, '11:15:00', '12:15:00', 'WIB', ''),
(180, 15, 'Minggu', 1, 4, '', '', 4.3, 15, 15, 50, '12:30:00', '13:30:00', 'WIB', ''),
(181, 15, 'Minggu', 1, 5, '', '', 2.6, 13, 15, 56, '13:45:00', '14:45:00', 'WIB', ''),
(182, 15, 'Senin', 2, 1, '', '', 0, 0, 0, 56, '09:00:00', '10:00:00', 'WIB', ''),
(183, 15, 'Senin', 2, 2, '', '', 3.1, 10, 10, 53, '10:10:00', '11:10:00', 'WIB', ''),
(184, 15, 'Senin', 2, 3, '', '', 1.6, 5, 5, 54, '11:15:00', '12:15:00', 'WIB', ''),
(185, 15, 'Senin', 2, 4, '', '', 4.3, 15, 15, 55, '12:30:00', '13:30:00', 'WIB', ''),
(186, 15, 'Senin', 2, 5, '', '', 2.6, 13, 15, 56, '13:45:00', '14:45:00', 'WIB', ''),
(187, 15, 'Selasa', 3, 1, '', '', 0, 0, 0, 57, '09:00:00', '10:00:00', 'WIB', ''),
(188, 15, 'Selasa', 3, 2, '', '', 3.1, 10, 10, 58, '10:10:00', '11:10:00', 'WIB', ''),
(189, 15, 'Selasa', 3, 3, '', '', 1.6, 5, 5, 59, '11:15:00', '12:15:00', 'WIB', ''),
(190, 15, 'Selasa', 3, 4, '', '', 4.3, 15, 15, 60, '12:30:00', '13:30:00', 'WIB', ''),
(191, 15, 'Selasa', 3, 5, '', '', 2.6, 13, 15, 61, '13:45:00', '14:45:00', 'WIB', ''),
(192, 15, 'Rabu', 4, 1, '', '', 0, 0, 0, 62, '09:00:00', '10:00:00', 'WIB', ''),
(193, 15, 'Rabu', 4, 2, '', '', 3.1, 10, 10, 63, '10:10:00', '11:10:00', 'WIB', ''),
(194, 15, 'Rabu', 4, 3, '', '', 1.6, 5, 5, 64, '11:15:00', '12:15:00', 'WIB', ''),
(195, 15, 'Rabu', 4, 4, '', '', 4.3, 15, 15, 65, '12:30:00', '13:30:00', 'WIB', ''),
(196, 15, 'Rabu', 4, 5, '', '', 2.6, 13, 15, 66, '13:45:00', '14:45:00', 'WIB', ''),
(197, 15, 'Kamis', 5, 1, '', '', 0, 0, 0, 67, '09:00:00', '10:00:00', 'WIB', ''),
(198, 15, 'Kamis', 5, 2, '', '', 3.1, 10, 10, 53, '10:10:00', '11:10:00', 'WIB', ''),
(199, 15, 'Kamis', 5, 3, '', '', 1.6, 5, 5, 69, '11:15:00', '12:15:00', 'WIB', ''),
(200, 15, 'Kamis', 5, 4, '', '', 4.3, 15, 15, 70, '12:30:00', '13:30:00', 'WIB', ''),
(201, 15, 'Kamis', 5, 5, '', '', 2.6, 13, 15, 71, '13:45:00', '14:45:00', 'WIB', ''),
(202, 16, 'Selasa', 1, 1, '', '', 0, 0, 0, 72, '09:00:00', '10:00:00', 'WIB', ''),
(203, 16, 'Selasa', 1, 2, '', '', 3.1, 10, 10, 73, '10:10:00', '11:10:00', 'WIB', ''),
(204, 16, 'Selasa', 1, 3, '', '', 1.6, 5, 5, 74, '11:15:00', '12:15:00', 'WIB', ''),
(205, 16, 'Selasa', 1, 4, '', '', 4.3, 15, 15, 75, '12:30:00', '13:30:00', 'WIB', ''),
(206, 16, 'Selasa', 1, 5, '', '', 2.6, 13, 15, 76, '13:45:00', '14:45:00', 'WIB', ''),
(207, 16, 'Rabu', 2, 1, '', '', 0, 0, 0, 77, '09:00:00', '10:00:00', 'WIB', ''),
(208, 16, 'Rabu', 2, 2, '', '', 3.1, 10, 10, 78, '10:10:00', '11:10:00', 'WIB', ''),
(209, 16, 'Rabu', 2, 3, '', '', 1.6, 5, 5, 79, '11:15:00', '12:15:00', 'WIB', ''),
(210, 16, 'Rabu', 2, 4, '', '', 4.3, 15, 15, 80, '12:30:00', '13:30:00', 'WIB', ''),
(211, 16, 'Rabu', 2, 5, '', '', 2.6, 13, 15, 81, '13:45:00', '14:45:00', 'WIB', ''),
(212, 16, 'Kamis', 3, 1, '', '', 0, 0, 0, 82, '09:00:00', '10:00:00', 'WIB', ''),
(213, 16, 'Kamis', 3, 2, '', '', 3.1, 10, 10, 83, '10:10:00', '11:10:00', 'WIB', ''),
(214, 16, 'Kamis', 3, 3, '', '', 1.6, 5, 5, 84, '11:15:00', '12:15:00', 'WIB', ''),
(215, 16, 'Kamis', 3, 4, '', '', 4.3, 15, 15, 85, '12:30:00', '13:30:00', 'WIB', ''),
(216, 16, 'Kamis', 3, 5, '', '', 2.6, 13, 15, 86, '13:45:00', '14:45:00', 'WIB', ''),
(217, 16, 'Jumat', 4, 1, '', '', 0, 0, 0, 87, '09:00:00', '10:00:00', 'WIB', ''),
(218, 16, 'Jumat', 4, 2, '', '', 3.1, 10, 10, 88, '10:10:00', '11:10:00', 'WIB', ''),
(219, 16, 'Jumat', 4, 3, '', '', 1.6, 5, 5, 89, '11:15:00', '12:15:00', 'WIB', ''),
(220, 16, 'Jumat', 4, 4, '', '', 4.3, 15, 15, 90, '12:30:00', '13:30:00', 'WIB', ''),
(221, 16, 'Jumat', 4, 5, '', '', 2.6, 13, 15, 91, '13:45:00', '14:45:00', 'WIB', ''),
(222, 16, 'Sabtu', 5, 1, '', '', 0, 0, 0, 92, '09:00:00', '10:00:00', 'WIB', ''),
(223, 16, 'Sabtu', 5, 2, '', '', 3.1, 10, 10, 93, '10:10:00', '11:10:00', 'WIB', ''),
(224, 16, 'Sabtu', 5, 3, '', '', 1.6, 5, 5, 56, '11:15:00', '12:15:00', 'WIB', ''),
(225, 16, 'Sabtu', 5, 4, '', '', 4.3, 15, 15, 95, '12:30:00', '13:30:00', 'WIB', ''),
(226, 16, 'Sabtu', 5, 5, '', '', 2.6, 13, 15, 96, '13:45:00', '14:45:00', 'WIB', ''),
(227, 16, 'Minggu', 6, 1, '', '', 0, 0, 0, 56, '09:00:00', '10:00:00', 'WIB', ''),
(228, 16, 'Minggu', 6, 2, '', '', 3.1, 10, 10, 98, '10:10:00', '11:10:00', 'WIB', ''),
(229, 16, 'Minggu', 6, 3, '', '', 1.6, 5, 5, 99, '11:15:00', '12:15:00', 'WIB', ''),
(230, 16, 'Minggu', 6, 4, '', '', 4.3, 15, 15, 100, '12:30:00', '13:30:00', 'WIB', ''),
(231, 16, 'Minggu', 6, 5, '', '', 2.6, 13, 15, 101, '13:45:00', '14:45:00', 'WIB', ''),
(232, 17, 'Selasa', 1, 1, '', '', 0, 0, 0, 49, '09:00:00', '10:00:00', 'WIB', ''),
(233, 17, 'Selasa', 1, 2, '', '', 3.1, 10, 10, 53, '10:10:00', '11:10:00', 'WIB', ''),
(234, 17, 'Selasa', 1, 3, '', '', 1.6, 5, 5, 53, '11:15:00', '12:15:00', 'WIB', ''),
(235, 17, 'Selasa', 1, 4, '', '', 4.3, 15, 15, 52, '12:30:00', '13:30:00', 'WIB', ''),
(236, 17, 'Selasa', 1, 5, '', '', 2.6, 13, 15, 50, '13:45:00', '14:45:00', 'WIB', ''),
(237, 18, 'Jumat', 1, 1, '', '', 0, 0, 0, 54, '09:00:00', '10:00:00', 'WIB', ''),
(238, 18, 'Jumat', 1, 2, '', '', 3.1, 10, 10, 56, '10:10:00', '11:10:00', 'WIB', ''),
(239, 18, 'Jumat', 1, 3, '', '', 1.6, 5, 5, 58, '11:15:00', '12:15:00', 'WIB', ''),
(240, 18, 'Jumat', 1, 4, '', '', 4.3, 15, 15, 60, '12:30:00', '13:30:00', 'WIB', ''),
(241, 18, 'Jumat', 1, 5, '', '', 2.6, 13, 15, 62, '13:45:00', '14:45:00', 'WIB', ''),
(242, 18, 'Sabtu', 2, 1, '', '', 0, 0, 0, 63, '09:00:00', '10:00:00', 'WIB', ''),
(243, 18, 'Sabtu', 2, 2, '', '', 3.1, 10, 10, 61, '10:10:00', '11:10:00', 'WIB', ''),
(244, 18, 'Sabtu', 2, 3, '', '', 1.6, 5, 5, 59, '11:15:00', '12:15:00', 'WIB', ''),
(245, 18, 'Sabtu', 2, 4, '', '', 4.3, 15, 15, 57, '12:30:00', '13:30:00', 'WIB', ''),
(246, 18, 'Sabtu', 2, 5, '', '', 2.6, 13, 15, 55, '13:45:00', '14:45:00', 'WIB', ''),
(247, 19, 'Minggu', 1, 1, '', '', 0, 0, 0, 56, '09:00:00', '10:00:00', 'WIB', ''),
(248, 19, 'Minggu', 1, 2, '', '', 3.1, 10, 10, 66, '10:10:00', '11:10:00', 'WIB', ''),
(249, 19, 'Minggu', 1, 3, '', '', 1.6, 5, 5, 53, '11:15:00', '12:15:00', 'WIB', ''),
(250, 19, 'Minggu', 1, 4, '', '', 4.3, 15, 15, 70, '12:30:00', '13:30:00', 'WIB', ''),
(251, 19, 'Minggu', 1, 5, '', '', 2.6, 13, 15, 72, '13:45:00', '14:45:00', 'WIB', ''),
(252, 19, 'Senin', 2, 1, '', '', 0, 0, 0, 74, '09:00:00', '10:00:00', 'WIB', ''),
(253, 19, 'Senin', 2, 2, '', '', 3.1, 10, 10, 76, '10:10:00', '11:10:00', 'WIB', ''),
(254, 19, 'Senin', 2, 3, '', '', 1.6, 5, 5, 78, '11:15:00', '12:15:00', 'WIB', ''),
(255, 19, 'Senin', 2, 4, '', '', 4.3, 15, 15, 77, '12:30:00', '13:30:00', 'WIB', ''),
(256, 19, 'Senin', 2, 5, '', '', 2.6, 13, 15, 75, '13:45:00', '14:45:00', 'WIB', ''),
(257, 19, 'Selasa', 3, 1, '', '', 0, 0, 0, 73, '09:00:00', '10:00:00', 'WIB', ''),
(258, 19, 'Selasa', 3, 2, '', '', 3.1, 10, 10, 71, '10:10:00', '11:10:00', 'WIB', ''),
(259, 19, 'Selasa', 3, 3, '', '', 1.6, 5, 5, 69, '11:15:00', '12:15:00', 'WIB', ''),
(260, 19, 'Selasa', 3, 4, '', '', 4.3, 15, 15, 67, '12:30:00', '13:30:00', 'WIB', ''),
(261, 19, 'Selasa', 3, 5, '', '', 2.6, 13, 15, 65, '13:45:00', '14:45:00', 'WIB', ''),
(262, 20, 'Sabtu', 1, 1, '', '', 0, 0, 0, 79, '09:00:00', '10:00:00', 'WIB', ''),
(263, 20, 'Sabtu', 1, 2, '', '', 3.1, 10, 10, 100, '10:10:00', '11:10:00', 'WIB', ''),
(264, 20, 'Sabtu', 1, 3, '', '', 1.6, 5, 5, 80, '11:15:00', '12:15:00', 'WIB', ''),
(265, 20, 'Sabtu', 1, 4, '', '', 4.3, 15, 15, 56, '12:30:00', '13:30:00', 'WIB', ''),
(266, 20, 'Sabtu', 1, 5, '', '', 2.6, 13, 15, 81, '13:45:00', '14:45:00', 'WIB', ''),
(267, 20, 'Minggu', 2, 1, '', '', 0, 0, 0, 98, '09:00:00', '10:00:00', 'WIB', ''),
(268, 20, 'Minggu', 2, 2, '', '', 3.1, 10, 10, 82, '10:10:00', '11:10:00', 'WIB', ''),
(269, 20, 'Minggu', 2, 3, '', '', 1.6, 5, 5, 96, '11:15:00', '12:15:00', 'WIB', ''),
(270, 20, 'Minggu', 2, 4, '', '', 4.3, 15, 15, 83, '12:30:00', '13:30:00', 'WIB', ''),
(271, 20, 'Minggu', 2, 5, '', '', 2.6, 13, 15, 101, '13:45:00', '14:45:00', 'WIB', ''),
(272, 20, 'Senin', 3, 1, '', '', 0, 0, 0, 84, '09:00:00', '10:00:00', 'WIB', ''),
(273, 20, 'Senin', 3, 2, '', '', 3.1, 10, 10, 93, '10:10:00', '11:10:00', 'WIB', ''),
(274, 20, 'Senin', 3, 3, '', '', 1.6, 5, 5, 85, '11:15:00', '12:15:00', 'WIB', ''),
(275, 20, 'Senin', 3, 4, '', '', 4.3, 15, 15, 92, '12:30:00', '13:30:00', 'WIB', ''),
(276, 20, 'Senin', 3, 5, '', '', 2.6, 13, 15, 86, '13:45:00', '14:45:00', 'WIB', ''),
(277, 20, 'Selasa', 4, 1, '', '', 0, 0, 0, 91, '09:00:00', '10:00:00', 'WIB', ''),
(278, 20, 'Selasa', 4, 2, '', '', 3.1, 10, 10, 87, '10:10:00', '11:10:00', 'WIB', ''),
(279, 20, 'Selasa', 4, 3, '', '', 1.6, 5, 5, 90, '11:15:00', '12:15:00', 'WIB', ''),
(280, 20, 'Selasa', 4, 4, '', '', 4.3, 15, 15, 88, '12:30:00', '13:30:00', 'WIB', ''),
(281, 20, 'Selasa', 4, 5, '', '', 2.6, 13, 15, 89, '13:45:00', '14:45:00', 'WIB', ''),
(282, 21, 'Senin', 1, 1, '', '', 0, 0, 0, 103, '06:00:00', '08:00:00', 'WIB', ''),
(283, 21, 'Senin', 1, 2, '', '', 4.4, 20, 20, 102, '08:20:00', '10:40:00', 'WIB', ''),
(284, 21, 'Senin', 1, 3, '', '', 4.9, 19, 20, 104, '11:00:00', '13:20:00', 'WIB', ''),
(285, 21, 'Senin', 1, 4, '', '', 4.1, 51, 55, 105, '14:15:00', '16:35:00', 'WIB', ''),
(286, 22, 'Senin', 1, 1, '', '', 0, 0, 0, 106, '06:00:00', '08:00:00', 'WIB', ''),
(287, 22, 'Senin', 1, 2, '', '', 4.4, 20, 20, 107, '08:20:00', '10:40:00', 'WIB', ''),
(288, 22, 'Senin', 1, 3, '', '', 4.9, 19, 20, 108, '11:00:00', '13:20:00', 'WIB', ''),
(289, 22, 'Senin', 1, 4, '', '', 4.1, 51, 55, 109, '14:15:00', '16:35:00', 'WIB', ''),
(290, 22, 'Selasa', 2, 1, '', '', 0, 0, 0, 110, '09:00:00', '10:00:00', 'WIB', ''),
(291, 22, 'Selasa', 2, 2, '', '', 4.4, 20, 20, 106, '10:20:00', '11:40:00', 'WIB', ''),
(292, 22, 'Selasa', 2, 3, '', '', 4.9, 19, 20, 112, '12:00:00', '13:20:00', 'WIB', ''),
(293, 22, 'Selasa', 2, 4, '', '', 4.1, 51, 55, 113, '14:15:00', '16:35:00', 'WIB', ''),
(294, 23, 'Jumat', 1, 1, '', '', 0, 0, 0, 114, '09:00:00', '11:00:00', 'WIB', ''),
(295, 23, 'Jumat', 1, 2, '', '', 4.4, 20, 20, 115, '11:20:00', '13:40:00', 'WIB', ''),
(296, 23, 'Jumat', 1, 3, '', '', 4.9, 19, 20, 106, '14:00:00', '15:20:00', 'WIB', ''),
(297, 23, 'Jumat', 1, 4, '', '', 4.1, 51, 55, 117, '16:15:00', '17:15:00', 'WIB', ''),
(298, 23, 'Sabtu', 2, 1, '', '', 0, 0, 0, 118, '09:00:00', '11:00:00', 'WIB', ''),
(299, 23, 'Sabtu', 2, 2, '', '', 4.4, 20, 20, 119, '11:20:00', '13:40:00', 'WIB', ''),
(300, 23, 'Sabtu', 2, 3, '', '', 4.9, 19, 20, 120, '14:00:00', '15:20:00', 'WIB', ''),
(301, 23, 'Sabtu', 2, 4, '', '', 4.1, 51, 55, 121, '16:15:00', '17:15:00', 'WIB', ''),
(302, 23, 'Minggu', 3, 1, '', '', 0, 0, 0, 122, '09:00:00', '10:00:00', 'WIB', ''),
(303, 23, 'Minggu', 3, 2, '', '', 4.4, 20, 20, 123, '10:20:00', '11:40:00', 'WIB', ''),
(304, 23, 'Minggu', 3, 3, '', '', 4.9, 19, 20, 124, '12:00:00', '13:20:00', 'WIB', ''),
(305, 23, 'Minggu', 3, 4, '', '', 4.1, 51, 55, 125, '14:15:00', '16:35:00', 'WIB', ''),
(306, 24, 'Rabu', 1, 1, '', '', 0, 0, 0, 106, '06:00:00', '08:00:00', 'WIB', ''),
(307, 24, 'Rabu', 1, 2, '', '', 4.4, 20, 20, 107, '08:20:00', '10:40:00', 'WIB', ''),
(308, 24, 'Rabu', 1, 3, '', '', 4.9, 19, 20, 128, '11:00:00', '13:20:00', 'WIB', ''),
(309, 24, 'Rabu', 1, 4, '', '', 4.1, 51, 55, 129, '14:15:00', '16:35:00', 'WIB', ''),
(310, 24, 'Kamis', 2, 1, '', '', 0, 0, 0, 130, '09:00:00', '10:00:00', 'WIB', ''),
(311, 24, 'Kamis', 2, 2, '', '', 7.2, 25, 25, 131, '10:25:00', '11:45:00', 'WIB', ''),
(312, 24, 'Kamis', 2, 3, '', '', 3.7, 31, 35, 132, '12:20:00', '14:40:00', 'WIB', ''),
(313, 24, 'Kamis', 2, 4, '', '', 2.2, 10, 10, 133, '14:50:00', '17:10:00', 'WIB', ''),
(314, 24, 'Jumat', 3, 1, '', '', 0, 0, 0, 134, '06:00:00', '08:00:00', 'WIB', ''),
(315, 24, 'Jumat', 3, 2, '', '', 9.5, 30, 30, 135, '08:30:00', '10:50:00', 'WIB', ''),
(316, 24, 'Jumat', 3, 3, '', '', 7.3, 13, 15, 136, '11:05:00', '13:25:00', 'WIB', ''),
(317, 24, 'Jumat', 3, 4, '', '', 7, 10, 10, 137, '13:35:00', '15:55:00', 'WIB', ''),
(318, 24, 'Sabtu', 4, 1, '', '', 0, 0, 0, 138, '09:00:00', '10:00:00', 'WIB', ''),
(319, 24, 'Sabtu', 4, 2, '', '', 3.1, 10, 10, 139, '10:10:00', '11:10:00', 'WIB', ''),
(320, 24, 'Sabtu', 4, 3, '', '', 1.6, 5, 5, 140, '11:15:00', '12:15:00', 'WIB', ''),
(321, 24, 'Sabtu', 4, 4, '', '', 4.3, 15, 15, 141, '12:30:00', '13:30:00', 'WIB', ''),
(322, 24, 'Sabtu', 4, 5, '', '', 2.6, 13, 15, 142, '13:45:00', '14:45:00', 'WIB', ''),
(323, 25, 'Sabtu', 1, 1, '', '', 0, 0, 0, 106, '06:00:00', '08:00:00', 'WIB', ''),
(324, 25, 'Sabtu', 1, 2, '', '', 4.4, 20, 20, 144, '08:20:00', '10:40:00', 'WIB', ''),
(325, 25, 'Sabtu', 1, 3, '', '', 4.9, 19, 20, 145, '11:00:00', '13:20:00', 'WIB', ''),
(326, 25, 'Sabtu', 1, 4, '', '', 4.1, 51, 55, 146, '14:15:00', '16:35:00', 'WIB', ''),
(327, 25, 'Minggu', 2, 1, '', '', 0, 0, 0, 147, '09:00:00', '10:00:00', 'WIB', ''),
(328, 25, 'Minggu', 2, 2, '', '', 4.4, 20, 20, 148, '10:20:00', '11:40:00', 'WIB', ''),
(329, 25, 'Minggu', 2, 3, '', '', 4.9, 19, 20, 149, '12:00:00', '13:20:00', 'WIB', ''),
(330, 25, 'Minggu', 2, 4, '', '', 4.1, 51, 55, 150, '14:15:00', '16:35:00', 'WIB', ''),
(331, 25, 'Senin', 3, 1, '', '', 0, 0, 0, 151, '08:00:00', '09:00:00', 'WIB', ''),
(332, 25, 'Senin', 3, 2, '', '', 4.4, 20, 20, 152, '09:20:00', '10:40:00', 'WIB', ''),
(333, 25, 'Senin', 3, 3, '', '', 4.9, 19, 20, 153, '11:00:00', '13:20:00', 'WIB', ''),
(334, 25, 'Senin', 3, 4, '', '', 4.1, 51, 55, 154, '14:15:00', '15:35:00', 'WIB', ''),
(335, 25, 'Selasa', 4, 1, '', '', 0, 0, 0, 155, '09:00:00', '10:00:00', 'WIB', ''),
(336, 25, 'Selasa', 4, 2, '', '', 4.4, 20, 20, 156, '10:20:00', '11:40:00', 'WIB', ''),
(337, 25, 'Selasa', 4, 3, '', '', 4.9, 19, 20, 157, '12:00:00', '13:20:00', 'WIB', ''),
(338, 25, 'Selasa', 4, 4, '', '', 4.1, 51, 55, 106, '14:15:00', '16:35:00', 'WIB', ''),
(339, 25, 'Rabu', 5, 1, '', '', 0, 0, 0, 103, '06:00:00', '08:00:00', 'WIB', ''),
(340, 25, 'Rabu', 5, 2, '', '', 9.5, 30, 30, 106, '08:30:00', '10:50:00', 'WIB', ''),
(341, 25, 'Rabu', 5, 3, '', '', 7.3, 13, 15, 105, '11:05:00', '13:25:00', 'WIB', ''),
(342, 25, 'Rabu', 5, 4, '', '', 7, 10, 10, 106, '13:35:00', '15:55:00', 'WIB', ''),
(343, 26, 'Sabtu', 1, 1, '', '', 0, 0, 0, 107, '09:00:00', '11:00:00', 'WIB', ''),
(344, 26, 'Sabtu', 1, 2, '', '', 4.4, 20, 20, 108, '11:20:00', '13:40:00', 'WIB', ''),
(345, 26, 'Sabtu', 1, 3, '', '', 4.9, 19, 20, 109, '14:00:00', '15:20:00', 'WIB', ''),
(346, 26, 'Sabtu', 1, 4, '', '', 4.1, 51, 55, 106, '16:15:00', '17:15:00', 'WIB', ''),
(347, 26, 'Minggu', 2, 1, '', '', 0, 0, 0, 107, '09:00:00', '11:00:00', 'WIB', ''),
(348, 26, 'Minggu', 2, 2, '', '', 4.4, 20, 20, 112, '11:20:00', '13:40:00', 'WIB', ''),
(349, 26, 'Minggu', 2, 3, '', '', 4.9, 19, 20, 113, '14:00:00', '15:20:00', 'WIB', ''),
(350, 26, 'Minggu', 2, 4, '', '', 4.1, 51, 55, 114, '16:15:00', '17:15:00', 'WIB', ''),
(351, 26, 'Senin', 3, 1, '', '', 0, 0, 0, 115, '09:00:00', '10:00:00', 'WIB', ''),
(352, 26, 'Senin', 3, 2, '', '', 4.4, 20, 20, 116, '10:20:00', '11:40:00', 'WIB', ''),
(353, 26, 'Senin', 3, 3, '', '', 4.9, 19, 20, 117, '12:00:00', '13:20:00', 'WIB', ''),
(354, 26, 'Senin', 3, 4, '', '', 4.1, 51, 55, 118, '14:15:00', '16:35:00', 'WIB', ''),
(355, 26, 'Selasa', 4, 1, '', '', 0, 0, 0, 119, '08:00:00', '09:00:00', 'WIB', ''),
(356, 26, 'Selasa', 4, 2, '', '', 4.4, 20, 20, 120, '09:20:00', '10:40:00', 'WIB', ''),
(357, 26, 'Selasa', 4, 3, '', '', 4.9, 19, 20, 121, '11:00:00', '13:20:00', 'WIB', ''),
(358, 26, 'Selasa', 4, 4, '', '', 4.1, 51, 55, 106, '14:15:00', '15:35:00', 'WIB', ''),
(359, 26, 'Rabu', 5, 1, '', '', 0, 0, 0, 123, '09:00:00', '10:00:00', 'WIB', ''),
(360, 26, 'Rabu', 5, 2, '', '', 7.2, 25, 25, 124, '10:25:00', '11:45:00', 'WIB', ''),
(361, 26, 'Rabu', 5, 3, '', '', 3.7, 31, 35, 125, '12:20:00', '14:40:00', 'WIB', ''),
(362, 26, 'Rabu', 5, 4, '', '', 2.2, 10, 10, 125, '14:50:00', '17:10:00', 'WIB', ''),
(363, 26, 'Kamis', 6, 1, '', '', 0, 0, 0, 106, '06:00:00', '08:00:00', 'WIB', ''),
(364, 26, 'Kamis', 6, 2, '', '', 9.5, 30, 30, 128, '08:30:00', '10:50:00', 'WIB', ''),
(365, 26, 'Kamis', 6, 3, '', '', 7.3, 13, 15, 129, '11:05:00', '13:25:00', 'WIB', ''),
(366, 26, 'Kamis', 6, 4, '', '', 7, 10, 10, 130, '13:35:00', '15:55:00', 'WIB', ''),
(367, 27, 'Minggu', 1, 1, '', '', 0, 0, 0, 131, '09:00:00', '11:00:00', 'WIB', ''),
(368, 27, 'Minggu', 1, 2, '', '', 4.4, 20, 20, 132, '11:20:00', '13:40:00', 'WIB', ''),
(369, 27, 'Minggu', 1, 3, '', '', 4.9, 19, 20, 133, '14:00:00', '15:20:00', 'WIB', ''),
(370, 27, 'Minggu', 1, 4, '', '', 4.1, 51, 55, 134, '16:15:00', '17:15:00', 'WIB', ''),
(371, 28, 'Jumat', 1, 1, '', '', 0, 0, 0, 135, '09:00:00', '11:00:00', 'WIB', ''),
(372, 28, 'Jumat', 1, 2, '', '', 4.4, 20, 20, 136, '11:20:00', '13:40:00', 'WIB', ''),
(373, 28, 'Jumat', 1, 3, '', '', 4.9, 19, 20, 137, '14:00:00', '15:20:00', 'WIB', ''),
(374, 28, 'Jumat', 1, 4, '', '', 4.1, 51, 55, 106, '16:15:00', '17:15:00', 'WIB', ''),
(375, 28, 'Sabtu', 2, 1, '', '', 0, 0, 0, 139, '09:00:00', '11:00:00', 'WIB', ''),
(376, 28, 'Sabtu', 2, 2, '', '', 4.4, 20, 20, 140, '11:20:00', '13:40:00', 'WIB', ''),
(377, 28, 'Sabtu', 2, 3, '', '', 4.9, 19, 20, 141, '14:00:00', '15:20:00', 'WIB', ''),
(378, 28, 'Sabtu', 2, 4, '', '', 4.1, 51, 55, 142, '16:15:00', '17:15:00', 'WIB', ''),
(379, 29, 'Minggu', 1, 1, '', '', 0, 0, 0, 143, '09:00:00', '11:00:00', 'WIB', ''),
(380, 29, 'Minggu', 1, 2, '', '', 4.4, 20, 20, 144, '11:20:00', '13:40:00', 'WIB', ''),
(381, 29, 'Minggu', 1, 3, '', '', 4.9, 19, 20, 145, '14:00:00', '15:20:00', 'WIB', ''),
(382, 29, 'Minggu', 1, 4, '', '', 4.1, 51, 55, 146, '16:15:00', '17:15:00', 'WIB', ''),
(383, 29, 'Senin', 2, 1, '', '', 0, 0, 0, 147, '09:00:00', '11:00:00', 'WIB', ''),
(384, 29, 'Senin', 2, 2, '', '', 4.4, 20, 20, 148, '11:20:00', '13:40:00', 'WIB', ''),
(385, 29, 'Senin', 2, 3, '', '', 4.9, 19, 20, 149, '14:00:00', '15:20:00', 'WIB', ''),
(386, 29, 'Senin', 2, 4, '', '', 4.1, 51, 55, 150, '16:15:00', '17:15:00', 'WIB', ''),
(387, 29, 'Selasa', 3, 1, '', '', 0, 0, 0, 151, '09:00:00', '10:00:00', 'WIB', ''),
(388, 29, 'Selasa', 3, 2, '', '', 4.4, 20, 20, 152, '10:20:00', '11:40:00', 'WIB', ''),
(389, 29, 'Selasa', 3, 3, '', '', 4.9, 19, 20, 153, '12:00:00', '13:20:00', 'WIB', ''),
(390, 29, 'Selasa', 3, 4, '', '', 4.1, 51, 55, 154, '14:15:00', '16:35:00', 'WIB', ''),
(391, 30, 'Senin', 1, 1, '', '', 0, 0, 0, 106, '06:00:00', '08:00:00', 'WIB', ''),
(392, 30, 'Senin', 1, 2, '', '', 4.4, 20, 20, 156, '08:20:00', '10:40:00', 'WIB', ''),
(393, 30, 'Senin', 1, 3, '', '', 4.9, 19, 20, 157, '11:00:00', '13:20:00', 'WIB', ''),
(394, 30, 'Senin', 1, 4, '', '', 4.1, 51, 55, 106, '14:15:00', '16:35:00', 'WIB', ''),
(395, 30, 'Selasa', 2, 1, '', '', 0, 0, 0, 103, '09:00:00', '10:00:00', 'WIB', ''),
(396, 30, 'Selasa', 2, 2, '', '', 7.2, 25, 25, 104, '10:25:00', '11:45:00', 'WIB', ''),
(397, 30, 'Selasa', 2, 3, '', '', 3.7, 31, 35, 105, '12:20:00', '14:40:00', 'WIB', ''),
(398, 30, 'Selasa', 2, 4, '', '', 2.2, 10, 10, 106, '14:50:00', '17:10:00', 'WIB', ''),
(399, 30, 'Rabu', 3, 1, '', '', 0, 0, 0, 106, '06:00:00', '08:00:00', 'WIB', ''),
(400, 30, 'Rabu', 3, 2, '', '', 9.5, 30, 30, 107, '08:30:00', '10:50:00', 'WIB', ''),
(401, 30, 'Rabu', 3, 3, '', '', 7.3, 13, 15, 109, '11:05:00', '13:25:00', 'WIB', ''),
(402, 30, 'Rabu', 3, 4, '', '', 7, 10, 10, 110, '13:35:00', '15:55:00', 'WIB', ''),
(403, 30, 'Kamis', 4, 1, '', '', 0, 0, 0, 106, '09:00:00', '10:00:00', 'WIB', ''),
(404, 30, 'Kamis', 4, 2, '', '', 3.1, 10, 10, 112, '10:10:00', '11:10:00', 'WIB', ''),
(405, 30, 'Kamis', 4, 3, '', '', 1.6, 5, 5, 113, '11:15:00', '12:15:00', 'WIB', ''),
(406, 30, 'Kamis', 4, 4, '', '', 4.3, 15, 15, 114, '12:30:00', '13:30:00', 'WIB', ''),
(407, 30, 'Kamis', 4, 5, '', '', 2.6, 13, 15, 115, '13:45:00', '14:45:00', 'WIB', ''),
(408, 31, 'Sabtu', 1, 1, '', '', 0, 0, 0, 158, '09:00:00', '10:00:00', 'WIB', ''),
(409, 31, 'Sabtu', 1, 2, '', '', 3.1, 10, 10, 159, '10:10:00', '11:10:00', 'WIB', ''),
(410, 31, 'Sabtu', 1, 3, '', '', 1.6, 5, 5, 160, '11:15:00', '12:15:00', 'WIB', ''),
(411, 31, 'Sabtu', 1, 4, '', '', 4.3, 15, 15, 161, '12:30:00', '13:30:00', 'WIB', ''),
(412, 31, 'Sabtu', 1, 5, '', '', 2.6, 13, 15, 162, '13:45:00', '14:45:00', 'WIB', ''),
(413, 32, 'Senin', 1, 1, '', '', 0, 0, 0, 163, '09:00:00', '10:00:00', 'WIB', ''),
(414, 32, 'Senin', 1, 2, '', '', 3.1, 10, 10, 164, '10:10:00', '11:10:00', 'WIB', ''),
(415, 32, 'Senin', 1, 3, '', '', 1.6, 5, 5, 165, '11:15:00', '12:15:00', 'WIB', ''),
(416, 32, 'Senin', 1, 4, '', '', 4.3, 15, 15, 166, '12:30:00', '13:30:00', 'WIB', ''),
(417, 32, 'Senin', 1, 5, '', '', 2.6, 13, 15, 167, '13:45:00', '14:45:00', 'WIB', ''),
(418, 32, 'Selasa', 2, 1, '', '', 0, 0, 0, 168, '09:00:00', '10:00:00', 'WIB', ''),
(419, 32, 'Selasa', 2, 2, '', '', 3.1, 10, 10, 169, '10:10:00', '11:10:00', 'WIB', ''),
(420, 32, 'Selasa', 2, 3, '', '', 1.6, 5, 5, 170, '11:15:00', '12:15:00', 'WIB', ''),
(421, 32, 'Selasa', 2, 4, '', '', 4.3, 15, 15, 171, '12:30:00', '13:30:00', 'WIB', ''),
(422, 32, 'Selasa', 2, 5, '', '', 2.6, 13, 15, 172, '13:45:00', '14:45:00', 'WIB', ''),
(423, 33, 'Rabu', 1, 1, '', '', 0, 0, 0, 173, '09:00:00', '10:00:00', 'WIB', ''),
(424, 33, 'Rabu', 1, 2, '', '', 3.1, 10, 10, 174, '10:10:00', '11:10:00', 'WIB', ''),
(425, 33, 'Rabu', 1, 3, '', '', 1.6, 5, 5, 175, '11:15:00', '12:15:00', 'WIB', ''),
(426, 33, 'Rabu', 1, 4, '', '', 4.3, 15, 15, 176, '12:30:00', '13:30:00', 'WIB', ''),
(427, 33, 'Rabu', 1, 5, '', '', 2.6, 13, 15, 177, '13:45:00', '14:45:00', 'WIB', ''),
(428, 33, 'Kamis', 2, 1, '', '', 0, 0, 0, 178, '09:00:00', '10:00:00', 'WIB', ''),
(429, 33, 'Kamis', 2, 2, '', '', 3.1, 10, 10, 179, '10:10:00', '11:10:00', 'WIB', ''),
(430, 33, 'Kamis', 2, 3, '', '', 1.6, 5, 5, 180, '11:15:00', '12:15:00', 'WIB', ''),
(431, 33, 'Kamis', 2, 4, '', '', 4.3, 15, 15, 181, '12:30:00', '13:30:00', 'WIB', ''),
(432, 33, 'Kamis', 2, 5, '', '', 2.6, 13, 15, 182, '13:45:00', '14:45:00', 'WIB', ''),
(433, 33, 'Jumat', 3, 1, '', '', 0, 0, 0, 183, '09:00:00', '10:00:00', 'WIB', ''),
(434, 33, 'Jumat', 3, 2, '', '', 3.1, 10, 10, 184, '10:10:00', '11:10:00', 'WIB', ''),
(435, 33, 'Jumat', 3, 3, '', '', 1.6, 5, 5, 185, '11:15:00', '12:15:00', 'WIB', ''),
(436, 33, 'Jumat', 3, 4, '', '', 4.3, 15, 15, 186, '12:30:00', '13:30:00', 'WIB', ''),
(437, 33, 'Jumat', 3, 5, '', '', 2.6, 13, 15, 187, '13:45:00', '14:45:00', 'WIB', ''),
(438, 34, 'Kamis', 1, 1, '', '', 0, 0, 0, 188, '09:00:00', '10:00:00', 'WIB', ''),
(439, 34, 'Kamis', 1, 2, '', '', 3.1, 10, 10, 189, '10:10:00', '11:10:00', 'WIB', ''),
(440, 34, 'Kamis', 1, 3, '', '', 1.6, 5, 5, 190, '11:15:00', '12:15:00', 'WIB', ''),
(441, 34, 'Kamis', 1, 4, '', '', 4.3, 15, 15, 191, '12:30:00', '13:30:00', 'WIB', ''),
(442, 34, 'Kamis', 1, 5, '', '', 2.6, 13, 15, 192, '13:45:00', '14:45:00', 'WIB', ''),
(443, 34, 'Jumat', 2, 1, '', '', 0, 0, 0, 193, '09:00:00', '10:00:00', 'WIB', ''),
(444, 34, 'Jumat', 2, 2, '', '', 3.1, 10, 10, 194, '10:10:00', '11:10:00', 'WIB', ''),
(445, 34, 'Jumat', 2, 3, '', '', 1.6, 5, 5, 195, '11:15:00', '12:15:00', 'WIB', ''),
(446, 34, 'Jumat', 2, 4, '', '', 4.3, 15, 15, 196, '12:30:00', '13:30:00', 'WIB', ''),
(447, 34, 'Jumat', 2, 5, '', '', 2.6, 13, 15, 197, '13:45:00', '14:45:00', 'WIB', ''),
(448, 34, 'Sabtu', 3, 1, '', '', 0, 0, 0, 198, '09:00:00', '10:00:00', 'WIB', ''),
(449, 34, 'Sabtu', 3, 2, '', '', 3.1, 10, 10, 199, '10:10:00', '11:10:00', 'WIB', ''),
(450, 34, 'Sabtu', 3, 3, '', '', 1.6, 5, 5, 200, '11:15:00', '12:15:00', 'WIB', ''),
(451, 34, 'Sabtu', 3, 4, '', '', 4.3, 15, 15, 199, '12:30:00', '13:30:00', 'WIB', ''),
(452, 34, 'Sabtu', 3, 5, '', '', 2.6, 13, 15, 202, '13:45:00', '14:45:00', 'WIB', ''),
(453, 34, 'Minggu', 4, 1, '', '', 0, 0, 0, 203, '09:00:00', '10:00:00', 'WIB', ''),
(454, 34, 'Minggu', 4, 2, '', '', 3.1, 10, 10, 204, '10:10:00', '11:10:00', 'WIB', ''),
(455, 34, 'Minggu', 4, 3, '', '', 1.6, 5, 5, 205, '11:15:00', '12:15:00', 'WIB', ''),
(456, 34, 'Minggu', 4, 4, '', '', 4.3, 15, 15, 206, '12:30:00', '13:30:00', 'WIB', ''),
(457, 34, 'Minggu', 4, 5, '', '', 2.6, 13, 15, 207, '13:45:00', '14:45:00', 'WIB', ''),
(458, 35, 'Minggu', 1, 1, '', '', 0, 0, 0, 158, '09:00:00', '10:00:00', 'WIB', ''),
(459, 35, 'Minggu', 1, 2, '', '', 3.1, 10, 10, 159, '10:10:00', '11:10:00', 'WIB', ''),
(460, 35, 'Minggu', 1, 3, '', '', 1.6, 5, 5, 160, '11:15:00', '12:15:00', 'WIB', ''),
(461, 35, 'Minggu', 1, 4, '', '', 4.3, 15, 15, 161, '12:30:00', '13:30:00', 'WIB', ''),
(462, 35, 'Minggu', 1, 5, '', '', 2.6, 13, 15, 162, '13:45:00', '14:45:00', 'WIB', ''),
(463, 35, 'Senin', 2, 1, '', '', 0, 0, 0, 163, '09:00:00', '10:00:00', 'WIB', ''),
(464, 35, 'Senin', 2, 2, '', '', 3.1, 10, 10, 164, '10:10:00', '11:10:00', 'WIB', ''),
(465, 35, 'Senin', 2, 3, '', '', 1.6, 5, 5, 165, '11:15:00', '12:15:00', 'WIB', ''),
(466, 35, 'Senin', 2, 4, '', '', 4.3, 15, 15, 166, '12:30:00', '13:30:00', 'WIB', ''),
(467, 35, 'Senin', 2, 5, '', '', 2.6, 13, 15, 167, '13:45:00', '14:45:00', 'WIB', ''),
(468, 35, 'Selasa', 3, 1, '', '', 0, 0, 0, 168, '09:00:00', '10:00:00', 'WIB', ''),
(469, 35, 'Selasa', 3, 2, '', '', 3.1, 10, 10, 169, '10:10:00', '11:10:00', 'WIB', ''),
(470, 35, 'Selasa', 3, 3, '', '', 1.6, 5, 5, 170, '11:15:00', '12:15:00', 'WIB', ''),
(471, 35, 'Selasa', 3, 4, '', '', 4.3, 15, 15, 171, '12:30:00', '13:30:00', 'WIB', ''),
(472, 35, 'Selasa', 3, 5, '', '', 2.6, 13, 15, 172, '13:45:00', '14:45:00', 'WIB', ''),
(473, 35, 'Rabu', 4, 1, '', '', 0, 0, 0, 173, '09:00:00', '10:00:00', 'WIB', ''),
(474, 35, 'Rabu', 4, 2, '', '', 3.1, 10, 10, 174, '10:10:00', '11:10:00', 'WIB', ''),
(475, 35, 'Rabu', 4, 3, '', '', 1.6, 5, 5, 175, '11:15:00', '12:15:00', 'WIB', ''),
(476, 35, 'Rabu', 4, 4, '', '', 4.3, 15, 15, 176, '12:30:00', '13:30:00', 'WIB', ''),
(477, 35, 'Rabu', 4, 5, '', '', 2.6, 13, 15, 177, '13:45:00', '14:45:00', 'WIB', ''),
(478, 35, 'Kamis', 5, 1, '', '', 0, 0, 0, 178, '09:00:00', '10:00:00', 'WIB', ''),
(479, 35, 'Kamis', 5, 2, '', '', 3.1, 10, 10, 179, '10:10:00', '11:10:00', 'WIB', ''),
(480, 35, 'Kamis', 5, 3, '', '', 4.3, 15, 15, 180, '12:30:00', '13:30:00', 'WIB', ''),
(481, 35, 'Kamis', 5, 4, '', '', 2.6, 13, 15, 181, '13:45:00', '14:45:00', 'WIB', ''),
(482, 36, 'Selasa', 1, 1, '', '', 0, 0, 0, 182, '09:00:00', '10:00:00', 'WIB', ''),
(483, 36, 'Selasa', 1, 2, '', '', 3.1, 10, 10, 183, '10:10:00', '11:10:00', 'WIB', ''),
(484, 36, 'Selasa', 1, 3, '', '', 1.6, 5, 5, 184, '11:15:00', '12:15:00', 'WIB', ''),
(485, 36, 'Selasa', 1, 4, '', '', 4.3, 15, 15, 185, '12:30:00', '13:30:00', 'WIB', ''),
(486, 36, 'Selasa', 1, 5, '', '', 2.6, 13, 15, 186, '13:45:00', '14:45:00', 'WIB', ''),
(487, 36, 'Rabu', 2, 1, '', '', 0, 0, 0, 187, '09:00:00', '10:00:00', 'WIB', ''),
(488, 36, 'Rabu', 2, 2, '', '', 3.1, 10, 10, 188, '10:10:00', '11:10:00', 'WIB', ''),
(489, 36, 'Rabu', 2, 3, '', '', 1.6, 5, 5, 189, '11:15:00', '12:15:00', 'WIB', ''),
(490, 36, 'Rabu', 2, 4, '', '', 4.3, 15, 15, 190, '12:30:00', '13:30:00', 'WIB', ''),
(491, 36, 'Rabu', 2, 5, '', '', 2.6, 13, 15, 191, '13:45:00', '14:45:00', 'WIB', ''),
(492, 36, 'Kamis', 3, 1, '', '', 0, 0, 0, 192, '09:00:00', '10:00:00', 'WIB', ''),
(493, 36, 'Kamis', 3, 2, '', '', 3.1, 10, 10, 193, '10:10:00', '11:10:00', 'WIB', ''),
(494, 36, 'Kamis', 3, 3, '', '', 1.6, 5, 5, 194, '11:15:00', '12:15:00', 'WIB', ''),
(495, 36, 'Kamis', 3, 4, '', '', 4.3, 15, 15, 195, '12:30:00', '13:30:00', 'WIB', ''),
(496, 36, 'Kamis', 3, 5, '', '', 2.6, 13, 15, 196, '13:45:00', '14:45:00', 'WIB', ''),
(497, 36, 'Jumat', 4, 1, '', '', 0, 0, 0, 197, '09:00:00', '10:00:00', 'WIB', ''),
(498, 36, 'Jumat', 4, 2, '', '', 3.1, 10, 10, 198, '10:10:00', '11:10:00', 'WIB', ''),
(499, 36, 'Jumat', 4, 3, '', '', 1.6, 5, 5, 199, '11:15:00', '12:15:00', 'WIB', ''),
(500, 36, 'Jumat', 4, 4, '', '', 4.3, 15, 15, 200, '12:30:00', '13:30:00', 'WIB', ''),
(501, 36, 'Jumat', 4, 5, '', '', 2.6, 13, 15, 199, '13:45:00', '14:45:00', 'WIB', ''),
(502, 36, 'Sabtu', 5, 1, '', '', 0, 0, 0, 202, '09:00:00', '10:00:00', 'WIB', ''),
(503, 36, 'Sabtu', 5, 2, '', '', 3.1, 10, 10, 203, '10:10:00', '11:10:00', 'WIB', ''),
(504, 36, 'Sabtu', 5, 3, '', '', 1.6, 5, 5, 204, '11:15:00', '12:15:00', 'WIB', ''),
(505, 36, 'Sabtu', 5, 4, '', '', 4.3, 15, 15, 205, '12:30:00', '13:30:00', 'WIB', ''),
(506, 36, 'Sabtu', 5, 5, '', '', 2.6, 13, 15, 206, '13:45:00', '14:45:00', 'WIB', ''),
(507, 36, 'Minggu', 6, 1, '', '', 0, 0, 0, 207, '09:00:00', '10:00:00', 'WIB', ''),
(508, 36, 'Minggu', 6, 2, '', '', 3.1, 10, 10, 158, '10:10:00', '11:10:00', 'WIB', ''),
(509, 36, 'Minggu', 6, 3, '', '', 1.6, 5, 5, 159, '11:15:00', '12:15:00', 'WIB', ''),
(510, 36, 'Minggu', 6, 4, '', '', 4.3, 15, 15, 160, '12:30:00', '13:30:00', 'WIB', ''),
(511, 36, 'Minggu', 6, 5, '', '', 2.6, 13, 15, 162, '13:45:00', '14:45:00', 'WIB', ''),
(512, 37, 'Selasa', 1, 1, '', '', 0, 0, 0, 162, '09:00:00', '10:00:00', 'WIB', ''),
(513, 37, 'Selasa', 1, 2, '', '', 3.1, 10, 10, 163, '10:10:00', '11:10:00', 'WIB', ''),
(514, 37, 'Selasa', 1, 3, '', '', 1.6, 5, 5, 164, '11:15:00', '12:15:00', 'WIB', ''),
(515, 37, 'Selasa', 1, 4, '', '', 4.3, 15, 15, 165, '12:30:00', '13:30:00', 'WIB', ''),
(516, 37, 'Selasa', 1, 5, '', '', 2.6, 13, 15, 166, '13:45:00', '14:45:00', 'WIB', ''),
(517, 38, 'Jumat', 1, 1, '', '', 0, 0, 0, 167, '09:00:00', '10:00:00', 'WIB', ''),
(518, 38, 'Jumat', 1, 2, '', '', 3.1, 10, 10, 168, '10:10:00', '11:10:00', 'WIB', ''),
(519, 38, 'Jumat', 1, 3, '', '', 1.6, 5, 5, 169, '11:15:00', '12:15:00', 'WIB', ''),
(520, 38, 'Jumat', 1, 4, '', '', 4.3, 15, 15, 170, '12:30:00', '13:30:00', 'WIB', ''),
(521, 38, 'Jumat', 1, 5, '', '', 2.6, 13, 15, 171, '13:45:00', '14:45:00', 'WIB', ''),
(522, 38, 'Sabtu', 2, 1, '', '', 0, 0, 0, 172, '09:00:00', '10:00:00', 'WIB', ''),
(523, 38, 'Sabtu', 2, 2, '', '', 3.1, 10, 10, 173, '10:10:00', '11:10:00', 'WIB', ''),
(524, 38, 'Sabtu', 2, 3, '', '', 1.6, 5, 5, 174, '11:15:00', '12:15:00', 'WIB', ''),
(525, 38, 'Sabtu', 2, 4, '', '', 4.3, 15, 15, 175, '12:30:00', '13:30:00', 'WIB', ''),
(526, 38, 'Sabtu', 2, 5, '', '', 2.6, 13, 15, 176, '13:45:00', '14:45:00', 'WIB', ''),
(527, 39, 'Minggu', 1, 1, '', '', 0, 0, 0, 177, '09:00:00', '10:00:00', 'WIB', ''),
(528, 39, 'Minggu', 1, 2, '', '', 3.1, 10, 10, 178, '10:10:00', '11:10:00', 'WIB', ''),
(529, 39, 'Minggu', 1, 3, '', '', 1.6, 5, 5, 179, '11:15:00', '12:15:00', 'WIB', ''),
(530, 39, 'Minggu', 1, 4, '', '', 4.3, 15, 15, 180, '12:30:00', '13:30:00', 'WIB', ''),
(531, 39, 'Minggu', 1, 5, '', '', 2.6, 13, 15, 181, '13:45:00', '14:45:00', 'WIB', ''),
(532, 39, 'Senin', 2, 1, '', '', 0, 0, 0, 182, '09:00:00', '10:00:00', 'WIB', ''),
(533, 39, 'Senin', 2, 2, '', '', 3.1, 10, 10, 183, '10:10:00', '11:10:00', 'WIB', ''),
(534, 39, 'Senin', 2, 3, '', '', 1.6, 5, 5, 184, '11:15:00', '12:15:00', 'WIB', ''),
(535, 39, 'Senin', 2, 4, '', '', 4.3, 15, 15, 185, '12:30:00', '13:30:00', 'WIB', ''),
(536, 39, 'Senin', 2, 5, '', '', 2.6, 13, 15, 186, '13:45:00', '14:45:00', 'WIB', ''),
(537, 39, 'Selasa', 3, 1, '', '', 0, 0, 0, 187, '09:00:00', '10:00:00', 'WIB', ''),
(538, 39, 'Selasa', 3, 2, '', '', 3.1, 10, 10, 188, '10:10:00', '11:10:00', 'WIB', ''),
(539, 39, 'Selasa', 3, 3, '', '', 1.6, 5, 5, 189, '11:15:00', '12:15:00', 'WIB', ''),
(540, 39, 'Selasa', 3, 4, '', '', 4.3, 15, 15, 190, '12:30:00', '13:30:00', 'WIB', ''),
(541, 39, 'Selasa', 3, 5, '', '', 2.6, 13, 15, 191, '13:45:00', '14:45:00', 'WIB', ''),
(542, 40, 'Sabtu', 1, 1, '', '', 0, 0, 0, 192, '09:00:00', '10:00:00', 'WIB', ''),
(543, 40, 'Sabtu', 1, 2, '', '', 3.1, 10, 10, 193, '10:10:00', '11:10:00', 'WIB', ''),
(544, 40, 'Sabtu', 1, 3, '', '', 1.6, 5, 5, 194, '11:15:00', '12:15:00', 'WIB', ''),
(545, 40, 'Sabtu', 1, 4, '', '', 4.3, 15, 15, 195, '12:30:00', '13:30:00', 'WIB', ''),
(546, 40, 'Sabtu', 1, 5, '', '', 2.6, 13, 15, 196, '13:45:00', '14:45:00', 'WIB', ''),
(547, 40, 'Minggu', 2, 1, '', '', 0, 0, 0, 197, '09:00:00', '10:00:00', 'WIB', ''),
(548, 40, 'Minggu', 2, 2, '', '', 3.1, 10, 10, 198, '10:10:00', '11:10:00', 'WIB', ''),
(549, 40, 'Minggu', 2, 3, '', '', 1.6, 5, 5, 199, '11:15:00', '12:15:00', 'WIB', ''),
(550, 40, 'Minggu', 2, 4, '', '', 4.3, 15, 15, 200, '12:30:00', '13:30:00', 'WIB', ''),
(551, 40, 'Minggu', 2, 5, '', '', 2.6, 13, 15, 199, '13:45:00', '14:45:00', 'WIB', ''),
(552, 40, 'Senin', 3, 1, '', '', 0, 0, 0, 202, '09:00:00', '10:00:00', 'WIB', ''),
(553, 40, 'Senin', 3, 2, '', '', 3.1, 10, 10, 203, '10:10:00', '11:10:00', 'WIB', ''),
(554, 40, 'Senin', 3, 3, '', '', 1.6, 5, 5, 204, '11:15:00', '12:15:00', 'WIB', ''),
(555, 40, 'Senin', 3, 4, '', '', 4.3, 15, 15, 205, '12:30:00', '13:30:00', 'WIB', ''),
(556, 40, 'Senin', 3, 5, '', '', 2.6, 13, 15, 206, '13:45:00', '14:45:00', 'WIB', ''),
(557, 40, 'Selasa', 4, 1, '', '', 0, 0, 0, 207, '09:00:00', '10:00:00', 'WIB', ''),
(558, 40, 'Selasa', 4, 2, '', '', 3.1, 10, 10, 158, '10:10:00', '11:10:00', 'WIB', ''),
(559, 40, 'Selasa', 4, 3, '', '', 1.6, 5, 5, 159, '11:15:00', '12:15:00', 'WIB', ''),
(560, 40, 'Selasa', 4, 4, '', '', 4.3, 15, 15, 160, '12:30:00', '13:30:00', 'WIB', ''),
(561, 40, 'Selasa', 4, 5, '', '', 2.6, 13, 15, 161, '13:45:00', '14:45:00', 'WIB', ''),
(562, 41, 'Rabu', 1, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(563, 41, 'Rabu', 1, 2, '', '', 4.4, 20, 20, 2, '08:20:00', '10:40:00', 'WIB', ''),
(564, 41, 'Rabu', 1, 3, '', '', 4.9, 19, 20, 49, '11:00:00', '13:20:00', 'WIB', ''),
(565, 41, 'Rabu', 1, 4, '', '', 4.1, 51, 55, 50, '14:15:00', '16:35:00', 'WIB', ''),
(566, 42, 'Senin', 1, 1, '', '', 0, 0, 0, 2, '06:00:00', '08:00:00', 'WIB', ''),
(567, 42, 'Senin', 1, 2, '', '', 4.4, 20, 20, 3, '08:20:00', '10:40:00', 'WIB', ''),
(568, 42, 'Senin', 1, 3, '', '', 4.9, 19, 20, 4, '11:00:00', '13:20:00', 'WIB', ''),
(569, 42, 'Senin', 1, 4, '', '', 4.1, 51, 55, 5, '14:15:00', '16:35:00', 'WIB', ''),
(570, 42, 'Selasa', 2, 1, '', '', 0, 0, 0, 65, '09:00:00', '10:00:00', 'WIB', ''),
(571, 42, 'Selasa', 2, 2, '', '', 4.4, 20, 20, 66, '10:20:00', '11:40:00', 'WIB', ''),
(572, 42, 'Selasa', 2, 3, '', '', 4.9, 19, 20, 67, '12:00:00', '13:20:00', 'WIB', ''),
(573, 42, 'Selasa', 2, 4, '', '', 4.1, 51, 55, 69, '14:15:00', '16:35:00', 'WIB', ''),
(574, 43, 'Minggu', 1, 1, '', '', 0, 0, 0, 17, '09:00:00', '11:00:00', 'WIB', ''),
(575, 43, 'Minggu', 1, 2, '', '', 4.4, 20, 20, 18, '11:20:00', '13:40:00', 'WIB', ''),
(576, 43, 'Minggu', 1, 3, '', '', 4.9, 19, 20, 19, '14:00:00', '15:20:00', 'WIB', ''),
(577, 43, 'Minggu', 1, 4, '', '', 4.1, 51, 55, 20, '16:15:00', '17:15:00', 'WIB', ''),
(578, 43, 'Senin', 2, 1, '', '', 0, 0, 0, 2, '09:00:00', '11:00:00', 'WIB', ''),
(579, 43, 'Senin', 2, 2, '', '', 4.4, 20, 20, 3, '11:20:00', '13:40:00', 'WIB', ''),
(580, 43, 'Senin', 2, 3, '', '', 4.9, 19, 20, 56, '14:00:00', '15:20:00', 'WIB', ''),
(581, 43, 'Senin', 2, 4, '', '', 4.1, 51, 55, 55, '16:15:00', '17:15:00', 'WIB', ''),
(582, 43, 'Selasa', 3, 1, '', '', 0, 0, 0, 53, '09:00:00', '10:00:00', 'WIB', ''),
(583, 43, 'Selasa', 3, 2, '', '', 4.4, 20, 20, 52, '10:20:00', '11:40:00', 'WIB', ''),
(584, 43, 'Selasa', 3, 3, '', '', 4.9, 19, 20, 56, '12:00:00', '13:20:00', 'WIB', ''),
(585, 43, 'Selasa', 3, 4, '', '', 4.1, 51, 55, 54, '14:15:00', '16:35:00', 'WIB', ''),
(586, 44, 'Rabu', 1, 1, '', '', 0, 0, 0, 1, '06:00:00', '08:00:00', 'WIB', ''),
(587, 44, 'Rabu', 1, 2, '', '', 4.4, 20, 20, 2, '08:20:00', '10:40:00', 'WIB', ''),
(588, 44, 'Rabu', 1, 3, '', '', 4.9, 19, 20, 4, '11:00:00', '13:20:00', 'WIB', ''),
(589, 44, 'Rabu', 1, 4, '', '', 4.1, 51, 55, 5, '14:15:00', '16:35:00', 'WIB', ''),
(590, 44, 'Kamis', 2, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(591, 44, 'Kamis', 2, 2, '', '', 7.2, 25, 25, 7, '10:25:00', '11:45:00', 'WIB', ''),
(592, 44, 'Kamis', 2, 3, '', '', 3.7, 31, 35, 8, '12:20:00', '14:40:00', 'WIB', ''),
(593, 44, 'Kamis', 2, 4, '', '', 2.2, 10, 10, 5, '14:50:00', '17:10:00', 'WIB', ''),
(594, 44, 'Jumat', 3, 1, '', '', 0, 0, 0, 58, '06:00:00', '08:00:00', 'WIB', ''),
(595, 44, 'Jumat', 3, 2, '', '', 9.5, 30, 30, 57, '08:30:00', '10:50:00', 'WIB', ''),
(596, 44, 'Jumat', 3, 3, '', '', 7.3, 13, 15, 59, '11:05:00', '13:25:00', 'WIB', ''),
(597, 44, 'Jumat', 3, 4, '', '', 7, 10, 10, 60, '13:35:00', '15:55:00', 'WIB', ''),
(598, 44, 'Sabtu', 4, 1, '', '', 0, 0, 0, 61, '09:00:00', '10:00:00', 'WIB', '');
INSERT INTO `jadwal_destinasi` (`id_jadwaldestinasi`, `id_paketdestinasi`, `hari`, `hari_ke`, `destinasi_ke`, `koordinat_berangkat`, `koordinat_tiba`, `jarak_tempuh`, `waktu_tempuh`, `waktu_sebenarnya`, `id_destinasi`, `jam_mulai`, `jam_selesai`, `jam_lokasi`, `catatan`) VALUES
(599, 44, 'Sabtu', 4, 2, '', '', 3.1, 10, 10, 62, '10:10:00', '11:10:00', 'WIB', ''),
(600, 44, 'Sabtu', 4, 3, '', '', 1.6, 5, 5, 63, '11:15:00', '12:15:00', 'WIB', ''),
(601, 44, 'Sabtu', 4, 4, '', '', 4.3, 15, 15, 64, '12:30:00', '13:30:00', 'WIB', ''),
(602, 44, 'Sabtu', 4, 5, '', '', 2.6, 13, 15, 65, '13:45:00', '14:45:00', 'WIB', ''),
(603, 45, 'Senin', 1, 1, '', '', 0, 0, 0, 2, '06:00:00', '08:00:00', 'WIB', ''),
(604, 45, 'Senin', 1, 2, '', '', 4.4, 20, 20, 3, '08:20:00', '10:40:00', 'WIB', ''),
(605, 45, 'Senin', 1, 3, '', '', 4.9, 19, 20, 4, '11:00:00', '13:20:00', 'WIB', ''),
(606, 45, 'Senin', 1, 4, '', '', 4.1, 51, 55, 5, '14:15:00', '16:35:00', 'WIB', ''),
(607, 45, 'Selasa', 2, 1, '', '', 0, 0, 0, 6, '09:00:00', '10:00:00', 'WIB', ''),
(608, 45, 'Selasa', 2, 2, '', '', 4.4, 20, 20, 7, '10:20:00', '11:40:00', 'WIB', ''),
(609, 45, 'Selasa', 2, 3, '', '', 4.9, 19, 20, 10, '12:00:00', '13:20:00', 'WIB', ''),
(610, 45, 'Selasa', 2, 4, '', '', 4.1, 51, 55, 11, '14:15:00', '16:35:00', 'WIB', ''),
(611, 45, 'Rabu', 3, 1, '', '', 0, 0, 0, 12, '08:00:00', '09:00:00', 'WIB', ''),
(612, 45, 'Rabu', 3, 2, '', '', 4.4, 20, 20, 13, '09:20:00', '10:40:00', 'WIB', ''),
(613, 45, 'Rabu', 3, 3, '', '', 4.9, 19, 20, 66, '11:00:00', '13:20:00', 'WIB', ''),
(614, 45, 'Rabu', 3, 4, '', '', 4.1, 51, 55, 67, '14:15:00', '15:35:00', 'WIB', ''),
(615, 45, 'Kamis', 4, 1, '', '', 0, 0, 0, 69, '09:00:00', '10:00:00', 'WIB', ''),
(616, 45, 'Kamis', 4, 2, '', '', 4.4, 20, 20, 65, '10:20:00', '11:40:00', 'WIB', ''),
(617, 45, 'Kamis', 4, 3, '', '', 4.9, 19, 20, 70, '12:00:00', '13:20:00', 'WIB', ''),
(618, 45, 'Kamis', 4, 4, '', '', 4.1, 51, 55, 71, '14:15:00', '16:35:00', 'WIB', ''),
(619, 45, 'Jumat', 5, 1, '', '', 0, 0, 0, 72, '06:00:00', '08:00:00', 'WIB', ''),
(620, 45, 'Jumat', 5, 2, '', '', 9.5, 30, 30, 74, '08:30:00', '10:50:00', 'WIB', ''),
(621, 45, 'Jumat', 5, 3, '', '', 7.3, 13, 15, 73, '11:05:00', '13:25:00', 'WIB', ''),
(622, 45, 'Jumat', 5, 4, '', '', 7, 10, 10, 75, '13:35:00', '15:55:00', 'WIB', ''),
(623, 46, 'Sabtu', 1, 1, '', '', 0, 0, 0, 102, '09:00:00', '10:00:00', 'WIB', ''),
(624, 46, 'Sabtu', 1, 2, '', '', 3.1, 10, 10, 103, '10:10:00', '11:10:00', 'WIB', ''),
(625, 46, 'Sabtu', 1, 3, '', '', 1.6, 5, 5, 160, '11:15:00', '12:15:00', 'WIB', ''),
(626, 46, 'Sabtu', 1, 4, '', '', 4.3, 15, 15, 161, '12:30:00', '13:30:00', 'WIB', ''),
(627, 46, 'Sabtu', 1, 5, '', '', 2.6, 13, 15, 162, '13:45:00', '14:45:00', 'WIB', ''),
(628, 47, 'Senin', 1, 1, '', '', 0, 0, 0, 104, '09:00:00', '10:00:00', 'WIB', ''),
(629, 47, 'Senin', 1, 2, '', '', 3.1, 10, 10, 105, '10:10:00', '11:10:00', 'WIB', ''),
(630, 47, 'Senin', 1, 3, '', '', 1.6, 5, 5, 106, '11:15:00', '12:15:00', 'WIB', ''),
(631, 47, 'Senin', 1, 4, '', '', 4.3, 15, 15, 107, '12:30:00', '13:30:00', 'WIB', ''),
(632, 47, 'Senin', 1, 5, '', '', 2.6, 13, 15, 108, '13:45:00', '14:45:00', 'WIB', ''),
(633, 47, 'Selasa', 2, 1, '', '', 0, 0, 0, 168, '09:00:00', '10:00:00', 'WIB', ''),
(634, 47, 'Selasa', 2, 2, '', '', 3.1, 10, 10, 169, '10:10:00', '11:10:00', 'WIB', ''),
(635, 47, 'Selasa', 2, 3, '', '', 1.6, 5, 5, 170, '11:15:00', '12:15:00', 'WIB', ''),
(636, 47, 'Selasa', 2, 4, '', '', 4.3, 15, 15, 171, '12:30:00', '13:30:00', 'WIB', ''),
(637, 47, 'Selasa', 2, 5, '', '', 2.6, 13, 15, 172, '13:45:00', '14:45:00', 'WIB', ''),
(638, 48, 'Rabu', 1, 1, '', '', 0, 0, 0, 109, '09:00:00', '10:00:00', 'WIB', ''),
(639, 48, 'Rabu', 1, 2, '', '', 3.1, 10, 10, 110, '10:10:00', '11:10:00', 'WIB', ''),
(640, 48, 'Rabu', 1, 3, '', '', 1.6, 5, 5, 106, '11:15:00', '12:15:00', 'WIB', ''),
(641, 48, 'Rabu', 1, 4, '', '', 4.3, 15, 15, 112, '12:30:00', '13:30:00', 'WIB', ''),
(642, 48, 'Rabu', 1, 5, '', '', 2.6, 13, 15, 113, '13:45:00', '14:45:00', 'WIB', ''),
(643, 48, 'Kamis', 2, 1, '', '', 0, 0, 0, 114, '09:00:00', '10:00:00', 'WIB', ''),
(644, 48, 'Kamis', 2, 2, '', '', 3.1, 10, 10, 115, '10:10:00', '11:10:00', 'WIB', ''),
(645, 48, 'Kamis', 2, 3, '', '', 1.6, 5, 5, 116, '11:15:00', '12:15:00', 'WIB', ''),
(646, 48, 'Kamis', 2, 4, '', '', 4.3, 15, 15, 181, '12:30:00', '13:30:00', 'WIB', ''),
(647, 48, 'Kamis', 2, 5, '', '', 2.6, 13, 15, 182, '13:45:00', '14:45:00', 'WIB', ''),
(648, 48, 'Jumat', 3, 1, '', '', 0, 0, 0, 183, '09:00:00', '10:00:00', 'WIB', ''),
(649, 48, 'Jumat', 3, 2, '', '', 3.1, 10, 10, 184, '10:10:00', '11:10:00', 'WIB', ''),
(650, 48, 'Jumat', 3, 3, '', '', 1.6, 5, 5, 185, '11:15:00', '12:15:00', 'WIB', ''),
(651, 48, 'Jumat', 3, 4, '', '', 4.3, 15, 15, 186, '12:30:00', '13:30:00', 'WIB', ''),
(652, 48, 'Jumat', 3, 5, '', '', 2.6, 13, 15, 187, '13:45:00', '14:45:00', 'WIB', ''),
(653, 49, 'Kamis', 1, 1, '', '', 0, 0, 0, 117, '09:00:00', '10:00:00', 'WIB', ''),
(654, 49, 'Kamis', 1, 2, '', '', 3.1, 10, 10, 118, '10:10:00', '11:10:00', 'WIB', ''),
(655, 49, 'Kamis', 1, 3, '', '', 1.6, 5, 5, 119, '11:15:00', '12:15:00', 'WIB', ''),
(656, 49, 'Kamis', 1, 4, '', '', 4.3, 15, 15, 120, '12:30:00', '13:30:00', 'WIB', ''),
(657, 49, 'Kamis', 1, 5, '', '', 2.6, 13, 15, 121, '13:45:00', '14:45:00', 'WIB', ''),
(658, 49, 'Jumat', 2, 1, '', '', 0, 0, 0, 122, '09:00:00', '10:00:00', 'WIB', ''),
(659, 49, 'Jumat', 2, 2, '', '', 3.1, 10, 10, 123, '10:10:00', '11:10:00', 'WIB', ''),
(660, 49, 'Jumat', 2, 3, '', '', 1.6, 5, 5, 124, '11:15:00', '12:15:00', 'WIB', ''),
(661, 49, 'Jumat', 2, 4, '', '', 4.3, 15, 15, 125, '12:30:00', '13:30:00', 'WIB', ''),
(662, 49, 'Jumat', 2, 5, '', '', 2.6, 13, 15, 126, '13:45:00', '14:45:00', 'WIB', ''),
(663, 49, 'Sabtu', 3, 1, '', '', 0, 0, 0, 198, '09:00:00', '10:00:00', 'WIB', ''),
(664, 49, 'Sabtu', 3, 2, '', '', 3.1, 10, 10, 199, '10:10:00', '11:10:00', 'WIB', ''),
(665, 49, 'Sabtu', 3, 3, '', '', 1.6, 5, 5, 200, '11:15:00', '12:15:00', 'WIB', ''),
(666, 49, 'Sabtu', 3, 4, '', '', 4.3, 15, 15, 196, '12:30:00', '13:30:00', 'WIB', ''),
(667, 49, 'Sabtu', 3, 5, '', '', 2.6, 13, 15, 202, '13:45:00', '14:45:00', 'WIB', ''),
(668, 49, 'Minggu', 4, 1, '', '', 0, 0, 0, 203, '09:00:00', '10:00:00', 'WIB', ''),
(669, 49, 'Minggu', 4, 2, '', '', 3.1, 10, 10, 204, '10:10:00', '11:10:00', 'WIB', ''),
(670, 49, 'Minggu', 4, 3, '', '', 1.6, 5, 5, 205, '11:15:00', '12:15:00', 'WIB', ''),
(671, 49, 'Minggu', 4, 4, '', '', 4.3, 15, 15, 206, '12:30:00', '13:30:00', 'WIB', ''),
(672, 49, 'Minggu', 4, 5, '', '', 2.6, 13, 15, 207, '13:45:00', '14:45:00', 'WIB', ''),
(673, 50, 'Minggu', 1, 1, '', '', 0, 0, 0, 127, '09:00:00', '10:00:00', 'WIB', ''),
(674, 50, 'Minggu', 1, 2, '', '', 3.1, 10, 10, 128, '10:10:00', '11:10:00', 'WIB', ''),
(675, 50, 'Minggu', 1, 3, '', '', 1.6, 5, 5, 129, '11:15:00', '12:15:00', 'WIB', ''),
(676, 50, 'Minggu', 1, 4, '', '', 4.3, 15, 15, 130, '12:30:00', '13:30:00', 'WIB', ''),
(677, 50, 'Minggu', 1, 5, '', '', 2.6, 13, 15, 131, '13:45:00', '14:45:00', 'WIB', ''),
(678, 50, 'Senin', 2, 1, '', '', 0, 0, 0, 132, '09:00:00', '10:00:00', 'WIB', ''),
(679, 50, 'Senin', 2, 2, '', '', 3.1, 10, 10, 133, '10:10:00', '11:10:00', 'WIB', ''),
(680, 50, 'Senin', 2, 3, '', '', 1.6, 5, 5, 134, '11:15:00', '12:15:00', 'WIB', ''),
(681, 50, 'Senin', 2, 4, '', '', 4.3, 15, 15, 135, '12:30:00', '13:30:00', 'WIB', ''),
(682, 50, 'Senin', 2, 5, '', '', 2.6, 13, 15, 136, '13:45:00', '14:45:00', 'WIB', ''),
(683, 50, 'Selasa', 3, 1, '', '', 0, 0, 0, 137, '09:00:00', '10:00:00', 'WIB', ''),
(684, 50, 'Selasa', 3, 2, '', '', 3.1, 10, 10, 138, '10:10:00', '11:10:00', 'WIB', ''),
(685, 50, 'Selasa', 3, 3, '', '', 1.6, 5, 5, 139, '11:15:00', '12:15:00', 'WIB', ''),
(686, 50, 'Selasa', 3, 4, '', '', 4.3, 15, 15, 171, '12:30:00', '13:30:00', 'WIB', ''),
(687, 50, 'Selasa', 3, 5, '', '', 2.6, 13, 15, 172, '13:45:00', '14:45:00', 'WIB', ''),
(688, 50, 'Rabu', 4, 1, '', '', 0, 0, 0, 173, '09:00:00', '10:00:00', 'WIB', ''),
(689, 50, 'Rabu', 4, 2, '', '', 3.1, 10, 10, 174, '10:10:00', '11:10:00', 'WIB', ''),
(690, 50, 'Rabu', 4, 3, '', '', 1.6, 5, 5, 175, '11:15:00', '12:15:00', 'WIB', ''),
(691, 50, 'Rabu', 4, 4, '', '', 4.3, 15, 15, 176, '12:30:00', '13:30:00', 'WIB', ''),
(692, 50, 'Rabu', 4, 5, '', '', 2.6, 13, 15, 177, '13:45:00', '14:45:00', 'WIB', ''),
(693, 50, 'Kamis', 5, 1, '', '', 0, 0, 0, 178, '09:00:00', '10:00:00', 'WIB', ''),
(694, 50, 'Kamis', 5, 2, '', '', 3.1, 10, 10, 179, '10:10:00', '11:10:00', 'WIB', ''),
(695, 50, 'Kamis', 5, 3, '', '', 4.3, 15, 15, 180, '12:30:00', '13:30:00', 'WIB', ''),
(696, 50, 'Kamis', 5, 4, '', '', 2.6, 13, 15, 181, '13:45:00', '14:45:00', 'WIB', '');

--
-- Triggers `jadwal_destinasi`
--
DELIMITER $$
CREATE TRIGGER `cek_delete_jadwal_destinasi` BEFORE DELETE ON `jadwal_destinasi` FOR EACH ROW BEGIN
    DECLARE last_hari_ke INT;
    DECLARE count_destinasi_ke INT;
    
    SELECT MAX(hari_ke) INTO last_hari_ke
    FROM jadwal_destinasi
    WHERE id_paketdestinasi = OLD.id_paketdestinasi
    GROUP BY id_paketdestinasi;
    SELECT COUNT(destinasi_ke) INTO count_destinasi_ke
    FROM jadwal_destinasi
    WHERE id_paketdestinasi = OLD.id_paketdestinasi AND hari_ke = OLD.hari_ke;
    
    IF OLD.hari_ke != last_hari_ke AND count_destinasi_ke = 1 THEN
		SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = 'DELETE hari seutuhnya hanya berlaku pada hari terakhir wisata'; -- Verifikasi
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `cek_insert_jadwal_destinasi` BEFORE INSERT ON `jadwal_destinasi` FOR EACH ROW BEGIN
	DECLARE last_hari VARCHAR(20);
	DECLARE last_hari_ke INT;
    DECLARE last_jam_mulai TIME;
    DECLARE last_jam_selesai TIME;
    DECLARE jam_mulai_seharusnya TIME;
    DECLARE jam_buka_destinasi TIME;
    DECLARE jam_tutup_destinasi TIME;
    DECLARE hitung_waktu_sebenarnya INT DEFAULT 0;
    DECLARE detect_hari INT;
    DECLARE cek_id_paketdestinasi INT;

    
	SET cek_id_paketdestinasi = (SELECT DISTINCT id_paketdestinasi FROM jadwal_destinasi WHERE id_paketdestinasi = NEW.id_paketdestinasi);
	
	-- Jika id_paketdestinasi belum ada atau sedang menginput id_paketdestinasi yang baru
	IF cek_id_paketdestinasi IS NULL THEN 
		-- 1. Mengatur nilai awal 'hari_ke' ketika 'id_paketdestinasi' yang baru dimasukkan
		SET NEW.hari_ke = 1;
		SET NEW.destinasi_ke = 1;
        SET NEW.jarak_tempuh = 0;
        SET NEW.waktu_tempuh = 0;
        
        -- Menolak input 'jam_mulai' dan 'jam_selesai' yang tumpang tindih
		IF NEW.jam_mulai > NEW.jam_selesai THEN
			SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Input jam_mulai dan jam_selesai tumpang tindih';
		END IF;
	END IF;
	
	-- Jika sudah ada id_paketdestinasi yang sama di tabel jadwal_destinasi dengan input id_paketdestinasi
	IF NEW.id_paketdestinasi = cek_id_paketdestinasi THEN
		-- 2. Menolak input 'hari' yang tidak berurutan atau tidak sama dengan sebelumnya
		SELECT hari, hari_ke INTO last_hari, last_hari_ke FROM jadwal_destinasi
		WHERE id_paketdestinasi = NEW.id_paketdestinasi ORDER BY hari_ke DESC LIMIT 1;
		SELECT COUNT(hari) INTO detect_hari FROM jadwal_destinasi WHERE id_paketdestinasi = NEW.id_paketdestinasi AND hari = NEW.hari;

		IF (NEW.hari != CASE last_hari
							WHEN 'Senin' THEN 'Selasa'
							WHEN 'Selasa' THEN 'Rabu'
							WHEN 'Rabu' THEN 'Kamis'
							WHEN 'Kamis' THEN 'Jumat'
							WHEN 'Jumat' THEN 'Sabtu'
							WHEN 'Sabtu' THEN 'Minggu'
							WHEN 'Minggu' THEN 'Senin'
							ELSE 'Senin'
							END) AND detect_hari = 0 THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Input hari tidak berurutan';
		END IF;
		
		-- 3. Increment 'hari_ke' ketika input 'hari' berubah
		IF detect_hari = 0 THEN
			SET NEW.hari_ke = last_hari_ke + 1;
		END IF;
		IF detect_hari > 0 THEN
			SET NEW.hari_ke = (SELECT hari_ke FROM jadwal_destinasi WHERE id_paketdestinasi = NEW.id_paketdestinasi AND hari = NEW.hari LIMIT 1);
		END IF;
		
		-- 4. Increment 'destinasi_ke' ketika input 'hari' masih sama dan atur ulang ke 1 jika input 'hari' telah berbeda
		IF detect_hari > 0 THEN 
			SET NEW.destinasi_ke = detect_hari + 1;
		END IF;
		IF detect_hari = 0 THEN 
			SET NEW.destinasi_ke = 1;
		END IF;
		
		-- 5. Menolak input jarak_tempuh dan waktu_tempuh bukan 0 pada destinasi_ke 1
		IF NEW.destinasi_ke = 1 AND (NEW.jarak_tempuh != 0 OR NEW.waktu_tempuh != 0) THEN
			SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Input jarak_tempuh dan waktu_tempuh pada destinasi_ke 1 harus bernilai 0';
		END IF;
		
		-- 6. Menolak input 'jam_mulai' dan 'jam_selesai' yang tumpang tindih
		IF detect_hari > 0 THEN 
			SELECT jam_mulai, jam_selesai INTO last_jam_mulai, last_jam_selesai
			FROM jadwal_destinasi WHERE id_paketdestinasi = NEW.id_paketdestinasi AND hari_ke = NEW.hari_ke AND destinasi_ke = NEW.destinasi_ke - 1;
			IF NEW.jam_mulai < last_jam_selesai OR NEW.jam_selesai < last_jam_mulai OR NEW.jam_mulai > NEW.jam_selesai THEN
				SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Input jam_mulai dan jam_selesai tumpang tindih';
			END IF;
		END IF;
		
		-- 7. Menolak input 'jarak_tempuh' dan 'waktu_tempuh' bernilai negatif
		IF NEW.jarak_tempuh < 0 OR NEW.waktu_tempuh < 0 THEN
			SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'Input jarak_tempuh atau waktu_tempuh tidak boleh negatif';
		END IF;

		-- 8. Mengotomatiskan nilai waktu_sebenarnya
		IF detect_hari > 0 THEN
			SET hitung_waktu_sebenarnya = NEW.waktu_tempuh;
		END IF;
		IF (hitung_waktu_sebenarnya % 10) < 5 AND (hitung_waktu_sebenarnya % 10) != 0 THEN
			SET hitung_waktu_sebenarnya = hitung_waktu_sebenarnya + (5 - (hitung_waktu_sebenarnya % 10)); -- Membulatkan ke atas jika digit terakhir < 5
		END IF;
		IF (hitung_waktu_sebenarnya % 10) > 5 THEN
			SET hitung_waktu_sebenarnya = hitung_waktu_sebenarnya + (10 - (hitung_waktu_sebenarnya % 10)); -- Membulatkan ke puluhan jika digit terakhir > 5
		END IF;
		SET NEW.waktu_sebenarnya = hitung_waktu_sebenarnya;
		
		-- 9. Memastikan jadwal 'jam_mulai' tidak kurang dari perhitungan waktu_sebenarnya
		IF detect_hari > 0 THEN
			SET jam_mulai_seharusnya = SEC_TO_TIME(TIME_TO_SEC(last_jam_selesai) + (hitung_waktu_sebenarnya * 60));
			IF NEW.jam_mulai < jam_mulai_seharusnya THEN
				SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'Input jam_mulai tidak sesuai dengan perhitungan waktu_tempuh atau waktu_sebenarnya';
			END IF;
		END IF;
	END IF;
	
	-- 10. Menolak input 'hari' yang ada di tabel destinasi_tutup
	IF EXISTS (SELECT 1 FROM destinasi_tutup WHERE id_destinasi = NEW.id_destinasi AND hari_tutup = NEW.hari) THEN
		SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'Destinasi tutup pada hari yang dipilih';
	END IF;
	
	-- 11. Menolak input 'jam_mulai' dan 'jam_selesai' yang destinasinya masih jam tutup
	SELECT jam_buka, jam_tutup INTO jam_buka_destinasi, jam_tutup_destinasi FROM destinasi WHERE id_destinasi = NEW.id_destinasi; 
	IF NEW.jam_mulai < jam_buka_destinasi OR NEW.jam_selesai > jam_tutup_destinasi THEN
		SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'Input jam_mulai dan jam_selesai tidak sesuai dengan jam layanan destinasi';
	END IF;
    
    -- 12. Menolak durasi wisata kurang dari 15 menit
	IF TIME_TO_SEC(NEW.jam_mulai) > (TIME_TO_SEC(NEW.jam_selesai) - 15 * 60) THEN
		SIGNAL SQLSTATE '45023' SET MESSAGE_TEXT = 'Durasi wisata terlalu cepat. Minimal 15 menit';
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `cek_update_jadwal_destinasi` BEFORE UPDATE ON `jadwal_destinasi` FOR EACH ROW BEGIN
	DECLARE durasi_berkunjung INT;
    DECLARE durasi_berkunjung_setelahnya INT;
    DECLARE durasi_berkunjung_sebelumnya INT;
    DECLARE perubahan_waktu_tempuh INT;
    DECLARE jam_buka_destinasi TIME;
    DECLARE jam_tutup_destinasi TIME;
    DECLARE last_destinasi_ke INT;

	-- 1. Memastikan yang hanya bisa di-update adalah destinasi_ke, jarak_tempuh, waktu_tempuh, waktu_sebenarnya, id_testinasi, jam_mulai, jam_selesai, jam_lokasi, catatan.
	IF NEW.id_jadwaldestinasi != OLD.id_jadwaldestinasi OR
	NEW.id_paketdestinasi != OLD.id_paketdestinasi OR
    NEW.hari != OLD.hari OR
    NEW.hari_ke != OLD.hari_ke
    THEN
        SIGNAL SQLSTATE '45009'
        SET MESSAGE_TEXT = 'Anda tidak diizinkan untuk mengupdate kolom id_jadwaldestinasi, id_paketdestinasi, hari, dan hari_ke.';
    END IF; 
    
    -- 2. Tidak diijinkan mengubah jarak_tempuh dan waktu_tempuh pada destinasi_ke 1
    IF NEW.destinasi_ke = 1 AND (NEW.jarak_tempuh != OLD.jarak_tempuh OR NEW.waktu_tempuh != OLD.waktu_tempuh) THEN
		SIGNAL SQLSTATE '45010'
        SET MESSAGE_TEXT = 'Tidak diijinkan mengubah jarak_tempuh dan waktu_tempuh pada destinasi_ke 1.';
    END IF; 
    
    -- 3. Menolak input 'jarak_tempuh' bernilai negatif
	IF NEW.jarak_tempuh < 0 THEN
		SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = 'Update nilai jarak_tempuh tidak boleh negatif';
	END IF; 
    
    -- 4. Jika waktu_tempuh bertambah, memastikan perubahan pada waktu_tempuh tidak lebih dari durasi berkunjung jam_mulai dan jam_selesai. Serta tidak boleh negatif.
    SET durasi_berkunjung = TIME_TO_SEC(TIMEDIFF(OLD.jam_selesai, OLD.jam_mulai)) / 60;
    SET perubahan_waktu_tempuh = NEW.waktu_tempuh - OLD.waktu_tempuh + 10;
    IF NEW.waktu_tempuh < 0 THEN
		SIGNAL SQLSTATE '45012'
        SET MESSAGE_TEXT = 'Update nilai waktu_tempuh tidak boleh negatif.';
    END IF;
    IF perubahan_waktu_tempuh > durasi_berkunjung THEN
		SIGNAL SQLSTATE '45013'
        SET MESSAGE_TEXT = 'Pertambahan nilai pada waktu_tempuh terlalu besar sehingga durasi berkunjung destinasi terlalu cepat.';
    END IF; 
    
    -- 5. Memastikan id_destinasi yang diganti masih dalam hari dan jam layanan. 
    --    Jadi, pemilihan id_destinasi sangat bergantung pada hari, jam_mulai, dan jam_selesai pada nilai kolom yang ada.
    -- Menolak update id_destinasi yang hari layanan tutup berdasarkan di tabel destinasi_tutup
	IF EXISTS (SELECT 1 FROM destinasi_tutup WHERE id_destinasi = NEW.id_destinasi AND hari_tutup = OLD.hari) THEN
		SIGNAL SQLSTATE '45014' SET MESSAGE_TEXT = 'Destinasi tutup pada hari yang dipilih';
	END IF;
	-- Menolak update id_destinasi yang 'jam_mulai' dan 'jam_selesai' nya termasuk jam tutup destinasi
    SET jam_buka_destinasi = (SELECT jam_buka FROM destinasi WHERE id_destinasi = NEW.id_destinasi);
    SET jam_tutup_destinasi = (SELECT jam_tutup FROM destinasi WHERE id_destinasi = NEW.id_destinasi);
	IF OLD.jam_mulai < jam_buka_destinasi OR OLD.jam_selesai > jam_tutup_destinasi THEN
		SIGNAL SQLSTATE '45015' SET MESSAGE_TEXT = 'Input id_destinasi tidak sesuai dengan jam layanan destinasi';
	END IF;
    
    -- 6. Menjaga konsistensi jadwal pada jam_mulai dan jam_selesai:
    SET last_destinasi_ke = (SELECT MAX(destinasi_ke) FROM jadwal_destinasi 
    WHERE id_paketdestinasi = OLD.id_paketdestinasi AND hari = OLD.hari AND hari_ke = OLD.hari_ke ORDER BY hari_ke);
    
    -- TENTUNYA SAAT MENGUBAH jam_mulai dan jam_selesai PASTIKAN MASIH DI DALAM JAM LAYANAN DESTINASI !!!
    SET jam_buka_destinasi = (SELECT jam_buka FROM destinasi WHERE id_destinasi = OLD.id_destinasi);
    SET jam_tutup_destinasi = (SELECT jam_tutup FROM destinasi WHERE id_destinasi = OLD.id_destinasi);
	IF NEW.jam_mulai < jam_buka_destinasi OR NEW.jam_selesai > jam_tutup_destinasi THEN
		SIGNAL SQLSTATE '45016' SET MESSAGE_TEXT = 'Input jam_mulai atau jam_selesai tidak sesuai dengan jam layanan destinasi';
	END IF;
	-- jam_mulai destinasi_ke 1 bisa mundur dan maju. tetapi majunya tidak boleh lebih dari jam_selesai - 10 mnt. Udah itu saja.
    IF OLD.destinasi_ke = 1 THEN
		IF TIME_TO_SEC(NEW.jam_mulai) > (TIME_TO_SEC(OLD.jam_selesai) - 10 * 60) THEN
			SIGNAL SQLSTATE '45017' SET MESSAGE_TEXT = 'jam_mulai pada destinasi_ke 1 terlalu maju sehingga mendekati jam_selesai';
		END IF;
    END IF;
	-- jam_selesai destinasi_ke 1 bisa mundur tetapi tidak boleh kurang dari jam_mulai. 
	-- Bisa maju tetapi tidak boleh lebih dari durasi berkunjung destinasi setelahnya - 10 mnt. 
	-- Saat jam_selesai berubah, maka jam_mulai destinasi setelahnya akan berpengaruh maju ataupun mundur tergantung seberapa banyak perubahan menit jam_selesainya.
    IF OLD.destinasi_ke != last_destinasi_ke THEN
		IF TIME_TO_SEC(NEW.jam_selesai) < (TIME_TO_SEC(OLD.jam_mulai) + 10 * 60) THEN
			SIGNAL SQLSTATE '45018' SET MESSAGE_TEXT = 'jam_selesai terlalu mundur sehingga mendekati jam_mulai';
		END IF;
        SET durasi_berkunjung_setelahnya = (SELECT TIME_TO_SEC(TIMEDIFF(jam_selesai, jam_mulai)) FROM jadwal_destinasi
        WHERE id_paketdestinasi = OLD.id_paketdestinasi AND hari = OLD.hari AND hari_ke = OLD.hari_ke AND destinasi_ke = OLD.destinasi_ke + 1);
        IF TIME_TO_SEC(TIMEDIFF(NEW.jam_selesai, OLD.jam_selesai)) > (durasi_berkunjung_setelahnya - 10 * 60) THEN
			SIGNAL SQLSTATE '45019' SET MESSAGE_TEXT = 'jam_selesai terlalu maju sehingga durasi kunjungan untuk destinasi setelahnya terlalu cepat';
		END IF;
    END IF;
	-- jam_mulai destinasi_ke 2 bisa mundur tetapi tidak boleh lebih dari durasi berkunjung destinasi sebelumnya - 10 mnt. 
	-- Bisa maju tetapi tidak boleh lebih dari jam_selesai - 10 mnt.
    -- Saat jam_mulai berubah, maka jam_selesai destinasi sebelumnya akan berpengaruh maju ataupun mundur tergantung seberapa banyak perubahan menit jam_mulainya.
    IF OLD.destinasi_ke != 1 THEN
		SET durasi_berkunjung_sebelumnya = (SELECT TIME_TO_SEC(TIMEDIFF(jam_selesai, jam_mulai)) FROM jadwal_destinasi
        WHERE id_paketdestinasi = OLD.id_paketdestinasi AND hari = OLD.hari AND hari_ke = OLD.hari_ke AND destinasi_ke = OLD.destinasi_ke - 1);
		IF TIME_TO_SEC(TIMEDIFF(OLD.jam_mulai, NEW.jam_mulai)) > (durasi_berkunjung_sebelumnya - 10 * 60) THEN
			SIGNAL SQLSTATE '45020' SET MESSAGE_TEXT = 'jam_mulai terlalu mundur sehingga durasi kunjungan untuk destinasi sebelumnya terlalu cepat';
		END IF;
        IF TIME_TO_SEC(NEW.jam_mulai) > (TIME_TO_SEC(OLD.jam_selesai) - 10 * 60) THEN
			SIGNAL SQLSTATE '45021' SET MESSAGE_TEXT = 'jam_mulai terlalu maju sehingga mendekati jam_selesai';
		END IF;
    END IF;
	-- jam_selesai destinasi_ke terakhir bisa mundur tetapi tidak boleh kurang dari jam_mulai. Udah itu saja.
    IF OLD.destinasi_ke = last_destinasi_ke THEN
		IF TIME_TO_SEC(NEW.jam_selesai) < (TIME_TO_SEC(OLD.jam_mulai) + 10 * 60) THEN
			SIGNAL SQLSTATE '45022' SET MESSAGE_TEXT = 'jam_selesai destinasi_ke terakhir terlalu mundur sehingga mendekati jam_mulai';
		END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `respon_delete_jadwal_destinasi` AFTER DELETE ON `jadwal_destinasi` FOR EACH ROW BEGIN
	-- Menghitung kembali durasi, harga, dan jarak_tempuh jika ada jadwal destinasi dihapus.
	DECLARE durasi_paketwisata INT;
	DECLARE deleted_harga_wni INT;
	DECLARE deleted_harga_wna INT;
    
    -- 1. Perhitungan durasi_wisata pada tabel paket_destinasi
    SELECT MAX(hari_ke) INTO durasi_paketwisata 
    FROM jadwal_destinasi 
    WHERE id_paketdestinasi = OLD.id_paketdestinasi 
    GROUP BY id_paketdestinasi;
    UPDATE paket_destinasi SET durasi_wisata = durasi_paketwisata WHERE id_paketdestinasi = OLD.id_paketdestinasi;
    
    -- 2. Perhitungan harga pada tabel paket_destinasi
    SELECT harga_wni, harga_wna INTO deleted_harga_wni, deleted_harga_wna FROM destinasi WHERE id_destinasi = OLD.id_destinasi;
    UPDATE paket_destinasi SET harga_wni = harga_wni - deleted_harga_wni WHERE id_paketdestinasi = OLD.id_paketdestinasi;
    UPDATE paket_destinasi SET harga_wna = harga_wna - deleted_harga_wna WHERE id_paketdestinasi = OLD.id_paketdestinasi;
    
    -- 3. Perhitungan total_jarak_tempuh pada tabel paket_destinasi  
    UPDATE paket_destinasi SET total_jarak_tempuh = ROUND(total_jarak_tempuh - OLD.jarak_tempuh, 1)
    WHERE id_paketdestinasi = OLD.id_paketdestinasi;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `respon_insert_jadwal_destinasi` AFTER INSERT ON `jadwal_destinasi` FOR EACH ROW BEGIN
	DECLARE durasi_paketwisata INT;
	DECLARE add_harga_wni INT;
	DECLARE add_harga_wna INT;
	DECLARE jaraktempuh_paketwisata DOUBLE;
    
    -- 1. Perhitungan durasi_wisata pada tabel paket_destinasi
    SELECT MAX(hari_ke) INTO durasi_paketwisata 
    FROM jadwal_destinasi 
    WHERE id_paketdestinasi = NEW.id_paketdestinasi 
    GROUP BY id_paketdestinasi;
    UPDATE paket_destinasi SET durasi_wisata = durasi_paketwisata WHERE id_paketdestinasi = NEW.id_paketdestinasi;
    
    -- 2. Perhitungan harga pada tabel paket_destinasi
    SELECT harga_wni, harga_wna INTO add_harga_wni, add_harga_wna FROM destinasi WHERE id_destinasi = NEW.id_destinasi;
    UPDATE paket_destinasi SET harga_wni = harga_wni + add_harga_wni WHERE id_paketdestinasi = NEW.id_paketdestinasi;
    UPDATE paket_destinasi SET harga_wna = harga_wna + add_harga_wna WHERE id_paketdestinasi = NEW.id_paketdestinasi;
    
    -- 3. Perhitungan total_jarak_tempuh pada tabel paket_destinasi
    -- SELECT ROUND(SUM(jadwal_destinasi.jarak_tempuh), 1) INTO jaraktempuh_paketwisata
-- 	FROM jadwal_destinasi
-- 	JOIN paket_destinasi ON jadwal_destinasi.id_paketdestinasi = paket_destinasi.id_paketdestinasi
--     WHERE jadwal_destinasi.id_paketdestinasi = NEW.id_paketdestinasi 
--     GROUP BY paket_destinasi.id_paketdestinasi;
--     UPDATE paket_destinasi SET total_jarak_tempuh = jaraktempuh_paketwisata WHERE id_paketdestinasi = NEW.id_paketdestinasi;
	UPDATE paket_destinasi SET total_jarak_tempuh = ROUND(total_jarak_tempuh + NEW.jarak_tempuh, 1) WHERE id_paketdestinasi = NEW.id_paketdestinasi;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `respon_update_jadwal_destinasi` AFTER UPDATE ON `jadwal_destinasi` FOR EACH ROW BEGIN
    DECLARE perbedaan_jarak_tempuh DOUBLE;
    DECLARE perbedaan_harga_wni INT;
    DECLARE perbedaan_harga_wna INT;
    DECLARE harga_lama_wni INT;
    DECLARE harga_baru_wni INT;
    DECLARE harga_lama_wna INT;
    DECLARE harga_baru_wna INT;
    
	-- 1. Menghitung lagi total_jarak_tempuh pada tabel paket_destinasi akibat perubahan pada jarak_tempuh.
    SET perbedaan_jarak_tempuh = ROUND(NEW.jarak_tempuh - OLD.jarak_tempuh, 1);
    UPDATE paket_destinasi SET total_jarak_tempuh = ROUND(total_jarak_tempuh + perbedaan_jarak_tempuh, 1) WHERE id_paketdestinasi = OLD.id_paketdestinasi;
    
	-- 2. Menghitung lagi harga pada tabel paket_destinasi akibat perubahan pada id_destinasi.
    SELECT harga_wni, harga_wna INTO harga_lama_wni, harga_lama_wna FROM destinasi WHERE id_destinasi = OLD.id_destinasi;
    SELECT harga_wni, harga_wna INTO harga_baru_wni, harga_baru_wna FROM destinasi WHERE id_destinasi = NEW.id_destinasi;
    SET perbedaan_harga_wni = harga_baru_wni - harga_lama_wni;
    SET perbedaan_harga_wna = harga_baru_wna - harga_lama_wna;
    UPDATE paket_destinasi SET harga_wni = harga_wni + perbedaan_harga_wni WHERE id_paketdestinasi = OLD.id_paketdestinasi;
    UPDATE paket_destinasi SET harga_wna = harga_wna + perbedaan_harga_wna WHERE id_paketdestinasi = OLD.id_paketdestinasi;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2024_04_29_152934_create_personal_access_tokens_table', 2);

-- --------------------------------------------------------

--
-- Table structure for table `paket_destinasi`
--

CREATE TABLE `paket_destinasi` (
  `id_paketdestinasi` int(11) NOT NULL,
  `id_profile` bigint(20) NOT NULL,
  `nama_paket` varchar(30) NOT NULL,
  `durasi_wisata` int(11) DEFAULT NULL,
  `harga_wni` int(11) DEFAULT NULL,
  `harga_wna` int(11) DEFAULT NULL,
  `total_jarak_tempuh` double DEFAULT NULL,
  `foto` varchar(200) DEFAULT NULL,
  `tanggal_dibuat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `paket_destinasi`
--

INSERT INTO `paket_destinasi` (`id_paketdestinasi`, `id_profile`, `nama_paket`, `durasi_wisata`, `harga_wni`, `harga_wna`, `total_jarak_tempuh`, `foto`, `tanggal_dibuat`) VALUES
(1, 1, '1 Hari di Yogyakarta', 1, 65000, 65000, 13.4, '66789016a15671719177238.jpeg', '2024-06-23 21:13:59'),
(2, 2, '2 Hari di Yogyakarta', 2, 92000, 92000, 26.8, '667890226c2351719177250.jpg', '2024-06-23 21:14:10'),
(3, 3, '3 Hari di Yogyakarta', 3, 112000, 112000, 40.2, '6678902d2a4c91719177261.jpg', '2024-06-23 21:14:21'),
(4, 4, '4 Hari di Yogyakarta', 4, 175000, 175000, 61.9, '667890388d2c71719177272.jpg', '2024-06-23 21:14:33'),
(5, 1, '5 Hari di Yogyakarta', 5, 197000, 197000, 77.4, '66789044e8d771719177284.jpg', '2024-06-23 21:14:45'),
(6, 2, '6 Hari di Yogyakarta', 6, 217000, 217000, 90.5, '66789051c7a731719177297.jpeg', '2024-06-23 21:14:58'),
(7, 3, '1 Hari di Yogyakarta', 1, 20000, 20000, 13.4, '6678905e2ed111719177310.jpg', '2024-06-23 21:15:10'),
(8, 4, '2 Hari di Yogyakarta', 2, 65000, 65000, 26.8, '66789069d25381719177321.jpg', '2024-06-23 21:15:22'),
(9, 1, '3 Hari di Yogyakarta', 3, 112000, 112000, 40.2, '66789079c172b1719177337.jpeg', '2024-06-23 21:15:38'),
(10, 2, '4 Hari di Yogyakarta', 4, 175000, 175000, 61.9, '667890877e9b91719177351.jpg', '2024-06-23 21:15:51'),
(11, 1, '1 Hari di Sleman', 1, 90000, 90000, 11.6, '66789097b79e51719177367.jpeg', '2024-06-23 21:16:08'),
(12, 2, '2 Hari di Sleman', 2, 305000, 305000, 23.2, '667890c6ecc8c1719177414.jpg', '2024-06-23 21:16:55'),
(13, 3, '3 Hari di Sleman', 3, 210000, 210000, 34.8, '667890d3ad50f1719177427.jpg', '2024-06-23 21:17:08'),
(14, 4, '4 Hari di Sleman', 4, 810000, 810000, 46.4, '667890e43aa721719177444.png', '2024-06-23 21:17:24'),
(15, 1, '5 Hari di Sleman', 5, 810000, 810000, 58, '667890efb51991719177455.jpeg', '2024-06-23 21:17:36'),
(16, 2, '6 Hari di Sleman', 6, 1065000, 1065000, 69.6, '667890fd386601719177469.jpg', '2024-06-23 21:17:49'),
(17, 3, '1 Hari di Sleman', 1, 65000, 65000, 11.6, '6678910b283f21719177483.png', '2024-06-23 21:18:03'),
(18, 4, '2 Hari di Sleman', 2, 310000, 310000, 23.2, '66789118cea411719177496.jpg', '2024-06-23 21:18:17'),
(19, 1, '3 Hari di Sleman', 3, 215000, 215000, 34.8, '66789126a20421719177510.jpg', '2024-06-23 21:18:31'),
(20, 2, '4 Hari di Sleman', 4, 845000, 845000, 46.4, '66789134c26cf1719177524.jpeg', '2024-06-23 21:18:45'),
(21, 1, '1 Hari di Bantul', 1, 85000, 85000, 13.4, '667891456776b1719177541.jpg', '2024-06-23 21:19:01'),
(22, 2, '2 Hari di Bantul', 2, 65000, 65000, 26.8, '6678915365c9f1719177555.jpg', '2024-06-23 21:19:15'),
(23, 3, '3 Hari di Bantul', 3, 67000, 67000, 40.2, '6678915feffb01719177567.jpg', '2024-06-23 21:19:28'),
(24, 4, '4 Hari di Bantul', 4, 300000, 300000, 61.9, '6678916d585401719177581.jpg', '2024-06-23 21:19:41'),
(25, 1, '5 Hari di Bantul', 5, 265000, 265000, 77.4, '6678917b269df1719177595.jpeg', '2024-06-23 21:19:55'),
(26, 2, '6 Hari di Bantul', 6, 167000, 167000, 90.5, '66789190983b21719177616.jpg', '2024-06-23 21:20:17'),
(27, 3, '1 Hari di Bantul', 1, 20000, 20000, 13.4, '667891a5ba85e1719177637.jpg', '2024-06-23 21:20:38'),
(28, 4, '2 Hari di Bantul', 2, 50000, 50000, 26.8, '667891b3627f61719177651.jpg', '2024-06-23 21:20:51'),
(29, 1, '3 Hari di Bantul', 3, 250000, 250000, 40.2, '667891c0832701719177664.jpg', '2024-06-23 21:21:04'),
(30, 2, '4 Hari di Bantul', 4, 125000, 125000, 61.9, '667891d5a35901719177685.jpg', '2024-06-23 21:21:26'),
(31, 1, '1 Hari di Kulon Progo', 1, 25000, 25000, 11.6, '667891e69f6d81719177702.jpeg', '2024-06-23 21:21:43'),
(32, 2, '2 Hari di Kulon Progo', 2, 1045000, 1045000, 23.2, '667891f3591931719177715.jpg', '2024-06-23 21:21:55'),
(33, 3, '3 Hari di Kulon Progo', 3, 83000, 83000, 34.8, '66789200cefc21719177728.jpg', '2024-06-23 21:22:09'),
(34, 4, '4 Hari di Kulon Progo', 4, 150000, 150000, 46.4, '6678920e86dee1719177742.png', '2024-06-23 21:22:23'),
(35, 1, '5 Hari di Kulon Progo', 5, 1122000, 1122000, 56.4, '6678921b20d4c1719177755.jpg', '2024-06-23 21:22:35'),
(36, 2, '6 Hari di Kulon Progo', 6, 201000, 201000, 69.6, '6678922857d361719177768.jpg', '2024-06-23 21:22:48'),
(37, 3, '1 Hari di Kulon Progo', 1, 25000, 25000, 11.6, '667892382c8401719177784.jpg', '2024-06-23 21:23:04'),
(38, 4, '2 Hari di Kulon Progo', 2, 1052000, 1052000, 23.2, '66789247777d31719177799.jpg', '2024-06-23 21:23:19'),
(39, 1, '3 Hari di Kulon Progo', 3, 77000, 77000, 34.8, '66789253d47c81719177811.jpg', '2024-06-23 21:23:32'),
(40, 2, '4 Hari di Kulon Progo', 4, 149000, 149000, 46.4, '66789261da20c1719177825.jpg', '2024-06-23 21:23:46'),
(41, 1, '1 Hari di YogyaSleman', 1, 75000, 75000, 13.4, '66789277f11bf1719177847.jpg', '2024-06-23 21:24:08'),
(42, 2, '2 Hari di YogyaSleman', 2, 85000, 85000, 26.8, '66789286af1931719177862.jpeg', '2024-06-23 21:24:23'),
(43, 3, '3 Hari di YogyaSleman', 3, 265000, 265000, 40.2, '66789298535031719177880.png', '2024-06-23 21:24:40'),
(44, 4, '4 Hari di YogyaSleman', 4, 385000, 385000, 61.9, '667892ae1c6b61719177902.jpg', '2024-06-23 21:25:02'),
(45, 1, '5 Hari di YogyaSleman', 5, 217000, 217000, 77.4, '667892c75f27a1719177927.jpg', '2024-06-23 21:25:27'),
(46, 2, '1 Hari di BantulProgo', 1, 80000, 80000, 11.6, '667892dcb9f111719177948.jpeg', '2024-06-23 21:25:49'),
(47, 3, '2 Hari di BantulProgo', 2, 65000, 65000, 23.2, '667892ed51c4f1719177965.jpg', '2024-06-23 21:26:05'),
(48, 4, '3 Hari di BantulProgo', 3, 101000, 101000, 34.8, '667893098d7e01719177993.jpg', '2024-06-23 21:26:34'),
(49, 1, '4 Hari di BantulProgo', 4, 190000, 190000, 46.4, '6678931b77aa01719178011.jpeg', '2024-06-23 21:26:51'),
(50, 2, '5 Hari di BantulProgo', 5, 332000, 332000, 56.4, '6678932ae664a1719178026.jpg', '2024-06-23 21:27:07');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(134, 'App\\Models\\User', 1, 'mytoken', '8b1560b32c16072427de4dda0895c240adcc6dd0e5548b4726065cc2107fc9ce', '[\"*\"]', '2024-06-23 16:03:00', NULL, '2024-06-23 14:06:20', '2024-06-23 16:03:00');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('fEcmzsNbrVdfPp4a6puwiNicwk3hTB4yh2H3bBcF', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRXh4cUNvdXVqV2FnU25hM1NzcXNZaEFuQ1A0ZlRPRllkV014ZHJUUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi9wYWtldC1hZG1pbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1719130234),
('fqmNhETbGDCIOHPKQLgNo7TXqReI9SzLmyYUhQT7', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUlU4cWNQdzJqUGlZU2VUb2pob1BMTEMyVmZzcXlkdnRpZ1BQdGpPciI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi90YW1iYWgtcGFrZXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1718788501),
('HNUPy2MBvzJlH65QGxegsSHrljCcEu2FBYrmkVr8', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoialB4MVV3RTlTRDhHMXdtQkdYOGF4UXhDc3M2NXlKRTFZUVJxM2xxaiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi90YW1iYWgtcGFrZXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1719071209),
('i4eICkHt3fvQ3vNQigxYcRg7j2uhX9VdejkDi4bp', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibjlvNlVYQUg4Rkx2SXZyaXJDbFhpRTY1enpSYVVOUVpNWjI3cTVORiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi9kZXRhaWwtcGFrZXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1719153986),
('J9GkipxZft7s7Xc1k6SlHpOvVx6A75VezbjfxLLB', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZjVxTWRUTHREbjB6S0lYY3RWcGM4amZYZU4xa29SbzVSMWFIbkdrQiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi9kZXRhaWwtcGFrZXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1719115507),
('Lrc0Xzw6v2oKvMTdjJT9mbZeVnhg0DtXeTZopRnI', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT2VIZks1dFp3ajhxN3RyRndvcE5UajlONmpjT1R0cDZPSkRnRkhHYSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDA6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi9jdXN0b20tcGlsaWgtdGlrZXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1719152973),
('OJ55P1x4Whb5WoWnI6ZDsShWFyOaPGA0IIUL3mXv', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNHFZcGFqRVo4anlYUW1QWmhjSmRRSzdvYUcyNnJSWHpzM29rTGN1eiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mjk6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi93YWl0aW5nIjt9fQ==', 1719148500),
('pIxGgC9XaoLhgGLXoPFK4iF37jwtRdhx5Ciyg7hs', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYlN1TjRNYk1jcjhRUERodXdPQzhwcmhCTHRVWTBNZHh0Smlqc2ZXOCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1718852782),
('TvfFWUTBuzc4xzUT3nc2buONQG2qcZtSzardyLZ3', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQzI3dFZLQzNIVTRTS0hmaE9Hcm85VjV2QXA2aHNlSGlsWWJtaUZRYyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi9kZXRhaWwtcGFrZXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1719149622),
('UtjZlBUM0qafvsMLxipI6OAGJoYs4oP0zBaO8msC', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVVKWWpudU0wM0J2NVZhdDIySmMxcEJJUjgwZGdPVFVYdFdvRFltdiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi9kZXN0aW5hc2kiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1718788210),
('wAgdxAvSSzRbArMkRmog7nGc7uLDMdtp9Q6zq25J', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoickY0d21PS2JUS0g5SnlsWGg4Q3Z0OTMxVHgzbWF5ZmxnOWpCd24yMyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDU6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi90YW1iYWgtamFkd2FsLWRlc3RpbmFzaSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1719147695),
('xFRfwMDOgVzM9PBfXiEULm9ilsZmPuloilw1HcLE', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaHlmR21WaDNqNmRwT3Bmb2pZUkgwZlNoanBZdEpRZU1WUTZtd2F5dyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi9wYWtldC1hZG1pbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1718787681),
('yjQVfrP2y1e905B7j1zjWUkyMXIOXcKCA6a6HWfL', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWjJ0Y1d6dk52OGlZU1JwV3ZjWVA1ekhZNXV6NEk3djhJcTNoZTVIbiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMi9kZXRhaWwtcGFrZXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1719152543);

-- --------------------------------------------------------

--
-- Table structure for table `tema`
--

CREATE TABLE `tema` (
  `id_tema` int(11) NOT NULL,
  `nama_tema` varchar(20) NOT NULL,
  `jenis` varchar(10) DEFAULT NULL CHECK (`jenis` in ('wisata','resto'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tema`
--

INSERT INTO `tema` (`id_tema`, `nama_tema`, `jenis`) VALUES
(1, 'Alam', 'wisata'),
(2, 'Kota', 'wisata'),
(3, 'Edukasi', 'wisata'),
(4, 'Seni & Budaya', 'wisata'),
(5, 'Religi', 'wisata'),
(6, 'Keluarga', 'wisata'),
(7, 'Belanja', 'wisata'),
(8, 'Wahana Bermain', 'wisata'),
(9, 'Olahraga', 'wisata'),
(10, 'Kuliner', 'wisata'),
(11, 'Outdoor', 'wisata'),
(12, 'Indoor', 'wisata'),
(13, 'Tanaman', 'wisata'),
(14, 'Binatang', 'wisata'),
(15, 'Street Food', 'resto'),
(16, 'Seafood', 'resto'),
(17, 'Vegetarian', 'resto'),
(18, 'Eksotis', 'resto'),
(19, 'Lokal', 'resto'),
(20, 'Tradisional', 'resto'),
(21, 'Modern', 'resto'),
(22, 'Lesehan', 'resto'),
(23, 'Prasmanan', 'resto'),
(24, 'Kafe', 'resto'),
(25, 'Indoor', 'resto'),
(26, 'Outdoor', 'resto');

-- --------------------------------------------------------

--
-- Table structure for table `tema_destinasi`
--

CREATE TABLE `tema_destinasi` (
  `id_temadestinasi` int(11) NOT NULL,
  `id_destinasi` int(11) NOT NULL,
  `id_tema` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tema_destinasi`
--

INSERT INTO `tema_destinasi` (`id_temadestinasi`, `id_destinasi`, `id_tema`) VALUES
(1, 1, 2),
(2, 1, 7),
(3, 1, 10),
(4, 2, 2),
(5, 2, 6),
(6, 2, 7),
(7, 2, 11),
(8, 3, 2),
(9, 3, 7),
(10, 3, 10),
(11, 4, 4),
(12, 4, 5),
(13, 4, 6),
(14, 4, 12),
(15, 5, 4),
(16, 5, 5),
(17, 5, 6),
(18, 5, 12),
(19, 6, 4),
(20, 6, 5),
(21, 6, 6),
(22, 6, 12),
(23, 7, 4),
(24, 7, 5),
(25, 7, 6),
(26, 7, 12),
(27, 8, 4),
(28, 8, 6),
(29, 8, 11),
(30, 9, 3),
(31, 9, 6),
(32, 9, 12),
(33, 10, 3),
(34, 10, 6),
(35, 10, 12),
(36, 11, 3),
(37, 11, 6),
(38, 11, 11),
(39, 11, 14),
(40, 12, 1),
(41, 12, 11),
(42, 12, 5),
(43, 13, 2),
(44, 13, 10),
(45, 13, 6),
(46, 13, 7),
(47, 14, 14),
(48, 14, 3),
(49, 14, 13),
(50, 15, 8),
(51, 15, 4),
(52, 15, 12),
(53, 15, 9),
(54, 16, 1),
(55, 16, 11),
(56, 16, 5),
(57, 17, 2),
(58, 17, 10),
(59, 17, 6),
(60, 17, 7),
(61, 18, 14),
(62, 18, 3),
(63, 18, 13),
(64, 19, 8),
(65, 19, 4),
(66, 19, 12),
(67, 19, 9),
(68, 20, 1),
(69, 20, 11),
(70, 20, 5),
(71, 21, 2),
(72, 21, 10),
(73, 21, 6),
(74, 21, 7),
(75, 22, 14),
(76, 22, 3),
(77, 22, 13),
(78, 23, 8),
(79, 23, 4),
(80, 23, 12),
(81, 23, 9),
(82, 24, 1),
(83, 24, 11),
(84, 24, 5),
(85, 25, 2),
(86, 25, 10),
(87, 25, 6),
(88, 25, 7),
(89, 26, 14),
(90, 26, 3),
(91, 26, 13),
(92, 27, 8),
(93, 27, 4),
(94, 27, 12),
(95, 27, 9),
(96, 28, 1),
(97, 28, 11),
(98, 28, 5),
(99, 29, 2),
(100, 29, 10),
(101, 29, 6),
(102, 29, 7),
(103, 30, 14),
(104, 30, 3),
(105, 30, 13),
(106, 31, 8),
(107, 31, 4),
(108, 31, 12),
(109, 31, 9),
(110, 32, 1),
(111, 32, 11),
(112, 32, 5),
(113, 33, 2),
(114, 33, 10),
(115, 33, 6),
(116, 33, 7),
(117, 34, 14),
(118, 34, 3),
(119, 34, 13),
(120, 35, 8),
(121, 35, 4),
(122, 35, 12),
(123, 35, 9),
(124, 36, 1),
(125, 36, 11),
(126, 36, 5),
(127, 37, 2),
(128, 37, 10),
(129, 37, 6),
(130, 37, 7),
(131, 38, 14),
(132, 38, 3),
(133, 38, 13),
(134, 39, 8),
(135, 39, 4),
(136, 39, 12),
(137, 39, 9),
(138, 40, 1),
(139, 40, 11),
(140, 40, 5),
(141, 41, 2),
(142, 41, 10),
(143, 41, 6),
(144, 41, 7),
(145, 42, 14),
(146, 42, 3),
(147, 42, 13),
(148, 43, 8),
(149, 43, 4),
(150, 43, 12),
(151, 43, 9),
(152, 44, 1),
(153, 44, 11),
(154, 44, 5),
(155, 45, 2),
(156, 45, 10),
(157, 45, 6),
(158, 45, 7),
(159, 46, 14),
(160, 46, 3),
(161, 46, 13),
(162, 47, 8),
(163, 47, 4),
(164, 47, 12),
(165, 47, 9),
(166, 48, 1),
(167, 48, 11),
(168, 48, 5),
(169, 49, 2),
(170, 49, 10),
(171, 49, 6),
(172, 49, 7),
(173, 50, 14),
(174, 50, 3),
(175, 50, 13),
(176, 51, 8),
(177, 51, 4),
(178, 51, 12),
(179, 51, 9),
(180, 52, 1),
(181, 52, 11),
(182, 52, 5),
(183, 53, 2),
(184, 53, 10),
(185, 53, 6),
(186, 53, 7),
(187, 54, 14),
(188, 54, 3),
(189, 54, 13),
(190, 55, 8),
(191, 55, 4),
(192, 55, 12),
(193, 55, 9),
(194, 56, 1),
(195, 56, 11),
(196, 56, 5),
(197, 57, 2),
(198, 57, 10),
(199, 57, 6),
(200, 57, 7),
(201, 58, 14),
(202, 58, 3),
(203, 58, 13),
(204, 59, 8),
(205, 59, 4),
(206, 59, 12),
(207, 59, 9),
(208, 60, 1),
(209, 60, 11),
(210, 60, 5),
(211, 61, 2),
(212, 61, 10),
(213, 61, 6),
(214, 61, 7),
(215, 62, 14),
(216, 62, 3),
(217, 62, 13),
(218, 63, 8),
(219, 63, 4),
(220, 63, 12),
(221, 63, 9),
(222, 64, 1),
(223, 64, 11),
(224, 64, 5),
(225, 65, 2),
(226, 65, 10),
(227, 65, 6),
(228, 65, 7),
(229, 66, 14),
(230, 66, 3),
(231, 66, 13),
(232, 67, 8),
(233, 67, 4),
(234, 67, 12),
(235, 67, 9),
(236, 68, 1),
(237, 68, 11),
(238, 68, 5),
(239, 69, 2),
(240, 69, 10),
(241, 69, 6),
(242, 69, 7),
(243, 70, 14),
(244, 70, 3),
(245, 70, 13),
(246, 71, 8),
(247, 71, 4),
(248, 71, 12),
(249, 71, 9),
(250, 72, 1),
(251, 72, 11),
(252, 72, 5),
(253, 73, 2),
(254, 73, 10),
(255, 73, 6),
(256, 73, 7),
(257, 74, 14),
(258, 74, 3),
(259, 74, 13),
(260, 75, 8),
(261, 75, 4),
(262, 75, 12),
(263, 75, 9),
(264, 76, 1),
(265, 76, 11),
(266, 76, 5),
(267, 77, 2),
(268, 77, 10),
(269, 77, 6),
(270, 77, 7),
(271, 78, 14),
(272, 78, 3),
(273, 78, 13),
(274, 79, 8),
(275, 79, 4),
(276, 79, 12),
(277, 79, 9),
(278, 80, 1),
(279, 80, 11),
(280, 80, 5),
(281, 81, 2),
(282, 81, 10),
(283, 81, 6),
(284, 81, 7),
(285, 82, 14),
(286, 82, 3),
(287, 82, 13),
(288, 83, 8),
(289, 83, 4),
(290, 83, 12),
(291, 83, 9),
(292, 84, 1),
(293, 84, 11),
(294, 84, 5),
(295, 85, 2),
(296, 85, 10),
(297, 85, 6),
(298, 85, 7),
(299, 86, 14),
(300, 86, 3),
(301, 86, 13),
(302, 87, 8),
(303, 87, 4),
(304, 87, 12),
(305, 87, 9),
(306, 88, 1),
(307, 88, 11),
(308, 88, 5),
(309, 89, 2),
(310, 89, 10),
(311, 89, 6),
(312, 89, 7),
(313, 90, 14),
(314, 90, 3),
(315, 90, 13),
(316, 91, 8),
(317, 91, 4),
(318, 91, 12),
(319, 91, 9),
(320, 92, 1),
(321, 92, 11),
(322, 92, 5),
(323, 93, 2),
(324, 93, 10),
(325, 93, 6),
(326, 93, 7),
(327, 94, 14),
(328, 94, 3),
(329, 94, 13),
(330, 95, 8),
(331, 95, 4),
(332, 95, 12),
(333, 95, 9),
(334, 96, 1),
(335, 96, 11),
(336, 96, 5),
(337, 97, 2),
(338, 97, 10),
(339, 97, 6),
(340, 97, 7),
(341, 98, 14),
(342, 98, 3),
(343, 98, 13),
(344, 99, 8),
(345, 99, 4),
(346, 99, 12),
(347, 99, 9),
(348, 100, 1),
(349, 100, 11),
(350, 100, 5),
(351, 101, 2),
(352, 101, 10),
(353, 101, 6),
(354, 101, 7),
(355, 102, 14),
(356, 102, 3),
(357, 102, 13),
(358, 103, 8),
(359, 103, 4),
(360, 103, 12),
(361, 103, 9),
(362, 104, 1),
(363, 104, 11),
(364, 104, 5),
(365, 105, 2),
(366, 105, 10),
(367, 105, 6),
(368, 105, 7),
(369, 106, 14),
(370, 106, 3),
(371, 106, 13),
(372, 107, 8),
(373, 107, 4),
(374, 107, 12),
(375, 107, 9),
(376, 108, 1),
(377, 108, 11),
(378, 108, 5),
(379, 109, 2),
(380, 109, 10),
(381, 109, 6),
(382, 109, 7),
(383, 110, 14),
(384, 110, 3),
(385, 110, 13),
(386, 111, 8),
(387, 111, 4),
(388, 111, 12),
(389, 111, 9),
(390, 112, 1),
(391, 112, 11),
(392, 112, 5),
(393, 113, 2),
(394, 113, 10),
(395, 113, 6),
(396, 113, 7),
(397, 114, 14),
(398, 114, 3),
(399, 114, 13),
(400, 115, 8),
(401, 115, 4),
(402, 115, 12),
(403, 115, 9),
(404, 116, 1),
(405, 116, 11),
(406, 116, 5),
(407, 117, 2),
(408, 117, 10),
(409, 117, 6),
(410, 117, 7),
(411, 118, 14),
(412, 118, 3),
(413, 118, 13),
(414, 119, 8),
(415, 119, 4),
(416, 119, 12),
(417, 119, 9),
(418, 120, 1),
(419, 120, 11),
(420, 120, 5),
(421, 121, 2),
(422, 121, 10),
(423, 121, 6),
(424, 121, 7),
(425, 122, 14),
(426, 122, 3),
(427, 122, 13),
(428, 123, 8),
(429, 123, 4),
(430, 123, 12),
(431, 123, 9),
(432, 124, 1),
(433, 124, 11),
(434, 124, 5),
(435, 125, 2),
(436, 125, 10),
(437, 125, 6),
(438, 125, 7),
(439, 126, 14),
(440, 126, 3),
(441, 126, 13),
(442, 127, 8),
(443, 127, 4),
(444, 127, 12),
(445, 127, 9),
(446, 128, 1),
(447, 128, 11),
(448, 128, 5),
(449, 129, 2),
(450, 129, 10),
(451, 129, 6),
(452, 129, 7),
(453, 130, 14),
(454, 130, 3),
(455, 130, 13),
(456, 131, 8),
(457, 131, 4),
(458, 131, 12),
(459, 131, 9),
(460, 132, 1),
(461, 132, 11),
(462, 132, 5),
(463, 133, 2),
(464, 133, 10),
(465, 133, 6),
(466, 133, 7),
(467, 134, 14),
(468, 134, 3),
(469, 134, 13),
(470, 135, 8),
(471, 135, 4),
(472, 135, 12),
(473, 135, 9),
(474, 136, 1),
(475, 136, 11),
(476, 136, 5),
(477, 137, 2),
(478, 137, 10),
(479, 137, 6),
(480, 137, 7),
(481, 138, 14),
(482, 138, 3),
(483, 138, 13),
(484, 139, 8),
(485, 139, 4),
(486, 139, 12),
(487, 139, 9),
(488, 140, 1),
(489, 140, 11),
(490, 140, 5),
(491, 141, 2),
(492, 141, 10),
(493, 141, 6),
(494, 141, 7),
(495, 142, 14),
(496, 142, 3),
(497, 142, 13),
(498, 143, 8),
(499, 143, 4),
(500, 143, 12),
(501, 143, 9),
(502, 144, 1),
(503, 144, 11),
(504, 144, 5),
(505, 145, 2),
(506, 145, 10),
(507, 145, 6),
(508, 145, 7),
(509, 146, 14),
(510, 146, 3),
(511, 146, 13),
(512, 147, 8),
(513, 147, 4),
(514, 147, 12),
(515, 147, 9),
(516, 148, 1),
(517, 148, 11),
(518, 148, 5),
(519, 149, 2),
(520, 149, 10),
(521, 149, 6),
(522, 149, 7),
(523, 150, 14),
(524, 150, 3),
(525, 150, 13),
(526, 151, 8),
(527, 151, 4),
(528, 151, 12),
(529, 151, 9),
(530, 152, 1),
(531, 152, 11),
(532, 152, 5),
(533, 153, 2),
(534, 153, 10),
(535, 153, 6),
(536, 153, 7),
(537, 154, 14),
(538, 154, 3),
(539, 154, 13),
(540, 155, 8),
(541, 155, 4),
(542, 155, 12),
(543, 155, 9),
(544, 156, 1),
(545, 156, 11),
(546, 156, 5),
(547, 157, 2),
(548, 157, 10),
(549, 157, 6),
(550, 157, 7),
(551, 158, 14),
(552, 158, 3),
(553, 158, 13),
(554, 159, 8),
(555, 159, 4),
(556, 159, 12),
(557, 159, 9),
(558, 160, 1),
(559, 160, 11),
(560, 160, 5),
(561, 161, 2),
(562, 161, 10),
(563, 161, 6),
(564, 161, 7),
(565, 162, 14),
(566, 162, 3),
(567, 162, 13),
(568, 163, 8),
(569, 163, 4),
(570, 163, 12),
(571, 163, 9),
(572, 164, 1),
(573, 164, 11),
(574, 164, 5),
(575, 165, 2),
(576, 165, 10),
(577, 165, 6),
(578, 165, 7),
(579, 166, 14),
(580, 166, 3),
(581, 166, 13),
(582, 167, 8),
(583, 167, 4),
(584, 167, 12),
(585, 167, 9),
(586, 168, 1),
(587, 168, 11),
(588, 168, 5),
(589, 169, 2),
(590, 169, 10),
(591, 169, 6),
(592, 169, 7),
(593, 170, 14),
(594, 170, 3),
(595, 170, 13),
(596, 171, 8),
(597, 171, 4),
(598, 171, 12),
(599, 171, 9),
(600, 172, 1),
(601, 172, 11),
(602, 172, 5),
(603, 173, 2),
(604, 173, 10),
(605, 173, 6),
(606, 173, 7),
(607, 174, 14),
(608, 174, 3),
(609, 174, 13),
(610, 175, 8),
(611, 175, 4),
(612, 175, 12),
(613, 175, 9),
(614, 176, 1),
(615, 176, 11),
(616, 176, 5),
(617, 177, 2),
(618, 177, 10),
(619, 177, 6),
(620, 177, 7),
(621, 178, 14),
(622, 178, 3),
(623, 178, 13),
(624, 179, 8),
(625, 179, 4),
(626, 179, 12),
(627, 179, 9),
(628, 180, 1),
(629, 180, 11),
(630, 180, 5),
(631, 181, 2),
(632, 181, 10),
(633, 181, 6),
(634, 181, 7),
(635, 182, 14),
(636, 182, 3),
(637, 182, 13),
(638, 183, 8),
(639, 183, 4),
(640, 183, 12),
(641, 183, 9),
(642, 184, 1),
(643, 184, 11),
(644, 184, 5),
(645, 185, 2),
(646, 185, 10),
(647, 185, 6),
(648, 185, 7),
(649, 186, 14),
(650, 186, 3),
(651, 186, 13),
(652, 187, 8),
(653, 187, 4),
(654, 187, 12),
(655, 187, 9),
(656, 188, 1),
(657, 188, 11),
(658, 188, 5),
(659, 189, 2),
(660, 189, 10),
(661, 189, 6),
(662, 189, 7),
(663, 190, 14),
(664, 190, 3),
(665, 190, 13),
(666, 191, 8),
(667, 191, 4),
(668, 191, 12),
(669, 191, 9),
(670, 192, 1),
(671, 192, 11),
(672, 192, 5),
(673, 193, 2),
(674, 193, 10),
(675, 193, 6),
(676, 193, 7),
(677, 194, 14),
(678, 194, 3),
(679, 194, 13),
(680, 195, 8),
(681, 195, 4),
(682, 195, 12),
(683, 195, 9),
(684, 196, 1),
(685, 196, 11),
(686, 196, 5),
(687, 197, 2),
(688, 197, 10),
(689, 197, 6),
(690, 197, 7),
(691, 198, 14),
(692, 198, 3),
(693, 198, 13),
(694, 199, 8),
(695, 199, 4),
(696, 199, 12),
(697, 199, 9),
(698, 200, 1),
(699, 200, 11),
(700, 200, 5),
(701, 201, 2),
(702, 201, 10),
(703, 201, 6),
(704, 201, 7),
(705, 202, 14),
(706, 202, 3),
(707, 202, 13),
(708, 203, 8),
(709, 203, 4),
(710, 203, 12),
(711, 203, 9),
(712, 204, 1),
(713, 204, 11),
(714, 204, 5),
(715, 205, 2),
(716, 205, 10),
(717, 205, 6),
(718, 205, 7),
(719, 206, 14),
(720, 206, 3),
(721, 206, 13),
(722, 207, 8),
(723, 207, 4),
(724, 207, 12),
(725, 207, 9);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `password` varchar(255) NOT NULL,
  `user_type` varchar(10) DEFAULT 'public' CHECK (`user_type` in ('public','admin')),
  `foto` varchar(255) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `full_name`, `email`, `email_verified_at`, `password`, `user_type`, `foto`, `deskripsi`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'kinan', 'Kinanthy Cahyaningrum', 'kinanthycahyaningrum@mail.ugm.ac.id', '2024-05-31 06:47:46', '$2y$12$KVvPyC13FLCba9je/XTGJOdg5Uqewu8pOGl/7cD8ucWnqoEm5DSkS', 'admin', NULL, NULL, NULL, '2024-05-30 23:47:46', '2024-05-30 23:47:46'),
(2, 'risma', 'Risma Saputri', 'rismasaputri@mail.ugm.ac.id', '2024-05-31 06:48:20', '$2y$12$mfzzk940Yvv9PK9b3EmyxupdpykiZKOq1LsV0fnfv79P6NdVhP6Xa', 'admin', NULL, NULL, NULL, '2024-05-30 23:48:20', '2024-05-30 23:48:20'),
(3, 'naufal', 'Naufal Manaf', 'naufalmanaf2004@mail.ugm.ac.id', '2024-05-31 06:48:52', '$2y$12$JlZtPflZiWkxa0SZaAG/b.xBb2skgEGJaZvFTYtg8KsYw8M35RsWa', 'admin', NULL, NULL, NULL, '2024-05-30 23:48:52', '2024-05-30 23:48:52'),
(4, 'fayyadh', 'Fayyadh Arrazan Miftakhul', 'fayyadharrazanmiftakhul@mail.ugm.ac.id', '2024-05-31 06:49:28', '$2y$12$qycWUV2YUuWBX.VvOxph/ecGQCAYxX6eoIUK5ORSgbiFeW0iMPEkW', 'admin', NULL, NULL, NULL, '2024-05-30 23:49:28', '2024-05-30 23:49:28'),
(5, 'andi', 'Bapak Andi', 'andi@email.com', '2024-05-31 06:50:15', '$2y$12$COi96EpQTEpckFv9baj.4OK1LyrZnYMXYDn0jrhTZnn0l17i1Avdy', 'public', NULL, NULL, NULL, '2024-05-30 23:50:15', '2024-05-30 23:50:15');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `destinasi`
--
ALTER TABLE `destinasi`
  ADD PRIMARY KEY (`id_destinasi`);

--
-- Indexes for table `destinasi_tutup`
--
ALTER TABLE `destinasi_tutup`
  ADD PRIMARY KEY (`id_destinasitutup`),
  ADD KEY `id_destinasi` (`id_destinasi`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jadwal_destinasi`
--
ALTER TABLE `jadwal_destinasi`
  ADD PRIMARY KEY (`id_jadwaldestinasi`),
  ADD KEY `id_paketdestinasi` (`id_paketdestinasi`),
  ADD KEY `id_destinasi` (`id_destinasi`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `paket_destinasi`
--
ALTER TABLE `paket_destinasi`
  ADD PRIMARY KEY (`id_paketdestinasi`),
  ADD KEY `id_profile` (`id_profile`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `tema`
--
ALTER TABLE `tema`
  ADD PRIMARY KEY (`id_tema`);

--
-- Indexes for table `tema_destinasi`
--
ALTER TABLE `tema_destinasi`
  ADD PRIMARY KEY (`id_temadestinasi`),
  ADD KEY `id_destinasi` (`id_destinasi`),
  ADD KEY `id_tema` (`id_tema`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `destinasi`
--
ALTER TABLE `destinasi`
  MODIFY `id_destinasi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=208;

--
-- AUTO_INCREMENT for table `destinasi_tutup`
--
ALTER TABLE `destinasi_tutup`
  MODIFY `id_destinasitutup` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jadwal_destinasi`
--
ALTER TABLE `jadwal_destinasi`
  MODIFY `id_jadwaldestinasi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=697;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `paket_destinasi`
--
ALTER TABLE `paket_destinasi`
  MODIFY `id_paketdestinasi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=135;

--
-- AUTO_INCREMENT for table `tema`
--
ALTER TABLE `tema`
  MODIFY `id_tema` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `tema_destinasi`
--
ALTER TABLE `tema_destinasi`
  MODIFY `id_temadestinasi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=726;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `destinasi_tutup`
--
ALTER TABLE `destinasi_tutup`
  ADD CONSTRAINT `destinasi_tutup_ibfk_1` FOREIGN KEY (`id_destinasi`) REFERENCES `destinasi` (`id_destinasi`);

--
-- Constraints for table `jadwal_destinasi`
--
ALTER TABLE `jadwal_destinasi`
  ADD CONSTRAINT `jadwal_destinasi_ibfk_1` FOREIGN KEY (`id_paketdestinasi`) REFERENCES `paket_destinasi` (`id_paketdestinasi`),
  ADD CONSTRAINT `jadwal_destinasi_ibfk_2` FOREIGN KEY (`id_destinasi`) REFERENCES `destinasi` (`id_destinasi`);

--
-- Constraints for table `paket_destinasi`
--
ALTER TABLE `paket_destinasi`
  ADD CONSTRAINT `paket_destinasi_ibfk_1` FOREIGN KEY (`id_profile`) REFERENCES `users` (`id`);

--
-- Constraints for table `tema_destinasi`
--
ALTER TABLE `tema_destinasi`
  ADD CONSTRAINT `tema_destinasi_ibfk_1` FOREIGN KEY (`id_destinasi`) REFERENCES `destinasi` (`id_destinasi`),
  ADD CONSTRAINT `tema_destinasi_ibfk_2` FOREIGN KEY (`id_tema`) REFERENCES `tema` (`id_tema`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
