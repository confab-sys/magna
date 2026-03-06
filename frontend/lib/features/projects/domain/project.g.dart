// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String,
      ownerName: json['owner_name'] as String,
      ownerAvatarUrl: json['owner_avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      techStack: (json['tech_stack'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lookingForContributors:
          json['looking_for_contributors'] as bool? ?? false,
      maxContributors: (json['max_contributors'] as num?)?.toInt(),
      repositoryUrl: json['repository_url'] as String?,
      liveDemoUrl: json['live_demo_url'] as String?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String,
      visibility: json['visibility'] as String? ?? 'public',
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'short_description': instance.shortDescription,
      'owner_name': instance.ownerName,
      'owner_avatar_url': instance.ownerAvatarUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'tech_stack': instance.techStack,
      'looking_for_contributors': instance.lookingForContributors,
      'max_contributors': instance.maxContributors,
      'repository_url': instance.repositoryUrl,
      'live_demo_url': instance.liveDemoUrl,
      'image_url': instance.imageUrl,
      'status': instance.status,
      'visibility': instance.visibility,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'is_liked': instance.isLiked,
    };
