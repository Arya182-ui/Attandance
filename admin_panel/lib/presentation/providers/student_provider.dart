import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'providers.dart';

final studentsProvider = StreamProvider<List<UserEntity>>((ref) {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.watchStudents();
});

class StudentNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  StudentNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> addStudent(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      print('Provider: Starting to add student - $name, $email');
      
      // Validate inputs
      if (name.trim().isEmpty) {
        throw Exception('Student name cannot be empty');
      }
      if (email.trim().isEmpty || !email.contains('@')) {
        throw Exception('Please provide a valid email address');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      final student = UserEntity(
        id: '',
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: 'student',
      );
      
      await _ref.read(studentRepositoryProvider).addStudent(student, password);
      state = const AsyncValue.data(null);
      print('Provider: Student added successfully');
      
    } catch (e, stack) {
      print('Provider Error: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateStudent(String id, String name, String email) async {
    state = const AsyncValue.loading();
    try {
      final student = UserEntity(
        id: id,
        name: name,
        email: email,
        role: 'student',
      );
      await _ref.read(studentRepositoryProvider).updateStudent(student);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(studentRepositoryProvider).deleteStudent(studentId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final studentNotifierProvider = StateNotifierProvider<StudentNotifier, AsyncValue<void>>((ref) {
  return StudentNotifier(ref);
});
