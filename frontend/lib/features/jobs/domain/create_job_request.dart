class CreateJobRequest {
  final String title;
  final String description;
  final String? companyId;
  final String? location;
  final String? salary;
  final String? jobType;
  final DateTime? deadline;
  final String? categoryId;
  final String? jobImageUrl;

  CreateJobRequest({
    required this.title,
    required this.description,
    this.companyId,
    this.location,
    this.salary,
    this.jobType,
    this.deadline,
    this.categoryId,
    this.jobImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      if (companyId != null) 'company_id': companyId,
      if (location != null) 'location': location,
      if (salary != null) 'salary': salary,
      if (jobType != null) 'job_type': jobType,
      if (deadline != null) 'deadline': deadline!.toIso8601String(),
      if (categoryId != null) 'category_id': categoryId,
      if (jobImageUrl != null) 'job_image_url': jobImageUrl,
    };
  }
}
