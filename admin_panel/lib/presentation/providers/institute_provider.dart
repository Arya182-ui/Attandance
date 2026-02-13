import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/institute_entity.dart';
import 'providers.dart';

final instituteSettingsProvider = StreamProvider<InstituteEntity>((ref) {
  final repository = ref.watch(adminInstituteRepositoryProvider);
  return repository.watchSettings().handleError((error, stackTrace) {
    // Log error for debugging
    print('Institute Settings Stream Error: $error');
    
    // Transform Firebase errors to user-friendly messages
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          throw 'Permission denied: Unable to access institute settings. Please check your admin privileges.';
        case 'unavailable':
          throw 'Service unavailable: Firebase is temporarily unavailable. Please try again later.';
        case 'network-request-failed':
          throw 'Network error: Please check your internet connection and try again.';
        default:
          throw 'Firebase error: ${error.message ?? error.code}';
      }
    }
    
    throw 'Failed to load institute settings: ${error.toString()}';
  });
});

class InstituteNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  InstituteNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateSettings({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // Input validation
      _validateInput(latitude, longitude, radius);
      
      final settings = InstituteEntity(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      
      // Save with timeout and better error handling
      await _ref.read(adminInstituteRepositoryProvider)
          .updateSettings(settings)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw 'Operation timed out. Please check your connection and try again.',
          );
      
      state = const AsyncValue.data(null);
      
      // Log successful update
      print('Institute settings updated successfully: lat=$latitude, lng=$longitude, radius=$radius');
      
    } catch (e, stack) {
      // Enhanced error handling with specific error types
      final transformedError = _transformError(e);
      state = AsyncValue.error(transformedError, stack);
      
      // Log error for debugging
      print('Institute settings update failed: $transformedError');
      print('Stack trace: $stack');
      
      rethrow;
    }
  }

  void _validateInput(double latitude, double longitude, double radius) {
    // Validate latitude
    if (latitude.isNaN || latitude.isInfinite) {
      throw 'Invalid latitude: Must be a valid number';
    }
    if (latitude < -90 || latitude > 90) {
      throw 'Invalid latitude: Must be between -90 and 90 degrees';
    }
    
    // Validate longitude  
    if (longitude.isNaN || longitude.isInfinite) {
      throw 'Invalid longitude: Must be a valid number';
    }
    if (longitude < -180 || longitude > 180) {
      throw 'Invalid longitude: Must be between -180 and 180 degrees';
    }
    
    // Validate radius
    if (radius.isNaN || radius.isInfinite) {
      throw 'Invalid radius: Must be a valid number';
    }
    if (radius <= 0) {
      throw 'Invalid radius: Must be greater than 0 meters';
    }
    if (radius > 100000) {
      throw 'Invalid radius: Maximum allowed radius is 100,000 meters (100km)';
    }
    
    // Additional business logic validation
    if (radius < 10) {
      throw 'Warning: Radius of ${radius.toStringAsFixed(0)}m is very small. Students may have difficulty checking in. Consider using at least 50m.';
    }
  }

  String _transformError(dynamic error) {
    final errorStr = error.toString();
    
    // Handle Firebase-specific errors
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied: You do not have permission to modify institute settings. Please contact your administrator.';
        case 'unavailable':
          return 'Service temporarily unavailable: Firebase servers are currently unavailable. Please try again in a few minutes.';
        case 'network-request-failed':
          return 'Network error: Unable to connect to the server. Please check your internet connection and try again.';
        case 'deadline-exceeded':
          return 'Request timeout: The operation took too long to complete. Please try again.';
        case 'resource-exhausted':
          return 'Service overloaded: The server is currently overloaded. Please try again later.';
        case 'internal':
          return 'Internal server error: An unexpected error occurred on the server. Please try again later.';
        case 'invalid-argument':
          return 'Invalid data: The provided data is not valid. Please check your input and try again.';
        default:
          return 'Firebase error: ${error.message ?? error.code}. Please try again.';
      }
    }
    
    // Handle validation errors (pass through as-is)
    if (errorStr.contains('Invalid') || errorStr.contains('Warning')) {
      return errorStr;
    }
    
    // Handle timeout errors
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Operation timed out: Please check your internet connection and try again.';
    }
    
    // Handle network errors
    if (errorStr.toLowerCase().contains('network') || 
        errorStr.toLowerCase().contains('connection') ||
        errorStr.toLowerCase().contains('internet')) {
      return 'Network error: Please check your internet connection and try again.';
    }
    
    // Handle generic errors
    return 'Failed to save settings: ${errorStr}. Please try again.';
  }
}

final instituteNotifierProvider = StateNotifierProvider<InstituteNotifier, AsyncValue<void>>((ref) {
  return InstituteNotifier(ref);
});
