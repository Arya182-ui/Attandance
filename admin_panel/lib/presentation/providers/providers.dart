import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_auth_datasource.dart';
import '../../data/datasources/student_datasource.dart';
import '../../data/datasources/admin_attendance_datasource.dart';
import '../../data/datasources/admin_institute_datasource.dart';
import '../../data/repositories/admin_auth_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/repositories/admin_attendance_repository_impl.dart';
import '../../data/repositories/admin_institute_repository_impl.dart';
import '../../domain/repositories/admin_auth_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/admin_attendance_repository.dart';
import '../../domain/repositories/admin_institute_repository.dart';

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Data sources
final adminAuthDataSourceProvider = Provider<AdminAuthDataSource>((ref) {
  return AdminAuthDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  );
});

final studentDataSourceProvider = Provider<StudentDataSource>((ref) {
  return StudentDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  );
});

final adminAttendanceDataSourceProvider = Provider<AdminAttendanceDataSource>((ref) {
  return AdminAttendanceDataSource(ref.watch(firebaseFirestoreProvider));
});

final adminInstituteDataSourceProvider = Provider<AdminInstituteDataSource>((ref) {
  return AdminInstituteDataSource(ref.watch(firebaseFirestoreProvider));
});

// Repositories
final adminAuthRepositoryProvider = Provider<AdminAuthRepository>((ref) {
  return AdminAuthRepositoryImpl(ref.watch(adminAuthDataSourceProvider));
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(ref.watch(studentDataSourceProvider));
});

final adminAttendanceRepositoryProvider = Provider<AdminAttendanceRepository>((ref) {
  return AdminAttendanceRepositoryImpl(ref.watch(adminAttendanceDataSourceProvider));
});

final adminInstituteRepositoryProvider = Provider<AdminInstituteRepository>((ref) {
  return AdminInstituteRepositoryImpl(ref.watch(adminInstituteDataSourceProvider));
});
