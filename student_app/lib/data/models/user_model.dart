import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.enrollmentNumber,
    super.course,
    super.batch,
    super.phone,
    super.address,
    super.profileImageUrl,
    super.instituteId,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      enrollmentNumber: data['enrollmentNumber'],
      course: data['course'],
      batch: data['batch'],
      phone: data['phone'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      instituteId: data['instituteId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (enrollmentNumber != null) 'enrollmentNumber': enrollmentNumber,
      if (course != null) 'course': course,
      if (batch != null) 'batch': batch,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (instituteId != null) 'instituteId': instituteId,
    };
  }
}
