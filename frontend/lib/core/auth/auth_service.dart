import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/core/auth/token_storage.dart';
import 'package:magna_coders/app/bootstrap.dart';

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
          final user = response.data['user'];
          final userId = user is Map ? user['id'] as String? : null;
          await AppBootstrap.setLoggedIn(token, userId: userId);
          return true;
        }
      }
      return false;
    } catch (e) {
      // TODO: Log error properly
      return false;
    }
  }

  Future<bool> registerWithUsername({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.authRegister,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map) {
          final token = data['token'] as String?;
          final user = data['user'];
          final userId = user is Map ? user['id'] as String? : null;
          if (token != null && token.isNotEmpty) {
            await AppBootstrap.setLoggedIn(token, userId: userId);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> startOAuth(String provider) async {
    final startPath = switch (provider) {
      'google' => Endpoints.googleAuthStart,
      'github' => Endpoints.githubAuthStart,
      _ => throw Exception('Unsupported provider: $provider'),
    };

    final callback = Uri.parse('${Uri.base.origin}${Endpoints.oauthCallback}');
    final startUrl = Uri.parse('${ApiConfig.apiBase}$startPath').replace(
      queryParameters: {
        'redirect_uri': callback.toString(),
      },
    );

    final ok = await launchUrl(
      startUrl,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_self',
    );
    if (!ok) {
      throw Exception('Could not start OAuth flow');
    }
  }

  Future<bool> handleOAuthCallback(Uri uri) async {
    // Check if we have a code from the OAuth provider redirect
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    
    if (error != null) {
      debugPrint('OAuth error: $error');
      return false;
    }

    if (code != null) {
       // Try Google first, then GitHub
       try {
         final ok = await _exchangeCode('google', code, uri);
         if (ok) return true;
       } catch (e) {
         // Ignore and try GitHub
       }

       try {
          final ok = await _exchangeCode('github', code, uri);
          if (ok) return true;
       } catch (e2) {
          debugPrint('OAuth exchange failed for both providers: $e2');
          return false;
       }
       return false;
    }

    // Legacy/Direct token handling (if backend sent token directly)
    final qp = uri.queryParameters;
    final token =
        qp['token'] ?? qp['access_token'] ?? qp['accessToken'] ?? qp['jwt'];
    final userId = qp['userId'] ?? qp['user_id'] ?? qp['id'];

    if (token == null || token.isEmpty) {
      debugPrint('OAuth callback missing token/code: $uri');
      return false;
    }

    await AppBootstrap.setLoggedIn(token, userId: userId);
    return true;
  }
  
  Future<bool> _exchangeCode(String provider, String code, Uri currentUri) async {
      // Construct the redirect_uri that was used to start this.
      // It must match EXACTLY what was sent to the provider.
      final callback = Uri.parse('${Uri.base.origin}${Endpoints.oauthCallback}');
      
      final endpoint = switch (provider) {
          'google' => '/api/auth/google/exchange',
          'github' => '/api/auth/github/exchange',
          _ => throw Exception('Unknown provider')
      };
      
      try {
        final response = await _dio.post(endpoint, data: {
            'code': code,
            'redirect_uri': callback.toString(),
        });
        
        if (response.statusCode == 200) {
            final data = response.data;
            final token = data['token'];
            final user = data['user'];
            final userId = user is Map ? user['id'] as String? : null;
            
            if (token != null) {
                await AppBootstrap.setLoggedIn(token, userId: userId);
                return true;
            }
        }
      } catch (e) {
        throw Exception('Exchange failed: $e');
      }
      throw Exception('Exchange failed');
  }

  Future<void> requestPasswordReset(String email) async {
    await _dio.post(
      Endpoints.forgotPassword,
      data: {'email': email.trim()},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post(
      Endpoints.resetPassword,
      data: {
        'token': token,
        'password': newPassword,
      },
    );
  }

  Future<void> logout() async {
    await TokenStorage.deleteTokens();
  }
}
