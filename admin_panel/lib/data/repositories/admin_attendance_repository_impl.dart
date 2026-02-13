import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/admin_attendance_repository.dart';
import '../datasources/admin_attendance_datasource.dart';

class AdminAttendanceRepositoryImpl implements AdminAttendanceRepository {
  final AdminAttendanceDataSource _dataSource;

  AdminAttendanceRepositoryImpl(this._dataSource);

  @override
  Future<List<AttendanceEntity>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
    String? studentId,
  }) {
    return _dataSource.getAllAttendance(
      startDate: startDate,
      endDate: endDate,
      studentId: studentId,
    );
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceByDate(DateTime date) {
    return _dataSource.getAttendanceByDate(date);
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceByStudent(String studentId) {
    return _dataSource.getAttendanceByStudent(studentId);
  }

  @override
  Stream<List<AttendanceEntity>> watchAllAttendance() {
    return _dataSource.watchAllAttendance();
  }
}
