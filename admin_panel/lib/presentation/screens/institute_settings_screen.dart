import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/institute_provider.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_overlay.dart';

class InstituteSettingsScreen extends ConsumerStatefulWidget {
  const InstituteSettingsScreen({super.key});

  @override
  ConsumerState<InstituteSettingsScreen> createState() => _InstituteSettingsScreenState();
}

class _InstituteSettingsScreenState extends ConsumerState<InstituteSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      if (kIsWeb) {
        // For web platforms, try HTML5 geolocation with fallback
        await _handleWebLocationRequest();
        return;
      }
      
      // For mobile platforms - comprehensive permission and service checking
      final locationResult = await _handleMobileLocationRequest();
      
      if (locationResult != null) {
        // Update the text fields with high precision
        _latitudeController.text = locationResult.latitude.toStringAsFixed(6);
        _longitudeController.text = locationResult.longitude.toStringAsFixed(6);
        
        if (mounted) {
          _showSuccessMessage(
            'Location updated successfully!\n'
            'Latitude: ${locationResult.latitude.toStringAsFixed(4)}\n'
            'Longitude: ${locationResult.longitude.toStringAsFixed(4)}\n'
            'Accuracy: ±${locationResult.accuracy.toStringAsFixed(0)}m'
          );
        }
      }
      
    } catch (e) {
      await _handleLocationError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _handleWebLocationRequest() async {
    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Web Location Access'),
          content: const Text(
            'For web browsers, please:\n\n'
            '1. Allow location access when prompted\n'
            '2. Or manually enter coordinates from Google Maps:\n'
            '   • Right-click on location\n'
            '   • Select "Copy coordinates"\n'
            '   • Paste in the latitude/longitude fields'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    }
  }

  Future<Position?> _handleMobileLocationRequest() async {
    // Check location service first
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationServiceDialog();
      return null;
    }

    // Enhanced permission handling with detailed checks
    final permissionResult = await _checkAndRequestLocationPermissions();
    if (!permissionResult) {
      return null;
    }

    // Get location with enhanced error handling
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      
      // Validate accuracy
      if (position.accuracy > 100) {
        if (mounted) {
          final retry = await _showAccuracyWarningDialog(position.accuracy);
          if (retry) {
            // Try again with best accuracy
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
              timeLimit: const Duration(seconds: 30),
            );
          }
        }
      }
      
      return position;
      
    } on LocationServiceDisabledException {
      throw 'Location services are disabled. Please enable GPS/Location services in device settings.';
    } on PermissionDeniedException {
      throw 'Location permissions denied. Please grant location access in app settings.';
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw 'Location permission not granted. Please allow location access when prompted.';
      } else if (e.toString().contains('POSITION_UNAVAILABLE')) {
        throw 'Unable to determine location. Please ensure GPS is enabled and try again.';
      } else {
        throw 'Failed to get location: ${e.toString()}';
      }
    }
  }

  Future<bool> _checkAndRequestLocationPermissions() async {
    try {
      // First check with permission_handler for more detailed control
      var status = await Permission.location.status;
      
      if (status.isDenied) {
        // Show explanation dialog before requesting
        final shouldRequest = await _showPermissionExplanationDialog();
        if (!shouldRequest) return false;
        
        status = await Permission.location.request();
      }
      
      if (status.isDenied) {
        await _showPermissionDeniedDialog();
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        await _showPermanentlyDeniedDialog();
        return false;
      }
      
      // Double-check with Geolocator for compatibility
      LocationPermission geoPermission = await Geolocator.checkPermission();
      if (geoPermission == LocationPermission.denied) {
        geoPermission = await Geolocator.requestPermission();
        if (geoPermission == LocationPermission.denied) {
          return false;
        }
      }
      
      if (geoPermission == LocationPermission.deniedForever) {
        await _showPermanentlyDeniedDialog();
        return false;
      }
      
      return true;
      
    } catch (e) {
      await _handleLocationError('Permission check failed: $e');
      return false;
    }
  }

  // Helper methods for better error handling and user experience

  Future<bool> _showPermissionExplanationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Text('Location Permission'),
          ],
        ),
        content: const Text(
          'This app needs location access to automatically detect the institute\'s coordinates. '
          'This makes setting up geo-fencing much easier and more accurate.\n\n'
          'Your location data is used only for this configuration and is not shared with anyone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showPermissionDeniedDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permission Required'),
          ],
        ),
        content: const Text(
          'Location permission is required to automatically detect coordinates. '
          'You can still manually enter the coordinates using Google Maps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermanentlyDeniedDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.red),
            SizedBox(width: 8),
            Text('Permission Permanently Denied'),
          ],
        ),
        content: const Text(
          'Location permission has been permanently denied. '
          'To use automatic location detection, please:\n\n'
          '1. Go to device Settings\n'
          '2. Find this app\n'
          '3. Enable Location permission\n\n'
          'Or you can manually enter coordinates using Google Maps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Manual Entry'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLocationServiceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gps_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Location Services Disabled'),
          ],
        ),
        content: const Text(
          'Location services are disabled on your device. '
          'To use automatic location detection, please:\n\n'
          '1. Go to device Settings\n'
          '2. Enable Location/GPS services\n'
          '3. Try again\n\n'
          'Or you can manually enter coordinates using Google Maps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Manual Entry'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Open GPS Settings'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showAccuracyWarningDialog(double accuracy) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Low Accuracy'),
          ],
        ),
        content: Text(
          'Current location accuracy is ±${accuracy.toStringAsFixed(0)}m, which is quite low. '
          'For better accuracy:\n\n'
          '• Move outdoors or near a window\n'
          '• Make sure GPS is enabled\n'
          '• Wait for better satellite signal\n\n'
          'Would you like to try again for better accuracy?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Use Current'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Try Again'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _handleLocationError(dynamic error) async {
    String errorMessage;
    String detailedMessage;
    Color backgroundColor = Colors.red;
    
    if (error.toString().contains('Permission')) {
      errorMessage = 'Permission Error';
      detailedMessage = 'Location permission is required. Please grant permission in settings.';
      backgroundColor = Colors.orange;
    } else if (error.toString().contains('service')) {
      errorMessage = 'Location Service Error';
      detailedMessage = 'GPS/Location services are disabled. Please enable them in device settings.';
    } else if (error.toString().contains('timeout') || error.toString().contains('Timeout')) {
      errorMessage = 'Timeout Error';
      detailedMessage = 'Location request timed out. Please ensure you have good GPS signal and try again.';
    } else if (error.toString().contains('POSITION_UNAVAILABLE')) {
      errorMessage = 'Position Unavailable';
      detailedMessage = 'Unable to determine location. Please check your GPS signal and try again.';
    } else {
      errorMessage = 'Location Error';
      detailedMessage = 'Failed to get location: ${error.toString()}';
    }

    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: backgroundColor),
              const SizedBox(width: 8),
              Text(errorMessage),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detailedMessage),
              const SizedBox(height: 16),
              const Text(
                'Alternative: Use Google Maps to find coordinates:\n'
                '1. Open Google Maps\n'
                '2. Right-click on your institute location\n'
                '3. Select "Copy coordinates"\n'
                '4. Paste in the latitude/longitude fields',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(instituteSettingsProvider);

    return Scaffold(
      body: settingsAsync.when(
        data: (settings) {
          // Populate controllers if they're empty
          if (_latitudeController.text.isEmpty) {
            _latitudeController.text = settings.latitude.toString();
            _longitudeController.text = settings.longitude.toString();
            _radiusController.text = settings.radius.toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Institute Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Geo-Fencing Configuration',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Set the institute location and allowed radius for attendance.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _latitudeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Latitude',
                                    border: OutlineInputBorder(),
                                    helperText: 'e.g., 40.7128',
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Required';
                                    final number = double.tryParse(value!);
                                    if (number == null) return 'Invalid number';
                                    if (number < -90 || number > 90) return 'Must be between -90 and 90';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _longitudeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Longitude',
                                    border: OutlineInputBorder(),
                                    helperText: 'e.g., -74.0060',
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Required';
                                    final number = double.tryParse(value!);
                                    if (number == null) return 'Invalid number';
                                    if (number < -180 || number > 180) return 'Must be between -180 and 180';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                              icon: _isLoadingLocation 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.my_location),
                              label: Text(_isLoadingLocation ? 'Getting Location...' : 'Use Current Location'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _radiusController,
                            decoration: const InputDecoration(
                              labelText: 'Allowed Radius (meters)',
                              border: OutlineInputBorder(),
                              helperText: 'e.g., 100',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Required';
                              final number = double.tryParse(value!);
                              if (number == null) return 'Invalid number';
                              if (number <= 0) return 'Must be greater than 0';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          LoadingButton(
                            isLoading: _isSaving,
                            onPressed: _saveSettings,
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text(
                                'Save Settings',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Settings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _SettingRow(
                          label: 'Latitude',
                          value: settings.latitude.toStringAsFixed(6),
                          icon: Icons.place,
                        ),
                        const SizedBox(height: 12),
                        _SettingRow(
                          label: 'Longitude',
                          value: settings.longitude.toStringAsFixed(6),
                          icon: Icons.place,
                        ),
                        const SizedBox(height: 12),
                        _SettingRow(
                          label: 'Radius',
                          value: '${settings.radius.toStringAsFixed(0)} meters',
                          icon: Icons.radar,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  bool _isSaving = false;

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationError();
      return;
    }

    if (_isSaving) return; // Prevent multiple simultaneous saves

    setState(() => _isSaving = true);

    try {
      // Parse and validate values
      final latitude = double.parse(_latitudeController.text.trim());
      final longitude = double.parse(_longitudeController.text.trim());
      final radius = double.parse(_radiusController.text.trim());

      // Additional validation
      if (latitude < -90 || latitude > 90) {
        throw 'Latitude must be between -90 and 90 degrees';
      }
      if (longitude < -180 || longitude > 180) {
        throw 'Longitude must be between -180 and 180 degrees';
      }
      if (radius <= 0) {
        throw 'Radius must be greater than 0 meters';
      }
      if (radius > 10000) {
        final confirmed = await _confirmLargeRadius(radius);
        if (!confirmed) return;
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Saving settings...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Save settings with timeout
      await ref.read(instituteNotifierProvider.notifier).updateSettings(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw 'Save operation timed out. Please check your connection and try again.',
      );

      if (mounted) {
        // Hide loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Show success message with details
        _showSuccessMessage(
          'Settings saved successfully!\\n'
          'Institute location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}\\n'
          'Allowed radius: ${radius.toStringAsFixed(0)} meters'
        );
        
        // Optional: Show success dialog for important updates
        if (radius > 1000) {
          await _showLargeRadiusConfirmation(radius);
        }
      }
    } catch (e) {
      if (mounted) {
        // Hide loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Show detailed error
        await _handleSaveError(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please correct the errors in the form before saving'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _confirmLargeRadius(double radius) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Large Radius Warning'),
          ],
        ),
        content: Text(
          'You have set a very large radius of ${radius.toStringAsFixed(0)} meters (${(radius / 1000).toStringAsFixed(1)} km).\\n\\n'
          'This means students can check in from a very wide area. '
          'For most institutes, a radius of 50-200 meters is recommended.\\n\\n'
          'Are you sure you want to use this large radius?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Use Large Radius'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showLargeRadiusConfirmation(double radius) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Settings Saved'),
          ],
        ),
        content: Text(
          'Institute settings have been saved with a radius of ${radius.toStringAsFixed(0)} meters.\\n\\n'
          'Students will be able to check in from anywhere within this radius of the institute location.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveError(dynamic error) async {
    String errorTitle = 'Save Failed';
    String errorMessage = 'Failed to save settings.';
    List<String> troubleshootingSteps = [];

    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('internet')) {
      errorTitle = 'Network Error';
      errorMessage = 'Unable to save settings due to network issues.';
      troubleshootingSteps = [
        'Check your internet connection',
        'Make sure Firebase is accessible',
        'Try saving again in a few moments',
      ];
    } else if (errorStr.contains('timeout')) {
      errorTitle = 'Connection Timeout';
      errorMessage = 'The save operation took too long to complete.';
      troubleshootingSteps = [
        'Check your internet speed',
        'Ensure stable connection',
        'Try again with a faster connection',
      ];
    } else if (errorStr.contains('permission') || errorStr.contains('unauthorized')) {
      errorTitle = 'Permission Error';
      errorMessage = 'You do not have permission to modify institute settings.';
      troubleshootingSteps = [
        'Make sure you are logged in as admin',
        'Try logging out and logging back in',
        'Contact your system administrator',
      ];
    } else if (errorStr.contains('validation') || errorStr.contains('invalid')) {
      errorTitle = 'Invalid Data';
      errorMessage = 'The entered data is not valid.';
      troubleshootingSteps = [
        'Check latitude is between -90 and 90',
        'Check longitude is between -180 and 180', 
        'Ensure radius is a positive number',
      ];
    } else {
      errorMessage = 'An unexpected error occurred: ${error.toString()}';
      troubleshootingSteps = [
        'Try saving again',
        'Check your internet connection',
        'If problem persists, contact support',
      ];
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(errorTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            if (troubleshootingSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Troubleshooting steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...troubleshootingSteps.map((step) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text('\u2022 $step', style: const TextStyle(fontSize: 13)),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveSettings(); // Retry
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SettingRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }
}
