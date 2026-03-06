// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      companyName: json['company_name'] as String,
      companyLogoUrl: json['company_logo_url'] as String?,
      companyVerified: json['company_verified'] as bool? ?? false,
      jobImageUrl: json['job_image_url'] as String?,
      location: json['location'] as String,
      salary: json['salary'] as String?,
      jobType: json['job_type'] as String,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'company_name': instance.companyName,
      'company_logo_url': instance.companyLogoUrl,
      'company_verified': instance.companyVerified,
      'job_image_url': instance.jobImageUrl,
      'location': instance.location,
      'salary': instance.salary,
      'job_type': instance.jobType,
      'deadline': instance.deadline?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'is_liked': instance.isLiked,
    };
