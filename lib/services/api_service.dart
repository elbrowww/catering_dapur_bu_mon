import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class ApiService {
  // ── Ganti sesuai kebutuhan ────────────────────────────────
  static const String baseUrl = 'http://10.0.2.2/dapur_bu_mon/api';
  static const Duration _timeout = Duration(seconds: 15);

  // ── Helper: headers tanpa token ───────────────────────────
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  // ── Helper: headers dengan token ──────────────────────────
  static Future<Map<String, String>> get _authHeaders async {
    final token = await SessionManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Helper: parse response (langsung, tanpa wrapper 'data') ──
  static dynamic _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw ApiException(body['error'] ?? body['message'] ?? 'Terjadi kesalahan.');
    }
    return body;
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
    final res = await http
        .post(
          Uri.parse('$baseUrl/auth.php?action=register'),
          headers: _headers,
          body: jsonEncode({
            'nama': nama,
            'email': email,
            'password': password,
            'no_telp': noTelp,
            'alamat': alamat,
          }),
        )
        .timeout(_timeout);
    final data = _parse(res);
    
    // Simpan token jika ada
    if (data['token'] != null) {
      await SessionManager.saveSession(data);
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/auth.php?action=login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);
    final data = _parse(res);

    // Simpan session otomatis setelah login
    if (data['token'] != null) {
      await SessionManager.saveSession(data);
    }
    return data;
  }

  static Future<void> logout() async {
    final headers = await _authHeaders;
    try {
      await http
          .post(
            Uri.parse('$baseUrl/auth.php?action=logout'),
            headers: headers,
          )
          .timeout(_timeout);
    } catch (e) {
      // Tetap hapus session meskipun request gagal
    }
    await SessionManager.clearSession();
  }

  // ==========================================================
  //  MENU
  // ==========================================================

  /// Ambil semua menu (response langsung berupa List)
  static Future<List<dynamic>> getMenu() async {
    final res = await http
        .get(Uri.parse('$baseUrl/menu.php'), headers: _headers)
        .timeout(_timeout);
    final data = _parse(res);
    
    // Jika response adalah List, return langsung
    if (data is List) return data;
    // Jika response adalah Map dengan key 'data'
    if (data['data'] is List) return data['data'];
    return [];
  }

  static Future<Map<String, dynamic>> getDetailMenu(int idMenu) async {
    final res = await http
        .get(Uri.parse('$baseUrl/menu.php?id_menu=$idMenu'), headers: _headers)
        .timeout(_timeout);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> tambahMenu({
    required String nama,
    required String deskripsi,
    required double harga,
    String foto = '',
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .post(
          Uri.parse('$baseUrl/menu.php'),
          headers: headers,
          body: jsonEncode({
            'nama': nama,
            'deskripsi': deskripsi,
            'harga': harga,
            'foto': foto,
          }),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> editMenu(
      int idMenu, Map<String, dynamic> data) async {
    final headers = await _authHeaders;
    final res = await http
        .put(
          Uri.parse('$baseUrl/menu.php?id_menu=$idMenu'),
          headers: headers,
          body: jsonEncode(data),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> hapusMenu(int idMenu) async {
    final headers = await _authHeaders;
    final res = await http
        .delete(
          Uri.parse('$baseUrl/menu.php?id_menu=$idMenu'),
          headers: headers,
        )
        .timeout(_timeout);
    return _parse(res);
  }

  // ==========================================================
  //  KERANJANG
  // ==========================================================

  static Future<Map<String, dynamic>> getKeranjang() async {
    final headers = await _authHeaders;
    final res = await http
        .get(Uri.parse('$baseUrl/keranjang.php'), headers: headers)
        .timeout(_timeout);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> tambahKeKeranjang({
    required int idMenu,
    required int jumlah,
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .post(
          Uri.parse('$baseUrl/keranjang.php'),
          headers: headers,
          body: jsonEncode({'id_menu': idMenu, 'jumlah': jumlah}),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> ubahJumlahItem({
    required int idItem,
    required int jumlah,
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .put(
          Uri.parse('$baseUrl/keranjang.php'),
          headers: headers,
          body: jsonEncode({'id_item': idItem, 'jumlah': jumlah}),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> hapusDariKeranjang(int idItem) async {
    final headers = await _authHeaders;
    final res = await http
        .delete(
          Uri.parse('$baseUrl/keranjang.php?id_item=$idItem'),
          headers: headers,
        )
        .timeout(_timeout);
    return _parse(res);
  }

  /// Checkout — buat pesanan dari keranjang
  static Future<Map<String, dynamic>> checkout({
    required String metodeBayar,
    String catatan = '',
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .post(
          Uri.parse('$baseUrl/pesanan.php'), // Langsung ke pesanan.php
          headers: headers,
          body: jsonEncode({
            'metode_bayar': metodeBayar,
            'catatan': catatan,
          }),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  // ==========================================================
  //  PESANAN
  // ==========================================================

  static Future<List<dynamic>> getPesanan() async {
    final headers = await _authHeaders;
    final res = await http
        .get(Uri.parse('$baseUrl/pesanan.php'), headers: headers)
        .timeout(_timeout);
    final data = _parse(res);
    
    if (data is List) return data;
    if (data['data'] is List) return data['data'];
    return [];
  }

  static Future<Map<String, dynamic>> getDetailPesanan(int idPesanan) async {
    final headers = await _authHeaders;
    final res = await http
        .get(Uri.parse('$baseUrl/pesanan.php?id_pesanan=$idPesanan'), headers: headers)
        .timeout(_timeout);
    return _parse(res);
  }

  /// Update status pesanan (owner only)
  static Future<Map<String, dynamic>> updateStatusPesanan({
    required int idPesanan,
    required String status,
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .put(
          Uri.parse('$baseUrl/pesanan.php?id_pesanan=$idPesanan&status=$status'),
          headers: headers,
        )
        .timeout(_timeout);
    return _parse(res);
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}