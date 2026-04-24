import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  Future<UserEntity?> call(String email, String password) async {
    final user = await _authRepository.signInWithEmailPassword(email, password);
    
    if (user != null && !user.isStudent) {
      throw Exception(
        '⚠️ Access Denied\n\n'
        'You are trying to access the Student App with an Admin account.\n\n'
        'This app is for students only.\n\n'
        'If you are an administrator, please use the Admin Panel instead.'
      );
    }
    
    return user;
  }
}
