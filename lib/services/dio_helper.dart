import 'package:dio/dio.dart';
import 'package:catering_dapur_bu_mon/services/session_manager.dart';

class DioHelper {
  static late Dio _dio;
  
  static const String baseUrl = 'http://192.168.0.104/dapur_bu_mon/api';
  
  static void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
      // Tambahkan ini untuk debugging
      validateStatus: (status) {
        // Terima semua status code untuk debugging
        return status != null && status < 500;
      },
    ));
    
    // Interceptor untuk token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📤 REQUEST: ${options.method} ${options.path}');
        print('📍 URL: ${options.baseUrl}${options.path}');
        print('📋 Headers: ${options.headers}');
        print('📦 Data: ${options.data}');
        
        final token = await SessionManager.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Token: $token');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('✅ RESPONSE: ${response.statusCode}');
        print('📦 Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('❌ ERROR: ${error.type}');
        print('💬 Message: ${error.message}');
        print('📡 Response: ${error.response}');
        
        if (error.response != null) {
          print('📊 Status: ${error.response?.statusCode}');
          print('📦 Data: ${error.response?.data}');
        }
        
        return handler.next(error);
      },
    ));
    
    // Tambahkan LogInterceptor untuk detail lebih
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj),
    ));
  }
  
  static Dio get dio => _dio;
}