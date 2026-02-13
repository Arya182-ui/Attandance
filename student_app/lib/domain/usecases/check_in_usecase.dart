import 'package:geolocator/geolocator.dart';
import '../entities/attendance_entity.dart';
import '../entities/institute_entity.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/institute_repository.dart';

class CheckInUseCase {
  final AttendanceRepository _attendanceRepository;
  final InstituteRepository _instituteRepository;

  CheckInUseCase(this._attendanceRepository, this._instituteRepository);

  Future<void> call(String studentId) async {
    // Check if already checked in today
    final hasCheckedIn = await _attendanceRepository.hasCheckedInToday(studentId);
    if (hasCheckedIn) {
      throw Exception('You have already checked in today');
    }

    // Get institute settings
    final institute = await _instituteRepository.getInstituteSettings();

    // Get current location
    final position = await _getCurrentLocation();

    // Validate distance
    final distance = Geolocator.distanceBetween(
      institute.latitude,
      institute.longitude,
      position.latitude,
      position.longitude,
    );

    if (distance > institute.radius) {
      throw Exception(
        'You are outside the allowed radius. Distance: ${distance.toStringAsFixed(0)}m, Allowed: ${institute.radius.toStringAsFixed(0)}m'
      );
    }

    // Perform check-in
    await _attendanceRepository.checkIn(
      studentId: studentId,
      checkInTime: DateTime.now(),
      location: LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
