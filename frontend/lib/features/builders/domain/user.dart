import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  
  @JsonKey(name: 'cover_photo_url')
  final String? coverPhotoUrl;

  final String? location;
  final String? bio;
  final String? tagline;
  final String? role;

  @JsonKey(name: 'website_url')
  final String? websiteUrl;

  @JsonKey(name: 'github_url')
  final String? githubUrl;

  @JsonKey(name: 'linkedin_url')
  final String? linkedinUrl;

  @JsonKey(name: 'twitter_url')
  final String? twitterUrl;

  @JsonKey(name: 'whatsapp_url')
  final String? whatsappUrl;

  @JsonKey(name: 'categories')
  final List<String> categories;

  @JsonKey(name: 'lookingFor')
  final List<String> lookingFor;

  @JsonKey(name: 'skills')
  final List<String> skills;

  User({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.coverPhotoUrl,
    this.location,
    this.bio,
    this.tagline,
    this.role,
    this.websiteUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.whatsappUrl,
    this.categories = const [],
    this.lookingFor = const [],
    this.skills = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
