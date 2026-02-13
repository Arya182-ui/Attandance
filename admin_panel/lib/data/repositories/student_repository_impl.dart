import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_datasource.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentDataSource _dataSource;

  StudentRepositoryImpl(this._dataSource);

  @override
  Future<List<UserEntity>> getAllStudents() {
    return _dataSource.getAllStudents();
  }

  @override
  Future<void> addStudent(UserEntity student, String password) {
    return _dataSource.addStudent(student as dynamic, password);
  }

  @override
  Future<void> updateStudent(UserEntity student) {
    return _dataSource.updateStudent(student as dynamic);
  }

  @override
  Future<void> deleteStudent(String studentId) {
    return _dataSource.deleteStudent(studentId);
  }

  @override
  Stream<List<UserEntity>> watchStudents() {
    return _dataSource.watchStudents();
  }
}
