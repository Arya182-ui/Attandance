import '../../domain/entities/institute_entity.dart';

class InstituteModel extends InstituteEntity {
  const InstituteModel({
    super.name,
    super.address,
    required super.latitude,
    required super.longitude,
    required super.radius,
    super.adminEmails,
  });

  factory InstituteModel.fromFirestore(Map<String, dynamic> data) {
    return InstituteModel(
      name: data['name'],
      address: data['address'],
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      // Support both field names: 'allowedRadius' (admin web) and 'radius' (student app)
      radius: (data['allowedRadius'] ?? data['radius'] ?? 100.0).toDouble(),
      adminEmails: data['adminEmails'] != null 
          ? List<String>.from(data['adminEmails'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'allowedRadius': radius, // Keep both for compatibility with admin web
      if (adminEmails != null) 'adminEmails': adminEmails,
    };
  }
}
