import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final String id;
  final String title;
  final String? content;
  
  @JsonKey(name: 'post_type')
  final String postType;
  
  @JsonKey(name: 'author_id')
  final String authorId;
  
  @JsonKey(name: 'author_name')
  final String? authorName;
  
  @JsonKey(name: 'author_avatar')
  final String? authorAvatar;
  
  @JsonKey(name: 'like_count')
  final int likeCount;
  
  @JsonKey(name: 'comment_count')
  final int commentCount;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    this.content,
    this.postType = 'regular',
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
