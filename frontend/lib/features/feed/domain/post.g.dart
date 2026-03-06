// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      postType: json['post_type'] as String? ?? 'regular',
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String?,
      authorAvatar: json['author_avatar'] as String?,
      imageUrl: json['image_url'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isLiked: (json['is_liked'] as dynamic) is int 
          ? (json['is_liked'] as int) == 1 
          : (json['is_liked'] as bool? ?? false),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'post_type': instance.postType,
      'author_id': instance.authorId,
      'author_name': instance.authorName,
      'author_avatar': instance.authorAvatar,
      'image_url': instance.imageUrl,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'is_liked': instance.isLiked,
      'created_at': instance.createdAt.toIso8601String(),
    };
