import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/institute_model.dart';

class InstituteDataSource {
  final FirebaseFirestore _firestore;

  InstituteDataSource(this._firestore);

  Future<InstituteModel> getSettings() async {
    final doc = await _firestore.collection('institute').doc('settings').get();

    if (!doc.exists) {
      throw Exception('Institute settings not found');
    }

    return InstituteModel.fromFirestore(doc.data()!);
  }

  Stream<InstituteModel> watchSettings() {
    return _firestore
        .collection('institute')
        .doc('settings')
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('Institute settings not found');
      }
      return InstituteModel.fromFirestore(doc.data()!);
    });
  }
}
