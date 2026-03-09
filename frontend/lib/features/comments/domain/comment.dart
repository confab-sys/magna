import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final String id;
  
  @JsonKey(name: 'post_id')
  final String? postId;

  @JsonKey(name: 'job_id')
  final String? jobId;

  @JsonKey(name: 'project_id')
  final String? projectId;
  
  @JsonKey(name: 'author_id')
  final String authorId;
  
  @JsonKey(name: 'author_name')
  final String authorName;
  
  @JsonKey(name: 'author_avatar')
  final String? authorAvatar;
  
  final String content;
  
  @JsonKey(name: 'likes_count')
  final int likesCount;
  
  @JsonKey(name: 'is_liked', fromJson: _isLikedFromJson)
  final bool isLiked;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'parent_id')
  final String? parentId;

  Comment({
    required this.id,
    this.postId,
    this.jobId,
    this.projectId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.parentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

bool _isLikedFromJson(dynamic value) =>
    value == true || value == 1;
