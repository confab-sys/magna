import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  final String id;
  final String title;
  final String description;
  
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  
  @JsonKey(name: 'owner_id')
  final String ownerId;
  
  @JsonKey(name: 'tech_stack')
  final String? techStack;
  
  @JsonKey(name: 'looking_for_contributors')
  final bool lookingForContributors;
  
  @JsonKey(name: 'max_contributors')
  final int? maxContributors;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.shortDescription,
    required this.ownerId,
    this.techStack,
    this.lookingForContributors = false,
    this.maxContributors,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
