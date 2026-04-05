// ============================================================
//  lib/services/session_manager.dart
//  Menyimpan data login ke SharedPreferences
//
//  Tambahkan ke pubspec.yaml:
//    shared_preferences: ^2.2.3
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Key konstanta
  static const _kToken       = 'token';
  static const _kRole        = 'role';
  static const _kNama        = 'nama';
  static const _kEmail       = 'email';
  static const _kIdUser      = 'id_user';
  static const _kIdCustomer  = 'id_customer';
  static const _kIdOwner     = 'id_owner';

  // ── Simpan session setelah login ─────────────────────────
  static Future<void> saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken,      data['token']       ?? '');
    await prefs.setString(_kRole,       data['role']        ?? '');
    await prefs.setString(_kNama,       data['nama']        ?? '');
    await prefs.setString(_kEmail,      data['email']       ?? '');
    await prefs.setInt(_kIdUser,        data['id_user']     ?? 0);
    await prefs.setInt(_kIdCustomer,    data['id_customer'] ?? 0);
    await prefs.setInt(_kIdOwner,       data['id_owner']    ?? 0);
  }

  // ── Hapus session saat logout ─────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Getter masing-masing field ────────────────────────────
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken) ?? '';
  }

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRole) ?? '';
  }

  static Future<String> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kNama) ?? '';
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail) ?? '';
  }

  static Future<int> getIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kIdUser) ?? 0;
  }

  static Future<int> getIdCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kIdCustomer) ?? 0;
  }

  static Future<int> getIdOwner() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kIdOwner) ?? 0;
  }

  // ── Cek apakah sudah login ────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token.isNotEmpty;
  }

  // ── Ambil semua data session sekaligus ────────────────────
  static Future<Map<String, dynamic>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token'      : prefs.getString(_kToken)     ?? '',
      'role'       : prefs.getString(_kRole)      ?? '',
      'nama'       : prefs.getString(_kNama)      ?? '',
      'email'      : prefs.getString(_kEmail)     ?? '',
      'id_user'    : prefs.getInt(_kIdUser)       ?? 0,
      'id_customer': prefs.getInt(_kIdCustomer)   ?? 0,
      'id_owner'   : prefs.getInt(_kIdOwner)      ?? 0,
    };
  }
}
