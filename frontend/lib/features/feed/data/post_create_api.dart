import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/features/feed/domain/create_post_request.dart';

class PostCreateApi {
  final Dio _dio = ApiClient.dio;

  Future<String?> createPost(CreatePostRequest request, {XFile? imageFile}) async {
    try {
      final Map<String, dynamic> data = request.toJson();

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        data['image'] = MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'post-image.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.post('/api/posts', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend returns { "message": "Post created", "id": "..." }
        return response.data['id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
