import '../../domain/entities/institute_entity.dart';
import '../../domain/repositories/institute_repository.dart';
import '../datasources/institute_datasource.dart';

class InstituteRepositoryImpl implements InstituteRepository {
  final InstituteDataSource _dataSource;

  InstituteRepositoryImpl(this._dataSource);

  @override
  Future<InstituteEntity> getInstituteSettings() {
    return _dataSource.getSettings();
  }

  @override
  Stream<InstituteEntity> watchInstituteSettings() {
    return _dataSource.watchSettings();
  }
}
