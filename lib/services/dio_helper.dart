import 'package:dio/dio.dart';
import 'session_manager.dart';

class DioHelper {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2/dapur_bu_mon/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get instance => _dio;

  static void init() {
    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onResponse: (response, handler) {
          return handler.next(response);
        },

        onError: (DioException e, handler) async {
          // Auto logout kalau token invalid
          if (e.response?.statusCode == 401) {
            await SessionManager.clearSession();
          }

          return handler.next(e);
        },
      ),
    );
  }
}