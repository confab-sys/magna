import 'package:json_annotation/json_annotation.dart';

part 'member_dto.g.dart';

@JsonSerializable()
class MemberDto {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? lastReadMessageId;
  final DateTime? lastReadAt;

  MemberDto({
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.lastReadMessageId,
    required this.lastReadAt,
  });

  factory MemberDto.fromJson(Map<String, dynamic> json) =>
      _$MemberDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MemberDtoToJson(this);
}

