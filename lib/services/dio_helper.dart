import 'package:dio/dio.dart';
import 'package:catering_dapur_bu_mon/services/session_manager.dart';

class DioHelper {
  static late Dio _dio;

  // Ganti IP ini sesuai IP server/XAMPP Anda
  static const String baseUrl = 'http://172.16.103.197/dapur_bu_mon/api/';

  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Terima semua status agar error bisa diproses di ApiService
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    // ── Interceptor: sisipkan token + logging ──────────────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();

          if (token != null && token.isNotEmpty) {
            // Pastikan tidak ada spasi di awal/akhir token
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }

          // Debug log (hapus di production)
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('📤 ${options.method} ${options.uri}');
          print('🔑 Auth: ${options.headers['Authorization'] ?? 'TIDAK ADA'}');
          if (options.data != null) print('📦 Body: ${options.data}');

          return handler.next(options);
        },

        onResponse: (response, handler) {
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('✅ ${response.statusCode} ${response.requestOptions.uri}');
          print('📦 Response: ${response.data}');
          return handler.next(response);
        },

        onError: (error, handler) {
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('❌ ERROR ${error.type}: ${error.message}');
          if (error.response != null) {
            print('📊 Status : ${error.response?.statusCode}');
            print('📦 Data   : ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;
}