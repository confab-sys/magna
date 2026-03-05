import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationItem {
  final String id;
  final String title;
  final String message;
  
  @JsonKey(name: 'is_read')
  final bool isRead;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}
