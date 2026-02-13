import 'package:geolocator/geolocator.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class CheckOutUseCase {
  final AttendanceRepository _attendanceRepository;

  CheckOutUseCase(this._attendanceRepository);

  Future<void> call(String studentId) async {
    // Get current location
    final position = await _getCurrentLocation();

    // Perform check-out
    await _attendanceRepository.checkOut(
      studentId: studentId,
      checkOutTime: DateTime.now(),
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
