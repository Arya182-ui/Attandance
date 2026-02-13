import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'providers.dart';

final adminAuthStateProvider = StreamProvider<UserEntity?>((ref) {
  final authRepository = ref.watch(adminAuthRepositoryProvider);
  return authRepository.authStateChanges;
});

class AdminAuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref _ref;

  AdminAuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      final user = await _ref.read(adminAuthRepositoryProvider).getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref.read(adminAuthRepositoryProvider).signInWithEmailPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _ref.read(adminAuthRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final adminAuthNotifierProvider = StateNotifierProvider<AdminAuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AdminAuthNotifier(ref);
});
