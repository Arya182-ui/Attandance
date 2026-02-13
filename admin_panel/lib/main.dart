import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'presentation/providers/admin_auth_provider.dart';
import 'presentation/screens/admin_login_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/widgets/admin_logo.dart';
import 'core/error_handler.dart';
import 'core/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  // Set preferred orientations (portrait for mobile, any for web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ProductionConfig.appName,
      debugShowCheckedModeBanner: !ProductionConfig.isProduction,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        // Enhanced theme for production
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: ErrorBoundary(
        context: 'App Root',
        child: const FirebaseInitializer(),
      ),
      // Global error handler for navigation
      builder: (context, widget) {
        return ErrorBoundary(
          context: 'Global App Context',
          child: widget ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class FirebaseInitializer extends StatefulWidget {
  const FirebaseInitializer({super.key});

  @override
  State<FirebaseInitializer> createState() => _FirebaseInitializerState();
}

class _FirebaseInitializerState extends State<FirebaseInitializer> {
  bool _initialized = false;
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Check network connectivity with enhanced error handling
      if (!kIsWeb) {
        try {
          final connectivityResult = await Connectivity().checkConnectivity();
          if (connectivityResult == ConnectivityResult.none) {
            throw Exception('No internet connection detected');
          }
        } catch (connectivityError) {
          AppErrorHandler.logError(connectivityError, context: 'Connectivity Check');
          // Continue without connectivity check if plugin fails
          // This can happen on some Android versions or emulators
        }
      }
      // On web, we assume internet is available (browser requirement)

      // Initialize Firebase with enhanced timeout and error handling
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        Duration(seconds: ProductionConfig.firestoreTimeout), 
        onTimeout: () {
          throw Exception('Firebase initialization timed out after ${ProductionConfig.firestoreTimeout} seconds. Please check your internet connection.');
        }
      );
      
      AppErrorHandler.logError('Firebase initialized successfully', context: 'Firebase Init - Success');
      setState(() {
        _initialized = true;
      });
    } catch (e, stackTrace) {
      setState(() {
        _error = true;
        _errorMessage = AppErrorHandler.getErrorMessage(e);
      });
      AppErrorHandler.logError(e, stackTrace: stackTrace, context: 'Firebase Initialization');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (!_initialized && !_error) {
      return const _LoadingScreen();
    }

    // Show error screen if initialization failed
    if (_error) {
      return _ErrorScreen(
        errorMessage: _errorMessage,
        onRetry: () {
          setState(() {
            _error = false;
            _errorMessage = '';
          });
          _initializeFirebase();
        },
      );
    }

    // Firebase initialized successfully
    return const AuthWrapper();
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade800,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AdminLogo(width: 120, height: 120),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Initializing ${ProductionConfig.appName}...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connecting to secure cloud services',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version ${ProductionConfig.appVersion}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getErrorIcon(),
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                _getErrorTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ..._getTroubleshootingSteps(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _showErrorDetails(context);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Technical Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    if (errorMessage.contains('internet') || errorMessage.contains('network')) {
      return Icons.wifi_off;
    } else if (errorMessage.contains('timeout')) {
      return Icons.access_time;
    } else {
      return Icons.error_outline;
    }
  }

  String _getErrorTitle() {
    if (errorMessage.contains('internet') || errorMessage.contains('network')) {
      return 'No Internet';
    } else if (errorMessage.contains('timeout')) {
      return 'Connection Timeout';
    } else {
      return 'Connection Failed';
    }
  }

  List<Widget> _getTroubleshootingSteps() {
    List<String> steps = [];
    
    if (errorMessage.contains('internet') || errorMessage.contains('network')) {
      steps = kIsWeb ? [
        '1. Check your internet connection',
        '2. Refresh the browser page (F5 or Ctrl+R)',
        '3. Clear browser cache and cookies', 
        '4. Try using incognito/private mode',
        '5. Disable ad blockers or VPN',
      ] : [
        '1. Check your WiFi or ethernet connection',
        '2. Test internet by opening any website',
        '3. Disable VPN if enabled',
        '4. Check firewall settings',
      ];
    } else if (errorMessage.contains('timeout')) {
      steps = kIsWeb ? [
        '1. Check internet speed',
        '2. Close other browser tabs',
        '3. Refresh the page',
        '4. Try using a different browser',
      ] : [
        '1. Check internet speed',
        '2. Close other bandwidth-heavy applications',
        '3. Try using mobile hotspot',
        '4. Wait and try again',
      ];
    } else {
      steps = kIsWeb ? [
        '1. Refresh the browser page',
        '2. Check internet connection',
        '3. Clear browser cache',
        '4. Try using a different browser',
        '5. Contact administrator if issue persists',
      ] : [
        '1. Check internet connection',
        '2. Refresh the page',
        '3. Clear browser cache',
        '4. Contact administrator if issue persists',
      ];
    }

    return steps.map((step) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          step,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    )).toList();
  }

  void _showErrorDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Text(
            errorMessage,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the StreamProvider that listens to Firebase auth state changes
    final authState = ref.watch(adminAuthStateProvider);
    
    return authState.when(
      data: (admin) {
        if (admin != null) {
          return const DashboardScreen();
        } else {
          return const AdminLoginScreen();
        }
      },
      loading: () => const _LoadingScreen(),
      error: (error, stack) => _ErrorScreen(
        errorMessage: error.toString(),
        onRetry: () => ref.refresh(adminAuthStateProvider),
      ),
    );
  }
}
