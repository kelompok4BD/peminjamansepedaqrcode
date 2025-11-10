import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final String baseUrl = "http://localhost:3000/api";

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
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
      return rawList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching sepeda: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addSepeda(
    String merkModel,
    int tahunPembelian,
    String statusSaatIni,
    String statusPerawatan,
    String kodeQR,
  ) async {
    try {
      final res = await _dio.post(
        '/sepeda',
        data: {
          'merk': merkModel,
          'tahun': tahunPembelian,
          'status': statusSaatIni,
          'kondisi': statusPerawatan,
          'kode_qr_sepeda': kodeQR,
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
  ) async {
    try {
      final res = await _dio.put(
        '/sepeda/edit/$id',
        data: {
          'merk_model': merkModel,
          'tahun_pembelian': tahunPembelian,
          'status_saat_ini': statusSaatIni,
          'status_perawatan': statusPerawatan,
          'kode_qr_sepeda': kodeQR,
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
      final res = await _dio.post(
        '/transaksi_peminjaman',
        data: {
          'id_user': idUser,
          'id_sepeda': idSepeda,
        },
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        return {
          'success': true,
          'data': res.data['data'] ?? {},
          'message': res.data['message'] ?? 'Peminjaman berhasil ditambahkan'
        };
      }

      return {'success': false, 'message': 'Gagal menambahkan peminjaman'};
    } catch (e) {
      print('❌ Error pinjamSepeda: $e');
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

  Future<List<Map<String, dynamic>>> getRiwayatPemeliharaan() async {
    try {
      final res = await _dio.get('/riwayat_pemeliharaan');
      final List<dynamic> rawList = res.data['data'] ?? [];
      return rawList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching riwayat pemeliharaan: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPengaturan() async {
    try {
      final res = await _dio.get('/pengaturan');
      final List<dynamic> rawList = res.data['data'] ?? [];
      return rawList.map((item) => item as Map<String, dynamic>).toList();
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
}
