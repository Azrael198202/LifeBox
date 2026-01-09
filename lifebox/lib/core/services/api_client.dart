import 'package:dio/dio.dart';
import 'auth_store.dart';

class ApiClient {
  final Dio dio;
  final AuthStore authStore;

  ApiClient({required this.authStore})
      : dio = Dio(BaseOptions(
          baseUrl: 'https://example.com', // TODO: 替换成你的后端
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = authStore.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
