import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/notifications/data/dto/notification_dto.dart';

class NotificationsApiService {
  final Dio _dio;

  NotificationsApiService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<List<NotificationDto>> getNotifications() async {
    final response = await _dio.get(Endpoints.notifications);

    final data = response.data;
    debugPrint('NotificationsApiService.getNotifications status=${response.statusCode} data=$data');
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Unexpected notifications response shape',
      );
    }

    final success = data['success'] as bool? ?? response.statusCode == 200;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: data['error']?['message'] as String? ??
            'Failed to load notifications',
      );
    }

    final List<dynamic> rawList =
        (data['notifications'] as List?) ?? (data['data'] as List? ?? <dynamic>[]);

    final dtos = rawList
        .map((json) => NotificationDto.fromJson(json as Map<String, dynamic>))
        .toList();

    debugPrint('NotificationsApiService.getNotifications -> count=${dtos.length}');
    return dtos;
  }

  Future<void> markAsRead(String id) async {
    final response = await _dio.put(Endpoints.markNotificationRead(id));
    final data = response.data;
    final success = data is Map<String, dynamic>
        ? (data['success'] as bool? ?? response.statusCode == 200)
        : response.statusCode == 200;

    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to mark notification as read',
      );
    }
  }

  Future<void> markAllAsRead() async {
    final response = await _dio.put(Endpoints.markAllNotificationsRead);
    final data = response.data;
    final success = data is Map<String, dynamic>
        ? (data['success'] as bool? ?? response.statusCode == 200)
        : response.statusCode == 200;

    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to mark all notifications as read',
      );
    }
  }
}

