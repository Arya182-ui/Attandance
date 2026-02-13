import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/admin_auth_repository.dart';
import '../datasources/admin_auth_datasource.dart';

class AdminAuthRepositoryImpl implements AdminAuthRepository {
  final AdminAuthDataSource _dataSource;

  AdminAuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity?> signInWithEmailPassword(String email, String password) {
    return _dataSource.signIn(email, password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges();
}
