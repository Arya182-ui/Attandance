class InstituteEntity {
  final String? name;
  final String? address;
  final double latitude;
  final double longitude;
  final double radius; // in meters (maps to both 'radius' and 'allowedRadius' in Firestore)
  final List<String>? adminEmails;

  const InstituteEntity({
    this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.adminEmails,
  });
}
