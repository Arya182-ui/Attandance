import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.studentId,
    required super.date,
    super.checkInTime,
    super.checkOutTime,
    super.checkInLocation,
    super.checkOutLocation,
    required super.status,
    required super.createdAt,
  });

  factory AttendanceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AttendanceModel(
      id: id,
      studentId: data['studentId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      checkInTime: data['checkInTime'] != null 
          ? (data['checkInTime'] as Timestamp).toDate() 
          : null,
      checkOutTime: data['checkOutTime'] != null 
          ? (data['checkOutTime'] as Timestamp).toDate() 
          : null,
      checkInLocation: data['checkInLocation'] != null
          ? LocationPoint(
              latitude: data['checkInLocation']['latitude'],
              longitude: data['checkInLocation']['longitude'],
            )
          : null,
      checkOutLocation: data['checkOutLocation'] != null
          ? LocationPoint(
              latitude: data['checkOutLocation']['latitude'],
              longitude: data['checkOutLocation']['longitude'],
            )
          : null,
      status: data['status'] ?? 'absent',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'checkInLocation': checkInLocation != null
          ? {
              'latitude': checkInLocation!.latitude,
              'longitude': checkInLocation!.longitude,
            }
          : null,
      'checkOutLocation': checkOutLocation != null
          ? {
              'latitude': checkOutLocation!.latitude,
              'longitude': checkOutLocation!.longitude,
            }
          : null,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
