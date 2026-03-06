class CreatePostRequest {
  final String title;
  final String? content;
  final String postType;
  final String? categoryId;
  final String? imageUrl;

  CreatePostRequest({
    required this.title,
    this.content,
    this.postType = 'regular',
    this.categoryId,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (content != null) 'content': content,
      'post_type': postType,
      if (categoryId != null) 'category_id': categoryId,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
