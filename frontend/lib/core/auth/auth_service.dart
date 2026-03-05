import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/core/auth/token_storage.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(Endpoints.authLogin, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await TokenStorage.saveAccessToken(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      // TODO: Log error properly
      return false;
    }
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    try {
      final response = await _dio.post(Endpoints.authRegister, data: {
        'username': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        // Automatically login after register or redirect to login? 
        // For now, let's assume we need to login manually or the backend returns a token (check backend)
        // Backend returns: { message: 'User registered successfully', user: { ... } }
        // So we need to ask user to login.
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.deleteAccessToken();
  }
}
