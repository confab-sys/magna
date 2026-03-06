import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  final String id;
  final String title;
  
  @JsonKey(name: 'short_description')
  final String shortDescription;
  
  @JsonKey(name: 'owner_name')
  final String ownerName;
  
  @JsonKey(name: 'owner_avatar_url')
  final String? ownerAvatarUrl;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'tech_stack')
  final List<String> techStack;
  
  @JsonKey(name: 'looking_for_contributors')
  final bool lookingForContributors;
  
  @JsonKey(name: 'max_contributors')
  final int? maxContributors;
  
  @JsonKey(name: 'repository_url')
  final String? repositoryUrl;
  
  @JsonKey(name: 'live_demo_url')
  final String? liveDemoUrl;

  @JsonKey(name: 'image_url')
  final String? imageUrl;
  
  final String status;

  final String visibility;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  
  @JsonKey(name: 'likes_count')
  final int likesCount;
  
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  
  @JsonKey(name: 'is_liked')
  final bool isLiked;

  Project({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.ownerName,
    this.ownerAvatarUrl,
    required this.createdAt,
    required this.techStack,
    this.lookingForContributors = false,
    this.maxContributors,
    this.repositoryUrl,
    this.liveDemoUrl,
    this.imageUrl,
    required this.status,
    this.visibility = 'public',
    this.startDate,
    this.endDate,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? ownerName,
    String? ownerAvatarUrl,
    DateTime? createdAt,
    List<String>? techStack,
    bool? lookingForContributors,
    int? maxContributors,
    String? repositoryUrl,
    String? liveDemoUrl,
    String? imageUrl,
    String? status,
    String? visibility,
    DateTime? startDate,
    DateTime? endDate,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      techStack: techStack ?? this.techStack,
      lookingForContributors: lookingForContributors ?? this.lookingForContributors,
      maxContributors: maxContributors ?? this.maxContributors,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      liveDemoUrl: liveDemoUrl ?? this.liveDemoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
