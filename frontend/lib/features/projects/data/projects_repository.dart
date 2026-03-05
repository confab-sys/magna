import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/projects/domain/project.dart';

class ProjectsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Project>> getProjects() async {
    try {
      final response = await _dio.get(Endpoints.projects);
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['projects'];
        return list.map((json) => Project.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createProject(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(Endpoints.projects, data: data);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
