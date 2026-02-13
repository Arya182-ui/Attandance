import '../../domain/entities/institute_entity.dart';
import '../../domain/repositories/admin_institute_repository.dart';
import '../datasources/admin_institute_datasource.dart';

class AdminInstituteRepositoryImpl implements AdminInstituteRepository {
  final AdminInstituteDataSource _dataSource;

  AdminInstituteRepositoryImpl(this._dataSource);

  @override
  Future<InstituteEntity> getSettings() {
    return _dataSource.getSettings();
  }

  @override
  Future<void> updateSettings(InstituteEntity settings) {
    return _dataSource.updateSettings(settings as dynamic);
  }

  @override
  Stream<InstituteEntity> watchSettings() {
    return _dataSource.watchSettings();
  }
}
