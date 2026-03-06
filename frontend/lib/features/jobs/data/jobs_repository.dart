import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/jobs/domain/job.dart';

class JobsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Job>> getJobs() async {
    try {
      final response = await _dio.get(Endpoints.jobs);
      debugPrint('Jobs Response: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['jobs'];
        try {
          return list.map((json) {
            debugPrint('Parsing Job: ${json['id']}');
            return Job.fromJson(json);
          }).toList();
        } catch (parseError) {
          debugPrint('Job Parsing Error: $parseError');
          return [];
        }
      }
      return [];
    } catch (e) {
      debugPrint('Jobs Error: $e');
      return [];
    }
  }

  Future<Job?> getJobById(String id) async {
    try {
      final response = await _dio.get(Endpoints.jobById(id));
      if (response.statusCode == 200) {
        return Job.fromJson(response.data['job']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> likeJob(String id) async {
    try {
      final response = await _dio.post(Endpoints.likeJob(id));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
