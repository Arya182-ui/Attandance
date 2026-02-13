import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class StudentDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StudentDataSource(this._auth, this._firestore);

  Future<List<UserModel>> getAllStudents() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addStudent(UserModel student, String password) async {
    // Create auth user
    final credential = await _auth.createUserWithEmailAndPassword(
      email: student.email,
      password: password,
    );

    // Create user document
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': student.name,
      'email': student.email,
      'role': 'student',
    });
  }

  Future<void> updateStudent(UserModel student) async {
    await _firestore.collection('users').doc(student.id).update({
      'name': student.name,
      'email': student.email,
    });
  }

  Future<void> deleteStudent(String studentId) async {
    await _firestore.collection('users').doc(studentId).delete();
    // Note: Deleting auth user requires admin SDK on backend
  }

  Stream<List<UserModel>> watchStudents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
