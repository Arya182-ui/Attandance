import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_datasource.dart';
import '../models/user_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentDataSource _dataSource;

  StudentRepositoryImpl(this._dataSource);

  @override
  Future<List<UserEntity>> getAllStudents() {
    return _dataSource.getAllStudents();
  }

  @override
  Future<void> addStudent(UserEntity student, String password) {
    final userModel = UserModel(
      id: student.id,
      name: student.name,
      email: student.email,
      role: student.role,
    );
    return _dataSource.addStudent(userModel, password);
  }

  @override
  Future<void> updateStudent(UserEntity student) {
    final userModel = UserModel(
      id: student.id,
      name: student.name,
      email: student.email,
      role: student.role,
    );
    return _dataSource.updateStudent(userModel);
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
