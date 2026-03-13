import 'package:cross_file/cross_file.dart';

class UserGuideFormModel {
  final String? gender;
  final XFile? profilePicture;
  final List<String> roles;
  final List<String> goals;
  final List<String> specialisations;
  final List<String> skills;
  final List<String> availability;
  final String bio;
  final String? country;
  final String? county;

  const UserGuideFormModel({
    this.gender,
    this.profilePicture,
    this.roles = const [],
    this.goals = const [],
    this.specialisations = const [],
    this.skills = const [],
    this.availability = const [],
    this.bio = '',
    this.country,
    this.county,
  });

  UserGuideFormModel copyWith({
    String? gender,
    XFile? profilePicture,
    bool clearProfilePicture = false,
    List<String>? roles,
    List<String>? goals,
    List<String>? specialisations,
    List<String>? skills,
    List<String>? availability,
    String? bio,
    String? country,
    String? county,
    bool clearCounty = false,
  }) {
    return UserGuideFormModel(
      gender: gender ?? this.gender,
      profilePicture: clearProfilePicture ? null : (profilePicture ?? this.profilePicture),
      roles: roles ?? this.roles,
      goals: goals ?? this.goals,
      specialisations: specialisations ?? this.specialisations,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      county: clearCounty ? null : (county ?? this.county),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'gender': gender,
      'profilePicturePath': profilePicture?.path,
      'roles': roles,
      'goals': goals,
      'specialisations': specialisations,
      'skills': skills,
      'availability': availability,
      'bio': bio,
      'country': country,
      'county': county,
    };
  }
}

