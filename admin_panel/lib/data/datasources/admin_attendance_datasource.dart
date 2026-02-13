import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AdminAttendanceDataSource {
  final FirebaseFirestore _firestore;

  AdminAttendanceDataSource(this._firestore);

  Future<List<AttendanceModel>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
    String? studentId,
  }) async {
    Query query = _firestore.collection('attendance');

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    query = query.orderBy('date', descending: true);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<AttendanceModel>> getAttendanceByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<AttendanceModel>> getAttendanceByStudent(String studentId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Stream<List<AttendanceModel>> watchAllAttendance() {
    return _firestore
        .collection('attendance')
        .orderBy('date', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
