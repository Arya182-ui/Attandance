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

      print('DEBUG signIn: User authenticated with UID: ${credential.user!.uid}');
      
      // Just return a placeholder - don't read from Firestore yet
      // This avoids permission issues during login
      return UserModel(
        id: credential.user!.uid,
        email: credential.user!.email ?? email,
        name: credential.user!.displayName ?? email.split('@')[0],
        role: 'student',
      );
      
    } on FirebaseAuthException catch (e) {
      print('DEBUG signIn: FirebaseAuthException - ${e.code}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email address.');
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later.');
        case 'invalid-credential':
          throw Exception('Invalid email or password. Please check and try again.');
        case 'network-request-failed':
          throw Exception('Network error. Please check your internet connection.');
        default:
          throw Exception('Login failed: ${e.message ?? 'Unknown error occurred'}');
      }
    } catch (e) {
      print('DEBUG signIn: Exception - $e');
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    // Return placeholder without Firestore read for now
    return UserModel(
      id: currentUser.uid,
      email: currentUser.email ?? '',
      name: currentUser.displayName ?? 'User',
      role: 'student',
    );
  }

  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      print('DEBUG authStateChanges: user = ${user?.uid}');
      
      if (user == null) {
        print('DEBUG authStateChanges: user is null, returning null');
        return null;
      }

      // Don't read Firestore here - just return a placeholder
      // The signIn method will handle proper user loading
      print('DEBUG authStateChanges: returning placeholder user');
      
      // Return a minimal UserModel with just the UID
      // Full user data will be loaded by signIn
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
        role: 'student', // Assume student for now
      );
    });
  }
}
