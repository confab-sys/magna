import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/builders/domain/user.dart';

class BuildersRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<User>> getBuilders() async {
    try {
      final response = await _dio.get(Endpoints.users);
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data['users'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // TODO: Log error
      return [];
    }
  }
}
