import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthDataSource(this._auth, this._firestore);

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed. Please try again.');
      }

      // Try to get user data from Firestore, but don't fail if unavailable
      String role = 'student';
      String name = credential.user!.displayName ?? credential.user!.email?.split('@')[0] ?? 'Student';
      String? instituteId;
      String? enrollmentNumber;
      String? course;
      String? batch;
      String? phone;
      String? address;
      String? profileImageUrl;
      
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get()
            .timeout(const Duration(seconds: 10));
            
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            role = data['role'] ?? 'student';
            name = data['name'] ?? name;
            instituteId = data['instituteId'];
            enrollmentNumber = data['enrollmentNumber'];
            course = data['course'];
            batch = data['batch'];
            phone = data['phone'];
            address = data['address'];
            profileImageUrl = data['profileImageUrl'];
          }
        }
      } catch (e) {
        // Firestore read failed, use defaults
        // Log error for debugging (remove print in production)
        // print('Warning: Could not fetch user data from Firestore: $e');
      }

      return UserModel(
        id: credential.user!.uid,
        email: credential.user!.email ?? email,
        name: name,
        role: role,
        instituteId: instituteId,
        enrollmentNumber: enrollmentNumber,
        course: course,
        batch: batch,
        phone: phone,
        address: address,
        profileImageUrl: profileImageUrl,
      );
      
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception(
            '❌ Account Not Found\n\n'
            'No student account exists with this email address.\n\n'
            'Please check your email or contact your administrator.'
          );
        case 'wrong-password':
          throw Exception(
            '🔒 Incorrect Password\n\n'
            'The password you entered is incorrect.\n\n'
            'Please try again or reset your password.'
          );
        case 'invalid-email':
          throw Exception(
            '📧 Invalid Email Format\n\n'
            'Please enter a valid email address.'
          );
        case 'user-disabled':
          throw Exception(
            '🚫 Account Disabled\n\n'
            'Your student account has been disabled.\n\n'
            'Please contact your administrator for assistance.'
          );
        case 'too-many-requests':
          throw Exception(
            '⏱️ Too Many Attempts\n\n'
            'Too many failed login attempts.\n\n'
            'Please wait a few minutes and try again.'
          );
        case 'invalid-credential':
        case 'invalid-login-credentials':
          throw Exception(
            '❌ Invalid Credentials\n\n'
            'The email or password is incorrect.\n\n'
            'Please check your credentials and try again.'
          );
        case 'network-request-failed':
          throw Exception(
            '🌐 Network Error\n\n'
            'Unable to connect to the server.\n\n'
            'Please check your internet connection and try again.'
          );
        default:
          throw Exception(
            '⚠️ Login Failed\n\n'
            '${e.message ?? "An unknown error occurred"}\n\n'
            'Please try again or contact support if the problem persists.'
          );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        '⚠️ Login Error\n\n'
        'An unexpected error occurred during login.\n\n'
        'Please try again or contact support if the problem persists.'
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    // Try to get user data from Firestore with proper error handling
    String role = 'student';
    String name = currentUser.displayName ?? currentUser.email?.split('@')[0] ?? 'Student';
    String? instituteId;
    String? enrollmentNumber;
    String? course;
    String? batch;
    String? phone;
    String? address;
    String? profileImageUrl;
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .timeout(const Duration(seconds: 10));
          
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          role = data['role'] ?? 'student';
          name = data['name'] ?? name;
          instituteId = data['instituteId'];
          enrollmentNumber = data['enrollmentNumber'];
          course = data['course'];
          batch = data['batch'];
          phone = data['phone'];
          address = data['address'];
          profileImageUrl = data['profileImageUrl'];
        }
      } else {
        // User document doesn't exist - use defaults
        // print('Warning: User document does not exist in Firestore for UID: ${currentUser.uid}');
      }
    } catch (e) {
      // Use defaults
      // print('Warning: Could not fetch user data from Firestore: $e');
    }

    return UserModel(
      id: currentUser.uid,
      email: currentUser.email ?? '',
      name: name,
      role: role,
      instituteId: instituteId,
      enrollmentNumber: enrollmentNumber,
      course: course,
      batch: batch,
      phone: phone,
      address: address,
      profileImageUrl: profileImageUrl,
    );
  }

  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }

      // Try to fetch full user data from Firestore
      String role = 'student';
      String name = user.displayName ?? user.email?.split('@')[0] ?? 'Student';
      String? instituteId;
      String? enrollmentNumber;
      String? course;
      String? batch;
      String? phone;
      String? address;
      String? profileImageUrl;
      
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 10));
            
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            role = data['role'] ?? 'student';
            name = data['name'] ?? name;
            instituteId = data['instituteId'];
            enrollmentNumber = data['enrollmentNumber'];
            course = data['course'];
            batch = data['batch'];
            phone = data['phone'];
            address = data['address'];
            profileImageUrl = data['profileImageUrl'];
          }
        }
      } catch (e) {
        // Firestore read failed in auth state changes
        // print('Warning: Could not fetch user data in authStateChanges: $e');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: name,
        role: role,
        instituteId: instituteId,
        enrollmentNumber: enrollmentNumber,
        course: course,
        batch: batch,
        phone: phone,
        address: address,
        profileImageUrl: profileImageUrl,
      );
    });
  }
}
