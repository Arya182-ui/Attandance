import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class StudentDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  static FirebaseAuth? _secondaryAuth;

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
    try {
      print('Creating user with email: ${student.email}');
      
      // Initialize secondary Firebase Auth instance if not already done
      if (_secondaryAuth == null) {
        final secondaryApp = await Firebase.initializeApp(
          name: 'StudentCreation',
          options: Firebase.app().options,
        );
        _secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      }
      
      // Create auth user using secondary auth (won't affect current admin session)
      final credential = await _secondaryAuth!.createUserWithEmailAndPassword(
        email: student.email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user account');
      }

      print('User created with UID: ${credential.user!.uid}');

      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': student.name,
        'email': student.email,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Sign out from secondary auth to cleanup
      await _secondaryAuth!.signOut();
      
      print('User document created successfully');
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password is too weak. Please use at least 6 characters.');
        case 'email-already-in-use':
          throw Exception('An account with this email already exists.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled.');
        default:
          throw Exception('Failed to create account: ${e.message}');
      }
    } catch (e) {
      print('General Error: $e');
      if (e.toString().contains('Failed to create account') || 
          e.toString().contains('Password is too weak') ||
          e.toString().contains('email already exists')||
          e.toString().contains('Invalid email')) {
        rethrow; // Re-throw our custom exceptions
      }
      throw Exception('Failed to add student: ${e.toString()}');
    }
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

  // Cleanup method for secondary Firebase app
  static Future<void> cleanup() async {
    if (_secondaryAuth != null) {
      await _secondaryAuth!.signOut();
      _secondaryAuth = null;
      try {
        await Firebase.app('StudentCreation').delete();
      } catch (e) {
        // App might already be deleted, ignore error
        print('Secondary app cleanup: $e');
      }
    }
  }
}
