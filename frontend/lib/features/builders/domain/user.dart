import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  
  final String? location;
  final String? bio;
  final String? tagline;
  final String? role;

  User({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.location,
    this.bio,
    this.tagline,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
