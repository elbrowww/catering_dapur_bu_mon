import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // ✅ untuk kIsWeb & Uint8List
import 'dio_helper.dart';
import 'session_manager.dart';

class ApiService {
  static Dio get _dio => DioHelper.dio;

  static dynamic _parse(Response response) {
    final data = response.data;
    if (response.statusCode! >= 400) {
      final msg = (data is Map)
          ? (data['error'] ?? data['message'] ?? 'Terjadi kesalahan.')
          : 'Terjadi kesalahan.';
      throw ApiException(msg.toString());
    }
    return data;
  }

  static String _getErrorMessage(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map) {
        if (data['error'] != null)   return data['error'].toString();
        if (data['message'] != null) return data['message'].toString();
      }
      return 'Server error: ${e.response?.statusCode}';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Periksa koneksi internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server tidak merespon. Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Pastikan XAMPP aktif dan IP benar.';
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
    required String noTelp,
    required String alamat,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=register',
        data: {
          'nama':     nama,
          if (email.isNotEmpty)  'email':   email,
          if (noTelp.isNotEmpty) 'no_telp': noTelp,
          'alamat':   alamat,
          'password': password,
        },
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=verify_phone_otp',
        data: {'phone': phone, 'otp_code': otpCode},
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=verify_email_otp',
        data: {'email': email, 'otp_code': otpCode},
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> resendOtp({
    required String target,
    required String type,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=resend_otp',
        data: {'target': target, 'type': type},
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> login({
    String? email,
    String? noTelp,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=login',
        data: {
          if (email  != null && email.isNotEmpty)  'email':   email,
          if (noTelp != null && noTelp.isNotEmpty) 'no_telp': noTelp,
          'password': password,
        },
      );
      final data = _parse(response);
      if (data['token'] != null) await SessionManager.saveSession(data);
      return data;
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> sendOtpRegister({
    required String noTelp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=send_otp_register',
        data: {'no_telp': noTelp},
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> registerWithOtp({
    required String nama,
    required String email,
    required String noTelp,
    required String alamat,
    required String password,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=register',
        data: {
          'nama':      nama,
          'email':     email,
          'no_telp':   noTelp,
          'alamat':    alamat,
          'password':  password,
          'otp_code':  otpCode,
        },
      );
      final data = _parse(response);
      if (data['token'] != null) await SessionManager.saveSession(data);
      return data;
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<void> logout() async {
    try {
      await _dio.post('/auth.php?action=logout');
    } catch (_) {}
    await SessionManager.clearSession();
  }

  // ==========================================================
  //  MENU
  // ==========================================================

  static Future<List<dynamic>> getMenu() async {
    try {
      final response = await _dio.get('/menu.php');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List)                        return data;
        if (data is Map && data['data'] is List) return data['data'];
      }
      return [];
    } on DioException catch (e) {
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
    String foto     = '',
    String kategori = '',
  }) async {
    try {
      final response = await _dio.post(
        '/menu.php',
        data: {
          'nama':      nama,
          'deskripsi': deskripsi,
          'harga':     harga,
          'foto':      foto,
          'kategori':  kategori,
        },
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> editMenu(
    int idMenu,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/menu.php?id_menu=$idMenu', data: data);
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

  // ==========================================================
  //  CHECKOUT  ✅ FIXED: support Web (Uint8List) & Mobile (File)
  // ==========================================================

  static Future<Map<String, dynamic>> checkout({
    required String namaPembeli,
    required String alamat,
    required String metodeBayar,
    String catatan         = '',
    File?  buktiBayar,             // Mobile: dart:io File
    Uint8List? buktiBayarBytes,    // ✅ Web: raw bytes
    String?    buktiBayarName,     // ✅ nama file dari XFile.name
  }) async {
    try {
      MultipartFile? multipartFile;

      if (kIsWeb) {
        // ✅ Web: buat MultipartFile dari bytes
        if (buktiBayarBytes != null) {
          final filename = buktiBayarName ??
              'bukti_${DateTime.now().millisecondsSinceEpoch}.jpg';
          multipartFile = MultipartFile.fromBytes(
            buktiBayarBytes,
            filename: filename,
          );
        }
      } else {
        // Mobile: buat MultipartFile dari path File
        if (buktiBayar != null) {
          multipartFile = await MultipartFile.fromFile(
            buktiBayar.path,
            filename: 'bukti_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        }
      }

      final formData = FormData.fromMap({
        'nama_pembeli': namaPembeli,
        'alamat':       alamat,
        'metode_bayar': metodeBayar,
        'catatan':      catatan,
        if (multipartFile != null) 'bukti_bayar': multipartFile,
      });

      final response = await _dio.post('/pesanan.php', data: formData);
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
      if (data is List)         return data;
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
      if (data is List)         return data;
      if (data['data'] is List) return data['data'];
      return [];
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  // ==========================================================
  //  ULASAN
  // ==========================================================

  static Future<List<dynamic>> getUlasan({
    int limit  = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/ulasan.php',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final data = _parse(response);
      if (data is List)         return data;
      if (data['data'] is List) return data['data'];
      return [];
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> kirimUlasan({
    required int rating,
    required String komentar,
  }) async {
    try {
      final response = await _dio.post(
        '/ulasan.php',
        data: {'rating': rating, 'komentar': komentar},
      );
      return _parse(response);
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  // ==========================================================
  //  PROFIL
  // ==========================================================

  static Future<Map<String, dynamic>> getProfil() async {
    try {
      final response = await _dio.get('/profil.php');
      final data = _parse(response);
      if (data is Map<String, dynamic>) return data;
      throw const ApiException('Format response profil tidak valid');
    } on DioException catch (e) {
      throw ApiException(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> editProfil({
    String? nama,
    String? noTelp,
    String? alamat,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (nama   != null && nama.isNotEmpty)   body['nama']    = nama.trim();
      if (noTelp != null && noTelp.isNotEmpty) body['no_telp'] = noTelp.trim();
      if (alamat != null && alamat.isNotEmpty) body['alamat']  = alamat.trim();

      if (body.isEmpty) throw const ApiException('Tidak ada data yang diubah');

      final response = await _dio.put('/profil.php', data: body);
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