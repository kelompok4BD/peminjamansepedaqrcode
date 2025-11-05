import 'package:dio/dio.dart';

class ApiService {
  // Base URL backend lokal
  final String baseUrl = "http://localhost:3000/api";
  final Dio _dio = Dio(
    BaseOptions(
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // ===========================================================
  // 🔹 AUTH (LOGIN & REGISTER)
  // ===========================================================

  // Register new user
  Future<Map<String, dynamic>> register(
      String nim, String nama, String password) async {
    try {
      print('🔷 Mengirim request registrasi: $nim, $nama');
      // convert nim to number if possible (DB expects numeric id)
      final dynamic idValue = int.tryParse(nim) ?? nim;
      final res = await _dio.post('$baseUrl/register', data: {
        'id_NIM_NIP': idValue,
        'nama': nama,
        'password': password,
      });

      print('🟢 Response Register: ${res.data}');
      return {
        'success': res.statusCode == 201,
        'message': res.data['message'] ?? 'Registrasi berhasil!'
      };
    } on DioException catch (e) {
      // try to extract meaningful message from server response
      String message = 'Terjadi kesalahan saat registrasi';
      try {
        final resp = e.response?.data;
        if (resp is Map && resp['message'] != null) {
          message = resp['message'].toString();
        } else if (resp is String) {
          message = resp;
        }
      } catch (_) {
        message = e.toString();
      }
      print('❌ Register error: $message');
      return {'success': false, 'message': message};
    }
  }

  Future<bool> login(String nim, String password) async {
    try {
      final res = await _dio.post(
        '$baseUrl/login',
        data: {
          'id_NIM_NIP': nim,
          'password': password,
        },
      );

      print('🟢 Response Login: ${res.data}');
      return res.statusCode == 200 && res.data['message'] == 'Login berhasil!';
    } on DioException catch (e) {
      print('❌ Login error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // ===========================================================
  // 🔹 SEPEDA (CRUD)
  // ===========================================================

  // Ambil semua sepeda
  Future<List<dynamic>> getAllSepeda() async {
    try {
      final res = await _dio.get('$baseUrl/sepeda');
      if (res.statusCode == 200 && res.data is List) {
        print('📦 Data sepeda: ${res.data}');
        return res.data;
      } else {
        print('⚠️ Response tidak sesuai: ${res.data}');
        return [];
      }
    } catch (e) {
      print('❌ Error getAllSepeda: $e');
      return [];
    }
  }

  // Tambah sepeda baru
  Future<bool> tambahSepeda(String merk, int tahun) async {
    try {
      final res = await _dio.post(
        '$baseUrl/sepeda',
        data: {
          'merk': merk,
          'tahun': tahun,
          'status': 'Tersedia',
          'kondisi': 'Baik',
        },
      );
      print('🟢 Tambah sepeda: ${res.data}');
      return res.statusCode == 201;
    } on DioException catch (e) {
      print('❌ Error tambahSepeda: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // Update status sepeda (tersedia / dipinjam)
  Future<bool> updateStatusSepeda(int id, String status) async {
    try {
      final res = await _dio.put(
        '$baseUrl/sepeda/$id',
        data: {'status': status},
      );
      print('🟢 Update status sepeda: ${res.data}');
      return res.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Error updateStatusSepeda: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // Edit data sepeda
  Future<bool> editSepeda(
    int id,
    String merkModel,
    int tahunPembelian,
    String statusSaatIni,
    String statusPerawatan,
    String kodeQR,
  ) async {
    try {
      final res = await _dio.put(
        '$baseUrl/sepeda/edit/$id',
        data: {
          'merk_model': merkModel,
          'tahun_pembelian': tahunPembelian,
          'status_saat_ini': statusSaatIni,
          'status_perawatan': statusPerawatan,
          'kode_qr_sepeda': kodeQR,
        },
      );
      print('🟢 Edit sepeda: ${res.data}');
      return res.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Error editSepeda: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // Hapus sepeda
  Future<bool> hapusSepeda(int id) async {
    try {
      final res = await _dio.delete('$baseUrl/sepeda/$id');
      print('🗑️ Hapus sepeda response: ${res.data}');
      return res.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Error hapusSepeda: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // ===========================================================
  // 🔹 PEMINJAMAN
  // ===========================================================

  // Ambil semua riwayat peminjaman
  // Ambil semua riwayat peminjaman (masih ada untuk kompatibilitas)
  Future<List<dynamic>> getRiwayat() async {
    try {
      final res = await _dio.get('$baseUrl/peminjaman');
      if (res.statusCode == 200 && res.data is List) {
        return res.data;
      }
    } catch (e) {
      print('❌ Error getRiwayat: $e');
    }
    return [];
  }

  // Ambil riwayat pemeliharaan (dari tabel riwayat_pemeliharaan)
  Future<List<dynamic>> getRiwayatPemeliharaan() async {
    try {
      final res = await _dio.get('$baseUrl/riwayat_pemeliharaan');
      if (res.statusCode == 200 && res.data is List) {
        print('📜 Riwayat pemeliharaan: ${res.data}');
        return res.data;
      }
    } catch (e) {
      print('❌ Error getRiwayatPemeliharaan: $e');
    }
    return [];
  }

  // 🔹 Ambil pengaturan sistem
  Future<List<dynamic>> getPengaturan() async {
    try {
      final res = await _dio.get('$baseUrl/pengaturan');
      if (res.statusCode == 200) {
        return res.data;
      } else {
        return [];
      }
    } catch (e) {
      print('Error getPengaturan: $e');
      return [];
    }
  }

  // 🔹 Ambil daftar stasiun sepeda
  Future<List<dynamic>> getStasiun() async {
    try {
      final res = await _dio.get('$baseUrl/stasiun');
      if (res.statusCode == 200) {
        return res.data;
      } else {
        return [];
      }
    } catch (e) {
      print('Error getStasiun: $e');
      return [];
    }
  }

  // Tambah peminjaman (pinjam sepeda)
  Future<bool> pinjamSepeda(int idUser, int idSepeda) async {
    try {
      final res = await _dio.post(
        '$baseUrl/peminjaman',
        data: {
          'id_user': idUser,
          'id_sepeda': idSepeda,
        },
      );
      print('🚲 Response pinjam: ${res.data}');
      return res.statusCode == 200 ||
          res.statusCode == 201; // bisa dua-duanya tergantung backend
    } on DioException catch (e) {
      print('❌ Error pinjamSepeda: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // Update status peminjaman (misal: dikembalikan)
  Future<bool> updateStatusPeminjaman(int id, String status) async {
    try {
      final res = await _dio.put(
        '$baseUrl/peminjaman/$id',
        data: {'status': status},
      );
      print('🔁 Update status peminjaman: ${res.data}');
      return res.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Error updateStatusPeminjaman: ${e.response?.data ?? e.message}');
      return false;
    }
  }
}
