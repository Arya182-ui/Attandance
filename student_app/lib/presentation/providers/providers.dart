import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/attendance_datasource.dart';
import '../../data/datasources/institute_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/institute_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/institute_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/check_in_usecase.dart';
import '../../domain/usecases/check_out_usecase.dart';

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Data sources
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  );
});

final attendanceDataSourceProvider = Provider<AttendanceDataSource>((ref) {
  return AttendanceDataSource(ref.watch(firebaseFirestoreProvider));
});

final instituteDataSourceProvider = Provider<InstituteDataSource>((ref) {
  return InstituteDataSource(ref.watch(firebaseFirestoreProvider));
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(attendanceDataSourceProvider));
});

final instituteRepositoryProvider = Provider<InstituteRepository>((ref) {
  return InstituteRepositoryImpl(ref.watch(instituteDataSourceProvider));
});

// Use cases
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final checkInUseCaseProvider = Provider<CheckInUseCase>((ref) {
  return CheckInUseCase(
    ref.watch(attendanceRepositoryProvider),
    ref.watch(instituteRepositoryProvider),
  );
});

final checkOutUseCaseProvider = Provider<CheckOutUseCase>((ref) {
  return CheckOutUseCase(ref.watch(attendanceRepositoryProvider));
});
