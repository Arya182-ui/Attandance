class AttendanceEntity {
  final String id;
  final String studentId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final LocationPoint? checkInLocation;
  final LocationPoint? checkOutLocation;
  final String status; // 'checked_in', 'checked_out', 'absent'
  final DateTime createdAt;

  const AttendanceEntity({
    required this.id,
    required this.studentId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    required this.status,
    required this.createdAt,
  });

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;
}

class LocationPoint {
  final double latitude;
  final double longitude;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
  });
}
