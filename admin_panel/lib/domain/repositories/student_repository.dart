import '../entities/user_entity.dart';

abstract class StudentRepository {
  Future<List<UserEntity>> getAllStudents();
  Future<void> addStudent(UserEntity student, String password);
  Future<void> updateStudent(UserEntity student);
  Future<void> deleteStudent(String studentId);
  Stream<List<UserEntity>> watchStudents();
}
