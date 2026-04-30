/// User entity - mirrors the User model from Laravel backend
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.emailVerifiedAt,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isVerified => emailVerifiedAt != null;
}
