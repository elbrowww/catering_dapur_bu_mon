import 'package:dio/dio.dart';
import 'package:catering_dapur_bu_mon/services/session_manager.dart';

class DioHelper {
  static late Dio _dio;

  static const String baseUrl = 'http://192.168.1.63/dapur_bu_mon/api/';

  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        // ⚠️ HAPUS Content-Type dari sini agar tidak konflik dengan multipart
        // Dio akan set Content-Type yang tepat otomatis sesuai jenis data
        headers: {
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }

          // Jika bukan FormData, pastikan Content-Type JSON
          if (options.data is! FormData) {
            options.headers['Content-Type'] = 'application/json';
          }
          // Jika FormData, biarkan Dio set multipart/form-data + boundary otomatis

          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('📤 ${options.method} ${options.uri}');
          print('🔑 Auth: ${options.headers['Authorization'] ?? 'TIDAK ADA'}');
          print('📋 Content-Type: ${options.headers['Content-Type'] ?? 'auto (multipart)'}');
          if (options.data != null && options.data is! FormData) {
            print('📦 Body: ${options.data}');
          } else if (options.data is FormData) {
            print('📦 Body: FormData (multipart)');
          }

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