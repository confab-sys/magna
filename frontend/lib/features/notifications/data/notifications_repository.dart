import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/notifications/domain/notification.dart';

class NotificationsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await _dio.get(Endpoints.notifications);
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['notifications'];
        return list.map((json) => NotificationItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await _dio.put(Endpoints.markNotificationRead(id));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
