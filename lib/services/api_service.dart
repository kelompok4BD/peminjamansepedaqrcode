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
  // 🔹 LOGIN
  // ===========================================================
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
  Future<List<dynamic>> getRiwayat() async {
    try {
      final res = await _dio.get('$baseUrl/peminjaman');
      if (res.statusCode == 200 && res.data is List) {
        print('📜 Riwayat: ${res.data}');
        return res.data;
      } else {
        print('⚠️ Format riwayat tidak sesuai: ${res.data}');
        return [];
      }
    } catch (e) {
      print('❌ Error getRiwayat: $e');
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
