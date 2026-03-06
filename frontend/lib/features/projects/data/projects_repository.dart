import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/projects/domain/project.dart';

class ProjectsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Project>> getProjects() async {
    try {
      final response = await _dio.get(Endpoints.projects);
      debugPrint('Projects Response: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['projects'];
        return list.map((json) => Project.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Projects Error: $e');
      return [];
    }
  }

  Future<Project?> getProject(String id) async {
    try {
      final response = await _dio.get(Endpoints.projectById(id));
      if (response.statusCode == 200) {
        return Project.fromJson(response.data['project']);
      }
      return null;
    } catch (e) {
      return null;
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

  Future<bool> likeProject(String id) async {
    try {
      final response = await _dio.post(Endpoints.likeProject(id));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
