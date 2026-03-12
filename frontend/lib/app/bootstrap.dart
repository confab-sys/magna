import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:magna_coders/core/auth/token_storage.dart';

class ApiConfig {
  static String apiBase = '';
  static String? aiBase;
  static String? realtimeBase;
}

class AppBootstrap {
  static final isReady = ValueNotifier<bool>(false);
  static final authState = ValueNotifier<bool>(false);

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: 'assets/.env');
      final base = dotenv.env['MAGNA_API_BASE'];
      if (base == null || base.isEmpty) {
        throw Exception('MAGNA_API_BASE missing');
      }
      ApiConfig.apiBase = base;
      ApiConfig.aiBase = dotenv.env['MAGNA_AI_BASE'];
      ApiConfig.realtimeBase = dotenv.env['MAGNA_REALTIME_BASE'];

      final token = await TokenStorage.readAccessToken();
      authState.value = token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Bootstrap Error: $e');
    } finally {
      isReady.value = true;
    }
  }

  static Future<void> setLoggedIn(String token, {String? userId}) async {
    await TokenStorage.writeAccessToken(token);
    if (userId != null) {
      await TokenStorage.writeUserId(userId);
    }
    authState.value = true;
  }

  static Future<void> setLoggedOut() async {
    await TokenStorage.deleteTokens();
    authState.value = false;
  }
}
