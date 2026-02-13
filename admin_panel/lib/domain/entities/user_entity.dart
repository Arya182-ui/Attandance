class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'student'

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';
}
