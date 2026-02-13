import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Global error handler for the admin panel application
/// Provides consistent error handling, logging, and user-friendly messages
class AppErrorHandler {
  
  /// Handle and transform errors into user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    final errorStr = error.toString().toLowerCase();
    
    // Firebase Auth Errors
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    }
    
    // Firestore Errors
    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }
    
    // Network Errors
    if (errorStr.contains('network') || 
        errorStr.contains('connection') ||
        errorStr.contains('internet') ||
        errorStr.contains('socket')) {
      return 'Network error: Please check your internet connection and try again.';
    }
    
    // Timeout Errors
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Operation timed out. Please check your connection and try again.';
    }
    
    // Permission Errors
    if (errorStr.contains('permission')) {
      return 'Permission error: You may not have the required permissions for this action.';
    }
    
    // Format Errors
    if (errorStr.contains('format') || errorStr.contains('parse')) {
      return 'Data format error: The data provided is not in the correct format.';
    }
    
    // Generic error with sanitization
    return 'Error: ${_sanitizeErrorMessage(error.toString())}';
  }
  
  /// Handle Firebase Auth specific errors
  static String _handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with these credentials. Please check your email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format. Please enter a valid email.';
      case 'user-disabled':
        return 'This admin account has been disabled. Please contact your administrator.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes and try again.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact your administrator.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'requires-recent-login':
        return 'Please log out and log in again to perform this action.';
      case 'network-request-failed':
        return 'Network error: Please check your internet connection.';
      default:
        return 'Authentication error: ${error.message ?? 'Unknown authentication error'}';
    }
  }
  
  /// Handle Firebase/Firestore specific errors
  static String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Access denied: You do not have permission to perform this action.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'Network error: Please check your internet connection and try again.';
      case 'deadline-exceeded':
        return 'Request timeout: The operation took too long. Please try again.';
      case 'resource-exhausted':
        return 'Service is currently overloaded. Please try again later.';
      case 'internal':
        return 'Internal server error: An unexpected error occurred. Please try again.';
      case 'invalid-argument':
        return 'Invalid data provided. Please check your input and try again.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This data already exists in the system.';
      case 'failed-precondition':
        return 'Operation failed: The system is not in a valid state for this operation.';
      case 'out-of-range':
        return 'The provided data is out of the acceptable range.';
      case 'unimplemented':
        return 'This feature is not yet available.';
      case 'data-loss':
        return 'Data corruption detected. Please contact support immediately.';
      case 'unauthenticated':
        return 'Authentication required: Please log in and try again.';
      default:
        return 'Firebase error: ${error.message ?? error.code}';
    }
  }
  
  /// Sanitize error messages to remove sensitive information
  static String _sanitizeErrorMessage(String message) {
    // Remove file paths
    message = message.replaceAll(RegExp(r'[A-Za-z]:\\[^\\s]*'), '[file path]');
    message = message.replaceAll(RegExp(r'/[^\\s]*\\.(dart|js|html)'), '[file]');
    
    // Remove stack traces
    message = message.split('\\n').first;
    
    // Remove sensitive keywords
    const sensitiveKeywords = ['token', 'key', 'secret', 'password', 'auth'];
    for (String keyword in sensitiveKeywords) {
      message = message.replaceAll(RegExp('$keyword[^\\s]*', caseSensitive: false), '[$keyword]');
    }
    
    return message.length > 200 ? '${message.substring(0, 200)}...' : message;
  }
  
  /// Log errors for debugging (only in debug mode)
  static void logError(dynamic error, {StackTrace? stackTrace, String? context}) {
    if (kDebugMode) {
      print('=== ERROR LOG ===');
      if (context != null) {
        print('Context: $context');
      }
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
      print('=================');
    }
  }
  
  /// Show error dialog with user-friendly message
  static Future<void> showErrorDialog({
    required BuildContext context,
    required dynamic error,
    String? title,
    String? errorContext,
    VoidCallback? onRetry,
  }) async {
    final errorMessage = getErrorMessage(error);
    logError(error, context: errorContext);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(title ?? 'Error')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            if (errorContext != null) ...[
              const SizedBox(height: 12),
              Text(
                'Context: $errorContext',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onRetry();
              },
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }
  
  /// Show error snackbar with user-friendly message
  static void showErrorSnackbar({
    required BuildContext context,
    required dynamic error,
    String? errorContext,
    Duration? duration,
  }) {
    final errorMessage = getErrorMessage(error);
    logError(error, context: errorContext);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: duration ?? const Duration(seconds: 4),
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
  
  /// Handle errors with graceful recovery
  static Future<T?> handleAsync<T>({
    required Future<T> function,
    BuildContext? context,
    String? errorContext,
    T? fallback,
    bool showDialog = false,
    bool showSnackbar = true,
  }) async {
    try {
      return await function;
    } catch (error, stackTrace) {
      logError(error, stackTrace: stackTrace, context: errorContext);
      
      if (context != null && context.mounted) {
        if (showDialog) {
          await showErrorDialog(
            context: context,
            error: error,
            errorContext: errorContext,
          );
        } else if (showSnackbar) {
          showErrorSnackbar(
            context: context,
            error: error,
            errorContext: errorContext,
          );
        }
      }
      
      return fallback;
    }
  }
  
  /// Wrap widget with error boundary
  static Widget withErrorBoundary({
    required Widget child,
    String? errorContext,
    Widget? fallback,
  }) {
    return Builder(
      builder: (context) {
        return child;
      },
    );
  }
}

/// Error boundary widget that catches widget build errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(dynamic error)? errorBuilder;
  final String? context;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.context,
  });
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  dynamic error;
  
  @override
  Widget build(BuildContext context) {
    if (error != null) {
      AppErrorHandler.logError(error, context: widget.context);
      
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(error);
      }
      
      return Material(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.red.shade50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppErrorHandler.getErrorMessage(error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => error = null),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    
    return widget.child;
  }
}