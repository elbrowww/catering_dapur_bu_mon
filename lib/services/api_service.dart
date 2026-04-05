// ============================================================
//  lib/services/api_service.dart
//  Hubungkan ke semua endpoint PHP Dapur Bu Mon
//
//  CARA PAKAI:
//  - Emulator Android  → baseUrl = 'http://10.0.2.2/dapur_bu_mon/api'
//  - HP fisik (WiFi)   → baseUrl = 'http://192.168.x.x/dapur_bu_mon/api'
//  - iOS Simulator     → baseUrl = 'http://localhost/dapur_bu_mon/api'
// ============================================================

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

  // ── Helper: headers dengan token (untuk endpoint yang butuh auth) ──
  static Future<Map<String, String>> get _authHeaders async {
    final token = await SessionManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Helper: parse response ────────────────────────────────
  static Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw ApiException(body['message'] ?? 'Terjadi kesalahan.');
    }
    return body;
  }

  // ==========================================================
  //  AUTH
  // ==========================================================

  /// Daftar akun customer baru
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
            'role': 'customer',
            'no_telp': noTelp,
            'alamat': alamat,
          }),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  /// Login customer atau owner
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
    await SessionManager.saveSession(data['data']);
    return data;
  }

  /// Logout
  static Future<void> logout() async {
    final headers = await _authHeaders;
    await http
        .post(
          Uri.parse('$baseUrl/auth.php?action=logout'),
          headers: headers,
        )
        .timeout(_timeout);
    await SessionManager.clearSession();
  }

  // ==========================================================
  //  MENU
  // ==========================================================

  /// Ambil semua menu yang tersedia
  static Future<List<dynamic>> getMenu() async {
    final res = await http
        .get(Uri.parse('$baseUrl/menu.php'), headers: _headers)
        .timeout(_timeout);
    final data = _parse(res);
    return data['data'] as List;
  }

  /// Detail satu menu
  static Future<Map<String, dynamic>> getDetailMenu(int idMenu) async {
    final res = await http
        .get(Uri.parse('$baseUrl/menu.php?id=$idMenu'), headers: _headers)
        .timeout(_timeout);
    final data = _parse(res);
    return data['data'];
  }

  /// Tambah menu baru (owner only)
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

  /// Edit menu (owner only)
  static Future<Map<String, dynamic>> editMenu(
      int idMenu, Map<String, dynamic> data) async {
    final headers = await _authHeaders;
    final res = await http
        .put(
          Uri.parse('$baseUrl/menu.php?id=$idMenu'),
          headers: headers,
          body: jsonEncode(data),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  /// Hapus menu (owner only)
  static Future<Map<String, dynamic>> hapusMenu(int idMenu) async {
    final headers = await _authHeaders;
    final res = await http
        .delete(
          Uri.parse('$baseUrl/menu.php?id=$idMenu'),
          headers: headers,
        )
        .timeout(_timeout);
    return _parse(res);
  }

  // ==========================================================
  //  KERANJANG
  // ==========================================================

  /// Lihat isi keranjang
  static Future<Map<String, dynamic>> getKeranjang() async {
    final headers = await _authHeaders;
    final res = await http
        .get(Uri.parse('$baseUrl/keranjang.php'), headers: headers)
        .timeout(_timeout);
    final data = _parse(res);
    return data['data'];
  }

  /// Tambah item ke keranjang
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

  /// Ubah jumlah item di keranjang
  static Future<Map<String, dynamic>> ubahJumlahItem({
    required int idItem,
    required int jumlah,
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .put(
          Uri.parse('$baseUrl/keranjang.php?id=$idItem'),
          headers: headers,
          body: jsonEncode({'jumlah': jumlah}),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  /// Hapus item dari keranjang
  static Future<Map<String, dynamic>> hapusDariKeranjang(int idItem) async {
    final headers = await _authHeaders;
    final res = await http
        .delete(
          Uri.parse('$baseUrl/keranjang.php?id=$idItem'),
          headers: headers,
        )
        .timeout(_timeout);
    return _parse(res);
  }

  /// Checkout — buat pesanan dari keranjang
  static Future<Map<String, dynamic>> checkout({
    required String metodeBayar, // 'transfer' | 'cod' | 'ewallet'
    String catatan = '',
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .post(
          Uri.parse('$baseUrl/keranjang.php?action=checkout'),
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

  /// Daftar semua pesanan (riwayat customer / semua jika owner)
  static Future<List<dynamic>> getPesanan() async {
    final headers = await _authHeaders;
    final res = await http
        .get(Uri.parse('$baseUrl/pesanan.php'), headers: headers)
        .timeout(_timeout);
    final data = _parse(res);
    return data['data'] as List;
  }

  /// Detail pesanan beserta item-itemnya
  static Future<Map<String, dynamic>> getDetailPesanan(int idPesanan) async {
    final headers = await _authHeaders;
    final res = await http
        .get(Uri.parse('$baseUrl/pesanan.php?id=$idPesanan'), headers: headers)
        .timeout(_timeout);
    final data = _parse(res);
    return data['data'];
  }

  /// Update status pesanan (owner only)
  /// status: 'pending' | 'diterima' | 'diproses' | 'selesai' | 'batal'
  static Future<Map<String, dynamic>> updateStatusPesanan({
    required int idPesanan,
    required String status,
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .put(
          Uri.parse('$baseUrl/pesanan.php?id=$idPesanan'),
          headers: headers,
          body: jsonEncode({'status': status}),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  // ==========================================================
  //  PEMBAYARAN
  // ==========================================================

  /// Cek status pembayaran suatu pesanan
  static Future<Map<String, dynamic>> getPembayaran(int idPesanan) async {
    final headers = await _authHeaders;
    final res = await http
        .get(
          Uri.parse('$baseUrl/pembayaran.php?id_pesanan=$idPesanan'),
          headers: headers,
        )
        .timeout(_timeout);
    final data = _parse(res);
    return data['data'];
  }

  /// Upload bukti transfer (kirim sebagai base64 string)
  static Future<Map<String, dynamic>> uploadBuktiTransfer({
    required int idPesanan,
    required String base64Image, // konversi dari File atau Uint8List
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .post(
          Uri.parse('$baseUrl/pembayaran.php?action=upload'),
          headers: headers,
          body: jsonEncode({
            'id_pesanan': idPesanan,
            'bukti': base64Image,
          }),
        )
        .timeout(const Duration(seconds: 30)); // lebih lama untuk upload
    return _parse(res);
  }

  /// Verifikasi pembayaran (owner only)
  /// status: 'terverifikasi' | 'ditolak'
  static Future<Map<String, dynamic>> verifikasiPembayaran({
    required int idPembayaran,
    required String status,
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .put(
          Uri.parse('$baseUrl/pembayaran.php?id=$idPembayaran'),
          headers: headers,
          body: jsonEncode({'status': status}),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  // ==========================================================
  //  ULASAN
  // ==========================================================

  /// Ambil semua ulasan
  static Future<List<dynamic>> getUlasan() async {
    final headers = await _authHeaders;
    final res = await http
        .get(Uri.parse('$baseUrl/ulasan.php'), headers: headers)
        .timeout(_timeout);
    final data = _parse(res);
    return data['data'] as List;
  }

  /// Kirim ulasan untuk pesanan yang sudah selesai
  static Future<Map<String, dynamic>> kirimUlasan({
    required int idPesanan,
    required int rating, // 1–5
    String komentar = '',
  }) async {
    final headers = await _authHeaders;
    final res = await http
        .post(
          Uri.parse('$baseUrl/ulasan.php'),
          headers: headers,
          body: jsonEncode({
            'id_pesanan': idPesanan,
            'rating': rating,
            'komentar': komentar,
          }),
        )
        .timeout(_timeout);
    return _parse(res);
  }

  // ==========================================================
  //  NOTIFIKASI
  // ==========================================================

  /// Ambil semua notifikasi milik customer yang login
  static Future<List<dynamic>> getNotifikasi() async {
    final headers = await _authHeaders;
    final res = await http
        .get(Uri.parse('$baseUrl/notifikasi.php'), headers: headers)
        .timeout(_timeout);
    final data = _parse(res);
    return data['data'] as List;
  }

  /// Tandai satu notifikasi sudah dibaca
  static Future<void> readNotifikasi(int idNotifikasi) async {
    final headers = await _authHeaders;
    await http
        .put(
          Uri.parse('$baseUrl/notifikasi.php?id=$idNotifikasi'),
          headers: headers,
        )
        .timeout(_timeout);
  }

  /// Tandai semua notifikasi sudah dibaca
  static Future<void> readAllNotifikasi() async {
    final headers = await _authHeaders;
    await http
        .put(
          Uri.parse('$baseUrl/notifikasi.php?action=read_all'),
          headers: headers,
        )
        .timeout(_timeout);
  }
}

// ============================================================
//  Custom Exception — tampilkan pesan error dari server
// ============================================================
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
