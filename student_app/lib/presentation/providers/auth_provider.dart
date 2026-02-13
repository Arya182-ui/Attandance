import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'providers.dart';

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(signInUseCaseProvider);
      final user = await useCase(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref);
});
