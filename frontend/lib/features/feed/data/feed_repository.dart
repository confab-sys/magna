import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/feed/domain/post.dart';

class FeedRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Post>> getFeed() async {
    try {
      final response = await _dio.get(Endpoints.postsFeed);
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
