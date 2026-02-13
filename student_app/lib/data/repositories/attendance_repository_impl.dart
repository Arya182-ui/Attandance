import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceDataSource _dataSource;

  AttendanceRepositoryImpl(this._dataSource);

  @override
  Future<void> checkIn({
    required String studentId,
    required DateTime checkInTime,
    required LocationPoint location,
  }) {
    return _dataSource.checkIn(
      studentId: studentId,
      checkInTime: checkInTime,
      location: location,
    );
  }

  @override
  Future<void> checkOut({
    required String studentId,
    required DateTime checkOutTime,
    required LocationPoint location,
  }) {
    return _dataSource.checkOut(
      studentId: studentId,
      checkOutTime: checkOutTime,
      location: location,
    );
  }

  @override
  Future<bool> hasCheckedInToday(String studentId) {
    return _dataSource.hasCheckedInToday(studentId);
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory(String studentId) {
    return _dataSource.getAttendanceHistory(studentId);
  }

  @override
  Stream<AttendanceEntity?> getTodayAttendance(String studentId) {
    return _dataSource.getTodayAttendance(studentId);
  }
}
