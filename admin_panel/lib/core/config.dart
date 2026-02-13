import 'package:flutter/foundation.dart';

/// Production configuration settings for the admin panel
class ProductionConfig {
  // App Information
  static const String appName = 'Attendance Admin Panel';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // Environment Settings
  static const bool isProduction = kReleaseMode;
  static const bool enableDebugLogs = !kReleaseMode;
  static const bool enableErrorReporting = kReleaseMode;
  
  // Firebase Settings
  static const int firestoreTimeout = 30; // seconds
  static const int authTimeout = 15; // seconds
  static const bool enableFirestoreOffline = true;
  
  // Location Settings
  static const int locationTimeout = 20; // seconds
  static const double defaultRadius = 100.0; // meters
  static const double minRadius = 10.0; // meters
  static const double maxRadius = 10000.0; // meters
  
  // UI Settings
  static const int snackbarDuration = 4; // seconds
  static const int loadingTimeout = 30; // seconds
  static const bool enableHapticFeedback = true;
  
  // Security Settings
  static const int maxLoginAttempts = 5;
  static const int sessionTimeout = 8 * 60; // 8 hours in minutes
  static const bool requireStrongPasswords = true;
  
  // Performance Settings
  static const int maxCacheSize = 50; // MB
  static const bool enableImageCompression = true;
  static const double imageQuality = 0.8;
  
  // Validation Rules
  static const Map<String, dynamic> validationRules = {
    'email': {
      'required': true,
      'pattern': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
    },
    'password': {
      'required': true,
      'minLength': 8,
      'requireUppercase': true,
      'requireLowercase': true,
      'requireNumbers': true,
      'requireSpecialChars': false,
    },
    'name': {
      'required': true,
      'minLength': 2,
      'maxLength': 50,
      'pattern': r'^[a-zA-Z\\s]+$',
    },
    'latitude': {
      'required': true,
      'min': -90.0,
      'max': 90.0,
    },
    'longitude': {
      'required': true,
      'min': -180.0,
      'max': 180.0,
    },
    'radius': {
      'required': true,
      'min': minRadius,
      'max': maxRadius,
    },
  };
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Network connection failed. Please check your internet connection.',
    'auth_failed': 'Authentication failed. Please check your credentials.',
    'permission_denied': 'You do not have permission to perform this action.',
    'validation_failed': 'Please correct the errors and try again.',
    'location_disabled': 'Location services are disabled. Please enable GPS.',
    'location_permission': 'Location permission is required for this feature.',
    'save_failed': 'Failed to save changes. Please try again.',
    'load_failed': 'Failed to load data. Please refresh and try again.',
    'timeout': 'Operation timed out. Please try again.',
    'server_error': 'Server error occurred. Please try again later.',
  };
  
  // Success Messages
  static const Map<String, String> successMessages = {
    'settings_saved': 'Institute settings saved successfully!',
    'student_added': 'Student added successfully!',
    'student_updated': 'Student information updated successfully!',
    'student_deleted': 'Student removed successfully!',
    'login_success': 'Successfully logged in!',
    'logout_success': 'Successfully logged out!',
    'location_updated': 'Location updated successfully!',
  };
  
  // Feature Flags
  static const Map<String, bool> features = {
    'enable_csv_export': true,
    'enable_bulk_operations': true,
    'enable_student_photos': true,
    'enable_attendance_analytics': true,
    'enable_email_notifications': false, // Not implemented yet
    'enable_push_notifications': false, // Not implemented yet
    'enable_backup_restore': false, // Not implemented yet
    'enable_audit_logs': false, // Not implemented yet
  };
  
  // Platform-specific Settings
  static const Map<String, dynamic> platformSettings = {
    'web': {
      'enable_pwa': true,
      'enable_offline_mode': false,
      'max_file_size': 5 * 1024 * 1024, // 5MB
    },
    'android': {
      'enable_background_sync': false,
      'require_biometric_auth': false,
      'enable_auto_backup': true,
    },
    'ios': {
      'enable_background_sync': false,
      'require_biometric_auth': false,
      'enable_auto_backup': true,
    },
  };
  
  // API Configuration
  static const Map<String, dynamic> apiConfig = {
    'timeout': 30000, // milliseconds
    'max_retries': 3,
    'retry_delay': 1000, // milliseconds
    'enable_compression': true,
    'max_concurrent_requests': 5,
  };
  
  // Logging Configuration
  static const Map<String, dynamic> loggingConfig = {
    'enable_console_logs': enableDebugLogs,
    'enable_file_logs': isProduction,
    'max_log_file_size': 10 * 1024 * 1024, // 10MB
    'log_retention_days': 7,
    'log_levels': [
      if (!isProduction) 'DEBUG',
      'INFO',
      'WARNING',
      'ERROR',
      'CRITICAL',
    ],
  };
  
  /// Get validation rule for a specific field
  static Map<String, dynamic>? getValidationRule(String field) {
    return validationRules[field] as Map<String, dynamic>?;
  }
  
  /// Get error message by key
  static String getErrorMessage(String key) {
    return errorMessages[key] ?? 'An error occurred. Please try again.';
  }
  
  /// Get success message by key
  static String getSuccessMessage(String key) {
    return successMessages[key] ?? 'Operation completed successfully!';
  }
  
  /// Check if a feature is enabled
  static bool isFeatureEnabled(String feature) {
    return features[feature] ?? false;
  }
  
  /// Get platform-specific setting
  static dynamic getPlatformSetting(String platform, String setting) {
    final platformConfig = platformSettings[platform] as Map<String, dynamic>?;
    return platformConfig?[setting];
  }
  
  /// Environment-specific configurations
  static Map<String, dynamic> get currentEnvironment {
    return {
      'name': isProduction ? 'production' : 'development',
      'debug_mode': enableDebugLogs,
      'error_reporting': enableErrorReporting,
      'api_timeout': apiConfig['timeout'],
      'max_retries': apiConfig['max_retries'],
    };
  }
}