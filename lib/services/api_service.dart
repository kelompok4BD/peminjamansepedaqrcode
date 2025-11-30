import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  late final String baseUrl;

  ApiService._internal() {
    // determine baseUrl depending on platform
    if (kIsWeb) {
      baseUrl = "http://localhost:3000/api";
    } else {
      try {
        if (Platform.isAndroid) {
          // Android emulator -> host machine is 10.0.2.2
          baseUrl = "http://10.0.2.2:3000/api";
        } else {
          baseUrl = "http://localhost:3000/api";
        }
      } catch (_) {
        baseUrl = "http://localhost:3000/api";
      }
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    print('🔌 ApiService baseUrl = $baseUrl');
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        return error.response?.data['message'] ??
            error.message ??
            'Network error';
      }
      return error.message ?? 'Network error';
    }
    return error.toString();
  }

  Map<String, dynamic> _handleSuccess(Response response) {
    return {
      'success': true,
      'data': response.data['data'] ?? response.data,
      'message': response.data['message'] ?? 'Success'
    };
  }

  Future<Map<String, dynamic>> login(String nim, String password) async {
    try {
      print('🔷 Mengirim request login: $nim');
      final res = await _dio.post(
        '/login',
        data: {
          'id_NIM_NIP': int.tryParse(nim) ?? nim,
          'password': password,
        },
      );

      if (res.statusCode == 200 && res.data is Map) {
        final userData = res.data['user'];
        if (userData == null) {
          return {'success': false, 'message': 'Data user tidak valid'};
        }
        return {
          'success': true,
          'user': userData,
          'message': res.data['message'] ?? 'Login berhasil'
        };
      }

      return {
        'success': false,
        'message': res.data is Map
            ? res.data['message'] ?? 'Login gagal'
            : 'Login gagal'
      };
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> register(
      String nim, String nama, String password) async {
    try {
      print('🔷 Mengirim request registrasi: $nim, $nama');
      final idValue = int.tryParse(nim) ?? nim;
      final res = await _dio.post(
        '/register',
        data: {
          'id_NIM_NIP': idValue,
          'nama': nama,
          'password': password,
        },
      );

      return {
        'success': res.statusCode == 201,
        'message': res.data['message'] ?? 'Registrasi berhasil!',
        'user': res.data['user']
      };
    } catch (e) {
      print('❌ Register error: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<List<Map<String, dynamic>>> getAllUser() async {
    try {
      print('🔷 Fetching all user');
      final res = await _dio.get('/user');
      final List<dynamic> rawList = res.data['data'] ?? [];
      return rawList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> updateUser(
      String idNim, String nama, String password, String statusAkun) async {
    try {
      final res = await _dio.put(
        '/user/$idNim',
        data: {
          'nama': nama,
          'password': password,
          'status_akun': statusAkun,
        },
      );
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error updateUser: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String idNim) async {
    try {
      final res = await _dio.delete('/user/$idNim');
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error deleteUser: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<List<Map<String, dynamic>>> getAllSepeda() async {
    try {
      final res = await _dio.get('/sepeda');
      final List<dynamic> rawList = res.data['data'] ?? [];

      // Normalize items so frontend can rely on predictable keys
      final normalized = rawList.map<Map<String, dynamic>>((dynamic item) {
        final map =
            item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};

        final idVal = map['id'] ?? map['id_sepeda'];
        final merkVal = map['merk_model'] ?? map['merk'];
        final tahunVal = map['tahun_pembelian'] ?? map['tahun'];
        final statusVal = map['status_saat_ini'] ?? map['status'];
        final kondisiVal = map['status_perawatan'] ?? map['kondisi'];
        final kodeQrVal = map['kode_qr_sepeda'] ?? map['kode_qr'];

        return {
          // keep both naming conventions
          'id': idVal,
          'id_sepeda': idVal,
          'merk_model': merkVal,
          'merk': merkVal,
          'tahun_pembelian': tahunVal,
          'tahun': tahunVal,
          'status_saat_ini': statusVal,
          'status': statusVal,
          'status_perawatan': kondisiVal,
          'kondisi': kondisiVal,
          'kode_qr_sepeda': kodeQrVal,
          'kode_qr': kodeQrVal,
          // include original fields to avoid losing anything
          ...map,
        };
      }).toList();

      return normalized;
    } catch (e) {
      print('❌ Error fetching sepeda: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addSepeda(String merkModel, int tahunPembelian,
      String statusSaatIni, String statusPerawatan, String kodeQR,
      [int? idStasiun]) async {
    try {
      final res = await _dio.post(
        '/sepeda',
        data: {
          'merk': merkModel,
          'tahun': tahunPembelian,
          'status': statusSaatIni,
          'kondisi': statusPerawatan,
          'kode_qr_sepeda': kodeQR,
          'id_stasiun': idStasiun,
        },
      );
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error tambahSepeda: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> updateStatusSepeda(int id, String status) async {
    try {
      final res = await _dio.put(
        '/sepeda/$id',
        data: {'status': status},
      );
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error updateStatusSepeda: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> editSepeda(
      int id,
      String merkModel,
      int tahunPembelian,
      String statusSaatIni,
      String statusPerawatan,
      String kodeQR,
      [int? idStasiun]) async {
    try {
      final res = await _dio.put(
        '/sepeda/edit/$id',
        data: {
          'merk_model': merkModel,
          'tahun_pembelian': tahunPembelian,
          'status_saat_ini': statusSaatIni,
          'status_perawatan': statusPerawatan,
          'kode_qr_sepeda': kodeQR,
          'id_stasiun': idStasiun,
        },
      );
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error editSepeda: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> hapusSepeda(int id) async {
    try {
      final res = await _dio.delete('/sepeda/$id');
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error hapusSepeda: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // ✅ Get all stasiun (stations)
  Future<List<Map<String, dynamic>>> getAllStasiun() async {
    try {
      final res = await _dio.get('/stasiun_sepeda');

      List<dynamic> rawList = [];
      if (res.data is List) {
        rawList = res.data;
      } else if (res.data is Map && res.data['data'] is List) {
        rawList = res.data['data'];
      }

      return rawList.map((item) {
        final s = Map<String, dynamic>.from(item);
        return {
          'id_stasiun': s['id_stasiun'] ?? s['id'],
          'nama_stasiun':
              s['nama_stasiun'] ?? s['nama'] ?? 'Stasiun Tidak Diketahui',
          'alamat_stasiun': s['alamat_stasiun'] ?? s['alamat'] ?? '',
          'kapasitas_dock': s['kapasitas_dock'] ?? 0,
          'koordinat_gps': s['koordinat_gps'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching stasiun: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPeminjaman() async {
    try {
      final res = await _dio.get('/transaksi_peminjaman');

      List<dynamic> rawList = [];
      if (res.data is List) {
        rawList = res.data;
      } else if (res.data is Map && res.data['data'] is List) {
        rawList = res.data['data'];
      }

      return rawList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('❌ Error fetching peminjaman: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> pinjamSepeda(int idUser, int idSepeda) async {
    try {
      print('🔷 Mengirim request ke /transaksi-peminjaman ...');
      final res = await _dio.post(
        '/transaksi-peminjaman',
        data: {'id_user': idUser, 'id_sepeda': idSepeda},
      );
      print('🔶 Response status: ${res.statusCode}');
      print('🔶 Response data: ${res.data}');

      if (res.statusCode == 200 && res.data is Map) {
        return {
          'success': res.data['success'] ?? true,
          'data': res.data['data'] ?? {},
          'message': res.data['message'] ?? 'Peminjaman berhasil',
          'qr_code': res.data['data']?['qr_code'],
          'id_transaksi': res.data['data']?['id_transaksi'],
        };
      }
      return {'success': false, 'message': 'Gagal meminjam sepeda'};
    } catch (e) {
      print('❌ Error pinjamSepeda: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> pinjamSepedaWithJaminan(
      int idUser, int idSepeda, String metodeJaminan) async {
    try {
      print(
          '🔷 pinjamSepedaWithJaminan: baseUrl=$baseUrl, idUser=$idUser, idSepeda=$idSepeda, jaminan=$metodeJaminan');
      final res = await _dio.post(
        '/transaksi-peminjaman',
        data: {
          'id_user': idUser,
          'id_sepeda': idSepeda,
          'metode_jaminan': metodeJaminan
        },
      );
      print('🔶 Response status: ${res.statusCode}');
      print('🔶 Response data: ${res.data}');

      if (res.statusCode == 200 && res.data is Map) {
        return {
          'success': res.data['success'] ?? true,
          'data': res.data['data'] ?? {},
          'message': res.data['message'] ?? 'Peminjaman berhasil',
          'qr_code': res.data['data']?['qr_code'],
          'id_transaksi': res.data['data']?['id_transaksi'],
        };
      }
      return {'success': false, 'message': 'Gagal meminjam sepeda'};
    } catch (e) {
      print('❌ Error pinjamSepedaWithJaminan: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> updateStatusPeminjaman(
      int id, String status) async {
    try {
      final res = await _dio.put(
        '/transaksi_peminjaman/$id',
        data: {'status': status},
      );

      if (res.statusCode == 200) {
        return {
          'success': true,
          'data': res.data['data'] ?? {},
          'message':
              res.data['message'] ?? 'Status peminjaman berhasil diperbarui'
        };
      }

      return {'success': false, 'message': 'Gagal memperbarui status'};
    } catch (e) {
      print('❌ Error updateStatusPeminjaman: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // ⭐⭐⭐ PERBAIKAN RIWAYAT PEMELIHARAAN — FINAL ⭐⭐⭐
  Future<List<Map<String, dynamic>>> getRiwayatPemeliharaan() async {
    try {
      print('🔷 Fetching riwayat pemeliharaan from $baseUrl');

      final res = await _dio.get('/riwayat_pemeliharaan');
      print('🔁 riwayat response status=${res.statusCode}');
      print('🔁 riwayat response body=${res.data}');

      if (res.statusCode != 200) {
        throw Exception('Server returned status ${res.statusCode}');
      }

      dynamic body = res.data;
      List<dynamic> rawList = [];

      if (body is List) {
        rawList = body;
      } else if (body is Map && body['data'] is List) {
        rawList = body['data'];
      } else if (body is Map && body['rows'] is List) {
        // sometimes controllers return { rows: [...] }
        rawList = body['rows'];
      }

      return rawList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('❌ Error fetching riwayat pemeliharaan: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPengaturan() async {
    try {
      print('🔷 Fetching pengaturan from $baseUrl');

      final res = await _dio.get('/pengaturan');
      print('🔁 pengaturan response status=${res.statusCode}');
      print('🔁 pengaturan response body=${res.data}');

      if (res.statusCode != 200) {
        throw Exception('Server returned status ${res.statusCode}');
      }

      dynamic body = res.data;
      List<dynamic> rawList = [];

      if (body is List) {
        rawList = body;
      } else if (body is Map && body['data'] is List) {
        rawList = body['data'];
      } else if (body is Map && body['rows'] is List) {
        // sometimes controllers return { rows: [...] }
        rawList = body['rows'];
      }

      return rawList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('❌ Error fetching pengaturan: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getStasiun() async {
    try {
      final res = await _dio.get('/stasiun_sepeda');
      final List<dynamic> rawList = res.data['data'] ?? [];
      return rawList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching stasiun: $e');
      return [];
    }
  }

  // Create a new stasiun
  Future<Map<String, dynamic>> createStasiun(
      Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/stasiun_sepeda', data: payload);
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error createStasiun: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Update an existing stasiun by id
  Future<Map<String, dynamic>> updateStasiun(
      int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.put('/stasiun_sepeda/$id', data: payload);
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error updateStasiun: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Delete a stasiun by id
  Future<Map<String, dynamic>> deleteStasiun(int id) async {
    try {
      final res = await _dio.delete('/stasiun_sepeda/$id');
      return _handleSuccess(res);
    } catch (e) {
      print('❌ Error deleteStasiun: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<List<Map<String, dynamic>>> getLaporanKerusakan() async {
    try {
      print('🔷 Fetching laporan kerusakan from $baseUrl');
      final res = await _dio.get('/laporan-kerusakan');
      print('🔁 laporan kerusakan response status=${res.statusCode}');
      print('🔁 laporan kerusakan response body=${res.data}');

      if (res.statusCode != 200) {
        throw Exception('Server returned status ${res.statusCode}');
      }

      dynamic body = res.data;
      List<dynamic> rawList = [];

      if (body is List) {
        rawList = body;
      } else if (body is Map && body['data'] is List) {
        rawList = body['data'];
      } else if (body is Map &&
          body['success'] == true &&
          body['data'] is List) {
        rawList = body['data'];
      }

      return rawList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('❌ Error fetching laporan kerusakan: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createLaporanKerusakan(
    int idSepeda,
    int idPegawai,
    String deskripsi,
    String statusPerbaikan,
  ) async {
    try {
      final res = await _dio.post(
        '/laporan-kerusakan',
        data: {
          'id_sepeda': idSepeda,
          'id_pegawai': idPegawai,
          'deskripsi_kerusakan': deskripsi,
          'tanggal_laporan': DateTime.now().toIso8601String(),
          'status_perbaikan': statusPerbaikan,
        },
      );

      return {
        'success': res.statusCode == 201,
        'message': res.data['message'] ?? 'Laporan berhasil ditambahkan',
        'data': res.data['data']
      };
    } catch (e) {
      print('❌ Error creating laporan kerusakan: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> updateLaporanKerusakanStatus(
    int idLaporan,
    String status,
  ) async {
    try {
      final res = await _dio.put(
        '/laporan-kerusakan/$idLaporan',
        data: {'status': status},
      );

      return {
        'success': res.statusCode == 200,
        'message': res.data['message'] ?? 'Status diperbarui',
      };
    } catch (e) {
      print('❌ Error updating laporan status: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> createLogAktivitas(
    int? idPegawai,
    String jenisAktivitas,
    String deskripsi,
  ) async {
    try {
      final res = await _dio.post(
        '/log-aktivitas',
        data: {
          'id_pegawai': idPegawai,
          'waktu_aktivitas': DateTime.now().toIso8601String(),
          'jenis_aktivitas': jenisAktivitas,
          'deskripsi_aktivitas': deskripsi,
        },
      );

      return {
        'success': res.statusCode == 201,
        'message': res.data['message'] ?? 'Log aktivitas tercatat',
      };
    } catch (e) {
      print('❌ Error creating log aktivitas: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<List<Map<String, dynamic>>> getLogAktivitas() async {
    try {
      final res = await _dio.get('/log-aktivitas');
      final List<dynamic> data = res.data['data'] ?? [];
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      print('❌ Error fetching log aktivitas: $e');
      return [];
    }
  }
}
