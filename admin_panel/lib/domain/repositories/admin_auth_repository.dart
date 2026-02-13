import '../entities/user_entity.dart';

abstract class AdminAuthRepository {
  Future<UserEntity?> signInWithEmailPassword(String email, String password);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
