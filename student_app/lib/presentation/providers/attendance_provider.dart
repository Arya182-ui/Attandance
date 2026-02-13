import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/attendance_entity.dart';
import 'providers.dart';

final todayAttendanceProvider = StreamProvider.family<AttendanceEntity?, String>((ref, studentId) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getTodayAttendance(studentId);
});

final attendanceHistoryProvider = FutureProvider.family<List<AttendanceEntity>, String>((ref, studentId) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getAttendanceHistory(studentId);
});

class AttendanceNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AttendanceNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> checkIn(String studentId) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(checkInUseCaseProvider);
      await useCase(studentId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> checkOut(String studentId) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(checkOutUseCaseProvider);
      await useCase(studentId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final attendanceNotifierProvider = StateNotifierProvider<AttendanceNotifier, AsyncValue<void>>((ref) {
  return AttendanceNotifier(ref);
});
