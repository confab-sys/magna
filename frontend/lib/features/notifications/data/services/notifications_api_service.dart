import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/notifications/data/dto/notification_dto.dart';

class NotificationsApiService {
  final Dio _dio;

  NotificationsApiService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<List<NotificationDto>> getNotifications() async {
    final response = await _dio.get(Endpoints.notifications);

    final data = response.data;
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

    return rawList
        .map((json) => NotificationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    final response = await _dio.patch(Endpoints.markNotificationRead(id));
    final data = response.data;
    final success = data is Map<String, dynamic>
        ? (data['success'] as bool? ?? response.statusCode == 200)
        : response.statusCode == 200;

    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: data is Map<String, dynamic>
            ? data['error']?['message'] as String? ??
                'Failed to mark notification as read'
            : 'Failed to mark notification as read',
      );
    }
  }
}

