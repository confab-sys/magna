import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final String id;
  
  @JsonKey(name: 'post_id')
  final String postId;
  
  @JsonKey(name: 'author_id')
  final String authorId;
  
  @JsonKey(name: 'author_name')
  final String authorName;
  
  @JsonKey(name: 'author_avatar')
  final String? authorAvatar;
  
  final String content;
  
  @JsonKey(name: 'likes_count')
  final int likesCount;
  
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'parent_id')
  final String? parentId;

  Comment({
    required this.id,
    required this.postId,
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
