// lib/config.dart
class AppConfig {
  // 🔥 Pilih salah satu sesuai kebutuhan:
  
  // Untuk Emulator Android (AVD)
  static const String baseUrl = 'http://192.168.1.11';
  
  // Untuk Device Fisik (ganti dengan IP komputer Anda)
  // Cek IP dengan:
  // - Windows: ketik 'ipconfig' di CMD
  // - Mac/Linux: ketik 'ifconfig' di Terminal
  // static const String baseUrl = 'http://192.168.1.100';
  
  // Untuk Localhost (jika testing di browser)
  // static const String baseUrl = 'http://localhost';
  
  static const String imageBaseUrl = '$baseUrl/dapur_bu_mon/assets/images/';
  static const String apiBaseUrl = '$baseUrl/catering_dapur_bu_mon/api/';
}