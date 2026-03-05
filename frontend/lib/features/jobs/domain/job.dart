import 'package:json_annotation/json_annotation.dart';

part 'job.g.dart';

@JsonSerializable()
class Job {
  final String id;
  final String title;
  final String description;
  
  @JsonKey(name: 'company_id')
  final String? companyId;
  
  final String? location;
  final String? salary;
  
  @JsonKey(name: 'job_type')
  final String? jobType;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    this.companyId,
    this.location,
    this.salary,
    this.jobType,
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
  Map<String, dynamic> toJson() => _$JobToJson(this);
}
