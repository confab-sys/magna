// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      tagline: json['tagline'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'location': instance.location,
      'bio': instance.bio,
      'tagline': instance.tagline,
      'role': instance.role,
    };
