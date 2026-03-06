import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart'; // Added for MediaType
import 'package:image_picker/image_picker.dart';
import 'package:magna_coders/core/network/api_client.dart';

class CreateProjectRequest {
  final String title;
  final String shortDescription;
  final String description;
  final String? categoryId;
  final String visibility;
  final String status;
  final List<String> techStack;
  final bool lookingForContributors;
  final int? maxContributors;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? repositoryUrl;
  final XFile? imageFile;

  CreateProjectRequest({
    required this.title,
    required this.shortDescription,
    required this.description,
    this.categoryId,
    this.visibility = 'public',
    this.status = 'published',
    required this.techStack,
    required this.lookingForContributors,
    this.maxContributors,
    this.startDate,
    this.endDate,
    this.repositoryUrl,
    this.imageFile,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      'title': title,
      'short_description': shortDescription,
      'description': description,
      'visibility': visibility,
      'status': status,
      'tech_stack': jsonEncode(techStack), // Stringify for multipart
      'looking_for_contributors': lookingForContributors.toString(), // Convert to string for multipart
    };

    if (categoryId != null) data['category_id'] = categoryId;
    if (maxContributors != null) data['max_contributors'] = maxContributors.toString();
    if (startDate != null) data['start_date'] = startDate!.toIso8601String();
    if (endDate != null) data['end_date'] = endDate!.toIso8601String();
    if (repositoryUrl != null) data['repository_url'] = repositoryUrl;

    if (imageFile != null) {
      final bytes = await imageFile!.readAsBytes();
      if (bytes.isNotEmpty) {
        data['image'] = MultipartFile.fromBytes(
          bytes,
          filename: imageFile!.name.isNotEmpty ? imageFile!.name : 'project-image.jpg',
          contentType: MediaType('image', 'jpeg'), // Default to jpeg if unknown
        );
      }
    }

    return FormData.fromMap(data);
  }
}

class ProjectCreateApi {
  final Dio _dio = ApiClient.dio;

  Future<String?> createProject(CreateProjectRequest request) async {
    try {
      final formData = await request.toFormData();
      final response = await _dio.post('/api/projects', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // The backend returns { "message": "Project created", "id": "..." }
        return response.data['id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
