import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:magna_coders/core/network/api_client.dart';

class UserGuideRequest {
  final String gender;
  final XFile? profilePicture;
  final List<String> roles;
  final List<String> goals;
  final List<String> specialisations;
  final List<String> skills;
  final List<String> availability;
  final String bio;
  final String country;
  final String? county;

  UserGuideRequest({
    required this.gender,
    this.profilePicture,
    required this.roles,
    required this.goals,
    required this.specialisations,
    required this.skills,
    required this.availability,
    required this.bio,
    required this.country,
    this.county,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      'gender': gender,
      'roles': jsonEncode(roles),
      'goals': jsonEncode(goals),
      'specialisations': jsonEncode(specialisations),
      'skills': jsonEncode(skills),
      'availability': jsonEncode(availability),
      'bio': bio,
      'country': country,
    };

    if (county != null && county!.isNotEmpty) {
      data['county'] = county;
    }

    if (profilePicture != null) {
      final bytes = await profilePicture!.readAsBytes();
      if (bytes.isNotEmpty) {
        data['profile_picture'] = MultipartFile.fromBytes(
          bytes,
          filename: profilePicture!.name.isNotEmpty ? profilePicture!.name : 'profile-picture.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
      }
    }

    return FormData.fromMap(data);
  }
}

class UserGuideApi {
  final Dio _dio = ApiClient.dio;

  Future<bool> submitUserGuide(UserGuideRequest request) async {
    try {
      debugPrint('📤 Submitting user guide...');
      final formData = await request.toFormData();
      final response = await _dio.post('/api/user-guide', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ User guide submitted successfully');
        return true;
      }
      debugPrint('❌ User guide submission failed: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      debugPrint('❌ User guide submission error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return false;
    }
  }
}
