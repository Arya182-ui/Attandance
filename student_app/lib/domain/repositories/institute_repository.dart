import '../entities/institute_entity.dart';

abstract class InstituteRepository {
  Future<InstituteEntity> getInstituteSettings();
  Stream<InstituteEntity> watchInstituteSettings();
}
