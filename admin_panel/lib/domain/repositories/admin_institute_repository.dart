import '../entities/institute_entity.dart';

abstract class AdminInstituteRepository {
  Future<InstituteEntity> getSettings();
  Future<void> updateSettings(InstituteEntity settings);
  Stream<InstituteEntity> watchSettings();
}
