import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import 'attendance_history_screen.dart';
import 'profile_edit_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No user found')),
          );
        }

        return _HomeContent(user: user);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  final UserEntity user;

  const _HomeContent({required this.user});

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  Future<void> _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  Future<void> _refreshData() async {
    await _triggerHapticFeedback();
    // Refresh providers
    ref.refresh(todayAttendanceProvider(widget.user.id));
    ref.refresh(authStateProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _triggerHapticFeedback();
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayAttendance = ref.watch(todayAttendanceProvider(widget.user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCareerAdvisor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              await _triggerHapticFeedback();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AttendanceHistoryScreen(studentId: widget.user.id),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _triggerHapticFeedback();
              _showLogoutConfirmation();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF0D9488),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () async {
                  await _triggerHapticFeedback();
                  final result = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProfileEditScreen(user: widget.user),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                  );
                  if (result == true) {
                    // Profile updated, refresh the data
                    _refreshData();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Hero(
                              tag: 'profile_avatar',
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: widget.user.profileImageUrl != null
                                    ? NetworkImage(widget.user.profileImageUrl!)
                                    : null,
                                child: widget.user.profileImageUrl == null
                                    ? Text(
                                        widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.user.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            if (widget.user.enrollmentNumber != null || widget.user.course != null || widget.user.batch != null) ...[
                              const Divider(height: 20),
                              if (widget.user.enrollmentNumber != null)
                                _ProfileInfoRow(
                                  icon: Icons.badge_outlined,
                                  label: 'Enrollment',
                                  value: widget.user.enrollmentNumber!,
                                ),
                              if (widget.user.course != null)
                                _ProfileInfoRow(
                                  icon: Icons.school_outlined,
                                  label: 'Course',
                                  value: widget.user.course!,
                                ),
                              if (widget.user.batch != null)
                                _ProfileInfoRow(
                                  icon: Icons.group_outlined,
                                  label: 'Batch',
                                  value: widget.user.batch!,
                                ),
                            ],
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xFF0D9488),
                              size: 16,
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
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Today\'s Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      todayAttendance.when(
                        data: (attendance) {
                          if (attendance == null) {
                            return const Text(
                              'No check-in yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            );
                          }

                          return Column(
                            children: [
                              if (attendance.checkInTime != null) ...[
                                _StatusRow(
                                  icon: Icons.login,
                                  label: 'Check In',
                                  time: attendance.checkInTime!,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (attendance.checkOutTime != null) ...[
                                _StatusRow(
                                  icon: Icons.logout,
                                  label: 'Check Out',
                                  time: attendance.checkOutTime!,
                                  color: Colors.orange,
                                ),
                              ],
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (error, _) => Text('Error: $error'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              todayAttendance.when(
                data: (attendance) {
                  final hasCheckedIn = attendance?.hasCheckedIn ?? false;
                  final hasCheckedOut = attendance?.hasCheckedOut ?? false;

                  return Column(
                    children: [
                      if (!hasCheckedIn)
                        _CheckInButton(studentId: widget.user.id, onHaptic: _triggerHapticFeedback)
                      else if (!hasCheckedOut)
                        _CheckOutButton(studentId: widget.user.id, onHaptic: _triggerHapticFeedback)
                      else
                        Card(
                          color: Colors.green.shade50,
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Attendance completed for today',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime time;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              DateFormat('hh:mm a').format(time),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CheckInButton extends ConsumerWidget {
  final String studentId;
  final Future<void> Function() onHaptic;

  const _CheckInButton({required this.studentId, required this.onHaptic});

  void _showErrorDialog(BuildContext context, String title, String message, {
    String? actionText,
    VoidCallback? actionCallback,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (actionText != null && actionCallback != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                actionCallback();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceNotifierProvider);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: attendanceState.isLoading
            ? null
            : () async {
                await onHaptic();
                final connectivityResult = await Connectivity().checkConnectivity();
                if (connectivityResult == ConnectivityResult.none) {
                  if (context.mounted) {
                    _showErrorDialog(
                      context,
                      'No Internet Connection',
                      'Please check your network connection and try again.',
                      actionText: 'Open Settings',
                      actionCallback: () {
                        // Could open settings - but requires platform-specific code
                      },
                    );
                  }
                  return;
                }
                try {
                  await ref.read(attendanceNotifierProvider.notifier).checkIn(studentId);
                  await onHaptic();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Check-in successful!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    String errorMessage = e.toString();
                    String? actionText;
                    VoidCallback? actionCallback;
                    
                    // Better error handling
                    if (errorMessage.contains('location') || errorMessage.contains('permission')) {
                      errorMessage = 'Location permission is required to check in. '
                          'Please enable location services in your device settings.';
                      actionText = 'Open Settings';
                      actionCallback = () {
                        // Would open app settings if we had the app_settings package
                      };
                    } else if (errorMessage.contains('radius') || errorMessage.contains('distance')) {
                      errorMessage = 'You are outside the allowed check-in area. '
                          'Please move closer to your institute to check in.';
                    } else if (errorMessage.contains('already checked in')) {
                      errorMessage = 'You have already checked in today. '
                          'You can check out later.';
                    } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
                      errorMessage = 'Network error. Please check your internet connection and try again.';
                      actionText = 'Retry';
                      actionCallback = () {
                        // Retry logic would go here
                      };
                    }
                    
                    _showErrorDialog(
                      context,
                      'Check-in Failed',
                      errorMessage,
                      actionText: actionText,
                      actionCallback: actionCallback,
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: attendanceState.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Check In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CheckOutButton extends ConsumerWidget {
  final String studentId;
  final Future<void> Function() onHaptic;

  const _CheckOutButton({required this.studentId, required this.onHaptic});

  void _showErrorDialog(BuildContext context, String title, String message, {
    String? actionText,
    VoidCallback? actionCallback,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (actionText != null && actionCallback != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                actionCallback();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceNotifierProvider);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: attendanceState.isLoading
            ? null
            : () async {
                await onHaptic();
                final connectivityResult = await Connectivity().checkConnectivity();
                if (connectivityResult == ConnectivityResult.none) {
                  if (context.mounted) {
                    _showErrorDialog(
                      context,
                      'No Internet Connection',
                      'Please check your network connection and try again.',
                      actionText: 'Open Settings',
                      actionCallback: () {
                        // Could open settings
                      },
                    );
                  }
                  return;
                }
                try {
                  await ref.read(attendanceNotifierProvider.notifier).checkOut(studentId);
                  await onHaptic();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Check-out successful!'),
                          ],
                        ),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    String errorMessage = e.toString();
                    String? actionText;
                    VoidCallback? actionCallback;
                    
                    if (errorMessage.contains('network') || errorMessage.contains('connection')) {
                      errorMessage = 'Network error. Please check your internet connection and try again.';
                      actionText = 'Retry';
                    } else if (errorMessage.contains('not checked in')) {
                      errorMessage = 'You need to check in before you can check out.';
                    }
                    
                    _showErrorDialog(
                      context,
                      'Check-out Failed',
                      errorMessage,
                      actionText: actionText,
                      actionCallback: actionCallback,
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: attendanceState.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Check Out',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0D9488)),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
