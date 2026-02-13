import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/institute_entity.dart';
import 'providers.dart';

final instituteSettingsProvider = StreamProvider<InstituteEntity>((ref) {
  final repository = ref.watch(adminInstituteRepositoryProvider);
  return repository.watchSettings();
});

class InstituteNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  InstituteNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateSettings({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    state = const AsyncValue.loading();
    try {
      final settings = InstituteEntity(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      await _ref.read(adminInstituteRepositoryProvider).updateSettings(settings);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final instituteNotifierProvider = StateNotifierProvider<InstituteNotifier, AsyncValue<void>>((ref) {
  return InstituteNotifier(ref);
});
