import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/attendance_entity.dart';
import 'providers.dart';

final allAttendanceProvider = StreamProvider<List<AttendanceEntity>>((ref) {
  final repository = ref.watch(adminAttendanceRepositoryProvider);
  return repository.watchAllAttendance();
});

final filteredAttendanceProvider = FutureProvider.family<List<AttendanceEntity>, AttendanceFilters>((ref, filters) async {
  final repository = ref.watch(adminAttendanceRepositoryProvider);
  return repository.getAllAttendance(
    startDate: filters.startDate,
    endDate: filters.endDate,
    studentId: filters.studentId,
  );
});

class AttendanceFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? studentId;

  AttendanceFilters({
    this.startDate,
    this.endDate,
    this.studentId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceFilters &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          studentId == other.studentId;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode ^ studentId.hashCode;
}
