class MemberEntity {
  final String id;
  final String userId;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String role;
  final bool isOnline;

  MemberEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.role,
    required this.isOnline,
  });
}

