import '../../domain/entities/institute_entity.dart';

class InstituteModel extends InstituteEntity {
  const InstituteModel({
    required super.latitude,
    required super.longitude,
    required super.radius,
  });

  factory InstituteModel.fromFirestore(Map<String, dynamic> data) {
    return InstituteModel(
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      radius: (data['radius'] ?? 100.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}
