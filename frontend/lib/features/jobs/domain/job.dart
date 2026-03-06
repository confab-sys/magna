import 'package:json_annotation/json_annotation.dart';

part 'job.g.dart';

@JsonSerializable()
class Job {
  final String id;
  final String title;
  final String description;
  
  @JsonKey(name: 'company_name')
  final String companyName;
  
  @JsonKey(name: 'company_logo_url')
  final String? companyLogoUrl;
  
  @JsonKey(name: 'company_verified')
  final bool companyVerified;
  
  @JsonKey(name: 'job_image_url')
  final String? jobImageUrl;
  
  final String location;
  
  final String? salary;
  
  @JsonKey(name: 'job_type')
  final String jobType;
  
  final DateTime? deadline;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'likes_count')
  final int likesCount;
  
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  
  @JsonKey(name: 'is_liked')
  final bool isLiked;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    this.companyLogoUrl,
    this.companyVerified = false,
    this.jobImageUrl,
    required this.location,
    this.salary,
    required this.jobType,
    this.deadline,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);
    
    // Handle company_verified being 0/1 (int) from backend instead of boolean
    if (data['company_verified'] is int) {
      data['company_verified'] = data['company_verified'] == 1;
    }
    
    // Handle null company_name
    if (data['company_name'] == null) {
      data['company_name'] = 'Unknown Company';
    }
    
    return _$JobFromJson(data);
  }
  Map<String, dynamic> toJson() => _$JobToJson(this);

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? companyName,
    String? companyLogoUrl,
    bool? companyVerified,
    String? jobImageUrl,
    String? location,
    String? salary,
    String? jobType,
    DateTime? deadline,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      companyVerified: companyVerified ?? this.companyVerified,
      jobImageUrl: jobImageUrl ?? this.jobImageUrl,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      jobType: jobType ?? this.jobType,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
