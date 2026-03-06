import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/comments/domain/comment.dart';

class CommentsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await _dio.get(Endpoints.commentsByPost(postId));
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['comments'];
        return list.map((json) => Comment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Comment?> addComment(String targetId, String content, {String? parentId, bool isJob = false, bool isProject = false}) async {
    try {
      final data = {
        'content': content,
        'parent_id': parentId,
      };
      
      if (isJob) {
        data['job_id'] = targetId;
      } else if (isProject) {
        data['project_id'] = targetId;
      } else {
        data['post_id'] = targetId;
      }

      final response = await _dio.post(Endpoints.comments, data: data);
      
      if (response.statusCode == 201) {
        return Comment.fromJson(response.data['comment']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      final response = await _dio.delete('${Endpoints.comments}/$commentId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleLike(String commentId) async {
    try {
      final response = await _dio.post(Endpoints.likeComment(commentId));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
