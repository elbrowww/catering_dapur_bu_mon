import 'package:dio/dio.dart';
import 'dio_helper.dart';
import 'session_manager.dart';

class ApiService {
  static Dio get _dio => DioHelper.dio;

  // Helper: parse response
  static dynamic _parse(Response response) {
    final data = response.data;
    
    if (response.statusCode! >= 400) {
      throw ApiException(data['error'] ?? data['message'] ?? 'Terjadi kesalahan.');
    }
    
    return data;
  }

  // Helper untuk mengambil pesan error dari DioException
  static String _getErrorMessage(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data != null && data['error'] != null) {
        return data['error'];
      }
      if (data != null && data['message'] != null) {
        return data['message'];
      }
      return 'Server error: ${e.response?.statusCode}';
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Periksa koneksi internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server tidak merespon. Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      default:
        return e.message ?? 'Terjadi kesalahan.';
    }
  }

  // ==========================================================
  //  AUTH
  // ==========================================================

  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String noTelp,
    required String alamat,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=register',
        data: {
          'nama': nama,
          'email': email,
          'password': password,
          'no_telp': noTelp,
          'alamat': alamat,
        },
      );
      final data = _parse(response);
      
      if (data['token'] != null) {
        await SessionManager.saveSession(data);
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=login',
        data: {'email': email, 'password': password},
      );
      final data = _parse(response);
      
      if (data['token'] != null) {
        await SessionManager.saveSession(data);
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<void> logout() async {
    try {
      await _dio.post('/auth.php?action=logout');
    } catch (e) {
      // Tetap hapus session meskipun request gagal
    }
    await SessionManager.clearSession();
  }

  // ==========================================================
  //  MENU
  // ==========================================================

  static Future<List<dynamic>> getMenu() async {
    try {
      print('📡 Fetching menu from: ${DioHelper.dio.options.baseUrl}/menu.php');
      
      final response = await DioHelper.dio.get('/menu.php');
      
      print('✅ Response status: ${response.statusCode}');
      print('📦 Response data type: ${response.data.runtimeType}');
      print('📦 Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          print('✅ Data adalah List, jumlah: ${response.data.length}');
          return response.data;
        } else if (response.data is Map && response.data['data'] is List) {
          print('✅ Data dalam key "data", jumlah: ${response.data['data'].length}');
          return response.data['data'];
        } else {
          print('⚠️ Format response tidak dikenal: ${response.data}');
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.type} - ${e.message}');
      if (e.response != null) {
        print('❌ Response error: ${e.response?.data}');
      }
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> getDetailMenu(int idMenu) async {
    try {
      final response = await _dio.get('/menu.php?id_menu=$idMenu');
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> tambahMenu({
    required String nama,
    required String deskripsi,
    required double harga,
    String foto = '',
  }) async {
    try {
      final response = await _dio.post(
        '/menu.php',
        data: {
          'nama': nama,
          'deskripsi': deskripsi,
          'harga': harga,
          'foto': foto,
        },
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> editMenu(
    int idMenu, 
    Map<String, dynamic> data
  ) async {
    try {
      final response = await _dio.put(
        '/menu.php?id_menu=$idMenu',
        data: data,
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> hapusMenu(int idMenu) async {
    try {
      final response = await _dio.delete('/menu.php?id_menu=$idMenu');
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  // ==========================================================
  //  KERANJANG
  // ==========================================================

  static Future<Map<String, dynamic>> getKeranjang() async {
    try {
      final response = await _dio.get('/keranjang.php');
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> tambahKeKeranjang({
    required int idMenu,
    required int jumlah,
  }) async {
    try {
      final response = await _dio.post(
        '/keranjang.php',
        data: {'id_menu': idMenu, 'jumlah': jumlah},
      );

      print('📦 Response tambahKeranjang: ${response.data}');

      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> ubahJumlahItem({
    required int idItem,
    required int jumlah,
  }) async {
    try {
      final response = await _dio.put(
        '/keranjang.php',
        data: {'id_item': idItem, 'jumlah': jumlah},
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> hapusDariKeranjang(int idItem) async {
    try {
      final response = await _dio.delete('/keranjang.php?id_item=$idItem');
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> checkout({
    required String metodeBayar,
    String catatan = '',
  }) async {
    try {
      final response = await _dio.post(
        '/pesanan.php',
        data: {
          'metode_bayar': metodeBayar,
          'catatan': catatan,
        },
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  // ==========================================================
  //  PESANAN
  // ==========================================================

  static Future<List<dynamic>> getPesanan() async {
    try {
      final response = await _dio.get('/pesanan.php');
      final data = _parse(response);
      
      if (data is List) return data;
      if (data['data'] is List) return data['data'];
      return [];
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> getDetailPesanan(int idPesanan) async {
    try {
      final response = await _dio.get('/pesanan.php?id_pesanan=$idPesanan');
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> updateStatusPesanan({
    required int idPesanan,
    required String status,
  }) async {
    try {
      final response = await _dio.put(
        '/pesanan.php?id_pesanan=$idPesanan&status=$status',
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }
  
  // ==========================================================
  //  CUSTOMER
  // ==========================================================

  static Future<List<dynamic>> getDataCustomer() async {
    try {
      final response = await _dio.get('/auth.php?action=list_customer');
      final data = _parse(response);

      if (data is List) return data;
      if (data['data'] is List) return data['data'];
      return [];
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  // ==========================================================
  //  ULASAN
  // ==========================================================

  /// Ambil semua ulasan (publik, tidak perlu login)
  static Future<List<dynamic>> getUlasan({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/ulasan.php',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final data = _parse(response);

      if (data is List) return data;
      if (data['data'] is List) return data['data'];
      return [];
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  /// Kirim ulasan baru (harus sudah login sebagai customer)
  static Future<Map<String, dynamic>> kirimUlasan({
    required int rating,
    required String komentar,
  }) async {
    try {
      final response = await _dio.post(
        '/ulasan.php',
        data: {
          'rating': rating,
          'komentar': komentar,
        },
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}