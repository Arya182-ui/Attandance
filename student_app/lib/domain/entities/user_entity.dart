class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'student'
  final String? enrollmentNumber;
  final String? course;
  final String? batch;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  final String? instituteId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.enrollmentNumber,
    this.course,
    this.batch,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.instituteId,
  });

  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isStudent => role == 'student';
}
