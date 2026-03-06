// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      postId: (json['post_id'] ?? json['job_id'] ?? json['project_id']) as String, // Handle either post_id, job_id, or project_id
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatar: json['author_avatar'] as String?,
      content: json['content'] as String,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: (json['is_liked'] as dynamic) is int 
          ? (json['is_liked'] as int) == 1 
          : (json['is_liked'] as bool? ?? false),
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent_id'] as String?,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'author_id': instance.authorId,
      'author_name': instance.authorName,
      'author_avatar': instance.authorAvatar,
      'content': instance.content,
      'likes_count': instance.likesCount,
      'is_liked': instance.isLiked,
      'created_at': instance.createdAt.toIso8601String(),
      'parent_id': instance.parentId,
    };
