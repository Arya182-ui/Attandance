import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  Future<UserEntity?> call(String email, String password) async {
    final user = await _authRepository.signInWithEmailPassword(email, password);
    
    if (user != null && !user.isStudent) {
      throw Exception('Only students can access this app');
    }
    
    return user;
  }
}
