// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      tagline: json['tagline'] as String?,
      role: json['role'] as String?,
      websiteUrl: json['website_url'] as String?,
      githubUrl: json['github_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      whatsappUrl: json['whatsapp_url'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lookingFor: (json['lookingFor'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'cover_photo_url': instance.coverPhotoUrl,
      'location': instance.location,
      'bio': instance.bio,
      'tagline': instance.tagline,
      'role': instance.role,
      'website_url': instance.websiteUrl,
      'github_url': instance.githubUrl,
      'linkedin_url': instance.linkedinUrl,
      'twitter_url': instance.twitterUrl,
      'whatsapp_url': instance.whatsappUrl,
      'categories': instance.categories,
      'lookingFor': instance.lookingFor,
      'skills': instance.skills,
    };
