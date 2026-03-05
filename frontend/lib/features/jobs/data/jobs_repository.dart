import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/jobs/domain/job.dart';

class JobsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Job>> getJobs() async {
    try {
      final response = await _dio.get(Endpoints.jobs);
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['opportunities'];
        return list.map((json) => Job.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createJob(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(Endpoints.jobs, data: data);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
