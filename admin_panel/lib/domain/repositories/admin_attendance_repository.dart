import '../entities/attendance_entity.dart';

abstract class AdminAttendanceRepository {
  Future<List<AttendanceEntity>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
    String? studentId,
  });

  Future<List<AttendanceEntity>> getAttendanceByDate(DateTime date);
  
  Future<List<AttendanceEntity>> getAttendanceByStudent(String studentId);
  
  Stream<List<AttendanceEntity>> watchAllAttendance();
}
