import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/features/jobs/domain/create_job_request.dart';

class JobCreateApi {
  final Dio _dio = ApiClient.dio;

  Future<String?> createJob(CreateJobRequest request, {XFile? imageFile}) async {
    try {
      final Map<String, dynamic> data = request.toJson();

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        data['image'] = MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'job-banner.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.post('/api/jobs', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend returns { "message": "Job created", "id": "..." }
        return response.data['id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
