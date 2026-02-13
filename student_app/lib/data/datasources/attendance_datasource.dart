import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';
import '../models/attendance_model.dart';

class AttendanceDataSource {
  final FirebaseFirestore _firestore;

  AttendanceDataSource(this._firestore);

  Future<void> checkIn({
    required String studentId,
    required DateTime checkInTime,
    required LocationPoint location,
  }) async {
    final today = _normalizeDate(DateTime.now());
    final dateStr = _formatDate(today);

    final attendance = AttendanceModel(
      id: '',
      studentId: studentId,
      date: today,
      checkInTime: checkInTime,
      checkInLocation: location,
      status: 'checked_in',
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('attendance')
        .doc('${studentId}_$dateStr')
        .set(attendance.toFirestore());
  }

  Future<void> checkOut({
    required String studentId,
    required DateTime checkOutTime,
    required LocationPoint location,
  }) async {
    final today = _normalizeDate(DateTime.now());
    final dateStr = _formatDate(today);
    final docId = '${studentId}_$dateStr';

    await _firestore.collection('attendance').doc(docId).update({
      'checkOutTime': Timestamp.fromDate(checkOutTime),
      'checkOutLocation': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'status': 'checked_out',
    });
  }

  Future<bool> hasCheckedInToday(String studentId) async {
    final today = _normalizeDate(DateTime.now());
    final dateStr = _formatDate(today);
    final docId = '${studentId}_$dateStr';

    final doc = await _firestore.collection('attendance').doc(docId).get();
    return doc.exists;
  }

  Future<List<AttendanceModel>> getAttendanceHistory(String studentId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .limit(30)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Stream<AttendanceModel?> getTodayAttendance(String studentId) {
    final today = _normalizeDate(DateTime.now());
    final dateStr = _formatDate(today);
    final docId = '${studentId}_$dateStr';

    return _firestore
        .collection('attendance')
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return AttendanceModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
