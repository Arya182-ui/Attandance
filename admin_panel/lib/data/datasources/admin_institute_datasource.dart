import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/institute_model.dart';

class AdminInstituteDataSource {
  final FirebaseFirestore _firestore;

  AdminInstituteDataSource(this._firestore);

  Future<InstituteModel> getSettings() async {
    final doc = await _firestore.collection('institute').doc('settings').get();

    if (!doc.exists) {
      // Create default settings
      final defaultSettings = const InstituteModel(
        latitude: 0.0,
        longitude: 0.0,
        radius: 100.0,
      );
      await _firestore.collection('institute').doc('settings').set(defaultSettings.toFirestore());
      return defaultSettings;
    }

    return InstituteModel.fromFirestore(doc.data()!);
  }

  Future<void> updateSettings(InstituteModel settings) async {
    await _firestore
        .collection('institute')
        .doc('settings')
        .set(settings.toFirestore());
  }

  Stream<InstituteModel> watchSettings() {
    return _firestore
        .collection('institute')
        .doc('settings')
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return const InstituteModel(
          latitude: 0.0,
          longitude: 0.0,
          radius: 100.0,
        );
      }
      return InstituteModel.fromFirestore(doc.data()!);
    });
  }
}
