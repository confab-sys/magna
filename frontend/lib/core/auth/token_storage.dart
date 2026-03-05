import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _userIdKey = 'user_id';

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  // Alias for compatibility
  static Future<void> writeAccessToken(String token) => saveAccessToken(token);

  static Future<String?> readAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  static Future<void> deleteTokens() async {
    await _storage.deleteAll();
  }

  static Future<void> writeUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> readUserId() async {
    return await _storage.read(key: _userIdKey);
  }
}
