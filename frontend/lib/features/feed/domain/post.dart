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
  
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  
  @JsonKey(name: 'like_count')
  final int likeCount;
  
  @JsonKey(name: 'comment_count')
  final int commentCount;
  
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  
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
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? postType,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
