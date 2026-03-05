// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      companyId: json['company_id'] as String?,
      location: json['location'] as String?,
      salary: json['salary'] as String?,
      jobType: json['job_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'company_id': instance.companyId,
      'location': instance.location,
      'salary': instance.salary,
      'job_type': instance.jobType,
      'created_at': instance.createdAt.toIso8601String(),
    };
