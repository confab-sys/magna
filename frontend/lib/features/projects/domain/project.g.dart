// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      shortDescription: json['short_description'] as String?,
      ownerId: json['owner_id'] as String,
      techStack: json['tech_stack'] as String?,
      lookingForContributors:
          json['looking_for_contributors'] as bool? ?? false,
      maxContributors: (json['max_contributors'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'owner_id': instance.ownerId,
      'tech_stack': instance.techStack,
      'looking_for_contributors': instance.lookingForContributors,
      'max_contributors': instance.maxContributors,
      'created_at': instance.createdAt.toIso8601String(),
    };
