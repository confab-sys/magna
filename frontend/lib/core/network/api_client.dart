import 'package:dio/dio.dart';
import 'package:magna_coders/app/bootstrap.dart';
import 'package:magna_coders/core/auth/token_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBase,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode ?? 0;
          if (status == 401) {
            await AppBootstrap.setLoggedOut();
          }
          handler.next(error);
        },
      ),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
}
