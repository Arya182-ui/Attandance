import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminAuthDataSource(this._auth, this._firestore);

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed. Please try again.');
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      UserModel user;
      
      if (!userDoc.exists) {
        // Check if user email is in allowed admin emails
        final allowedAdminEmails = [
          'admin@attendance.com', 
          'administrator@gmail.com', 
          'arya@admin.com'
        ];
        
        if (allowedAdminEmails.contains(email.toLowerCase())) {
          // Auto-create admin user document
          print('Creating admin user document for: $email');
          await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .set({
            'name': 'Admin User',
            'email': email,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          user = UserModel(
            id: credential.user!.uid,
            name: 'Admin User',
            email: email,
            role: 'admin',
          );
        } else {
          await _auth.signOut();
          throw Exception('User account not found. Please contact administrator.');
        }
      } else {
        user = UserModel.fromFirestore(userDoc.data()!, userDoc.id);
      }
      
      if (!user.isAdmin) {
        await _auth.signOut();
        throw Exception('Access denied. Only admins can access this panel.');
      }

      return user;
      
    } on FirebaseAuthException catch (e) {
      await _auth.signOut(); // Ensure user is signed out on error
      
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
      await _auth.signOut();
      if (e.toString().contains('Only admins can access') || 
          e.toString().contains('Access denied') ||
          e.toString().contains('User account not found')) {
        rethrow; // Re-throw our custom exceptions
      }
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) return null;

    return UserModel.fromFirestore(userDoc.data()!, userDoc.id);
  }

  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc.data()!, userDoc.id);
    });
  }
}
