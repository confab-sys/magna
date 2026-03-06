import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/feed/domain/post.dart';

import 'package:magna_coders/features/projects/domain/project.dart';
import 'package:magna_coders/features/jobs/domain/job.dart';

class FeedRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> getMixedFeed({int page = 1, int limit = 10}) async {
    try {
      // For now, we'll fetch from different endpoints and mix them client-side
      // Ideally, the backend should provide a unified feed endpoint
      
      final results = await Future.wait([
        _dio.get(Endpoints.postsFeed, queryParameters: {'page': page, 'limit': limit}),
        _dio.get(Endpoints.projects), // Pagination needed here too ideally
        _dio.get(Endpoints.jobs),     // Pagination needed here too ideally
      ]);

      final postsResponse = results[0];
      final projectsResponse = results[1];
      final jobsResponse = results[2];

      List<dynamic> mixedContent = [];

      if (postsResponse.statusCode == 200) {
        final List<dynamic> postsJson = postsResponse.data['posts'];
        mixedContent.addAll(postsJson.map((json) => Post.fromJson(json)));
      }

      if (projectsResponse.statusCode == 200) {
        final List<dynamic> projectsJson = projectsResponse.data['projects'];
        mixedContent.addAll(projectsJson.map((json) => Project.fromJson(json)));
      }

      if (jobsResponse.statusCode == 200) {
        final List<dynamic> jobsJson = jobsResponse.data['jobs'];
        mixedContent.addAll(jobsJson.map((json) => Job.fromJson(json)));
      }

      // Shuffle for randomness
      mixedContent.shuffle();
      
      // Since we are fetching all projects/jobs each time (no pagination on those endpoints yet),
      // we need to slice manually to simulate pagination or just return a subset
      // For true infinite scroll, backend needs to support mixed pagination.
      // Here we just return a slice of the shuffled content to simulate a "page"
      
      return mixedContent.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Post>> getFeed({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        Endpoints.postsFeed, 
        queryParameters: {'page': page, 'limit': limit}
      );
      if (response.statusCode == 200) {
        final List<dynamic> postsJson = response.data['posts'];
        return postsJson.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // TODO: Log error
      return [];
    }
  }

  Future<Post?> getPost(String id) async {
    try {
      final response = await _dio.get(Endpoints.postById(id));
      if (response.statusCode == 200) {
        return Post.fromJson(response.data['post']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      final response = await _dio.post(Endpoints.likePost(postId));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createPost({required String title, String? content}) async {
    try {
      final response = await _dio.post(Endpoints.posts, data: {
        'title': title,
        'content': content,
        'post_type': 'regular',
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
