import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminAuthDataSource(this._auth, this._firestore);

  Future<UserModel?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) return null;

    final userDoc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (!userDoc.exists) return null;

    final user = UserModel.fromFirestore(userDoc.data()!, userDoc.id);
    
    if (!user.isAdmin) {
      await _auth.signOut();
      throw Exception('Only admins can access this panel');
    }

    return user;
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
