import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<void> checkIn({
    required String studentId,
    required DateTime checkInTime,
    required LocationPoint location,
  });

  Future<void> checkOut({
    required String studentId,
    required DateTime checkOutTime,
    required LocationPoint location,
  });

  Future<bool> hasCheckedInToday(String studentId);

  Future<List<AttendanceEntity>> getAttendanceHistory(String studentId);

  Stream<AttendanceEntity?> getTodayAttendance(String studentId);
}
