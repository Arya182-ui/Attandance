import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  final String studentId;

  const AttendanceHistoryScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(attendanceHistoryProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: historyAsync.when(
        data: (attendanceList) {
          if (attendanceList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No attendance history',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final attendance = attendanceList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM dd, yyyy').format(attendance.date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _StatusChip(status: attendance.status),
                        ],
                      ),
                      const Divider(height: 20),
                      if (attendance.checkInTime != null)
                        _TimeRow(
                          icon: Icons.login,
                          label: 'Check In',
                          time: attendance.checkInTime!,
                          color: Colors.green,
                        ),
                      if (attendance.checkInTime != null && attendance.checkOutTime != null)
                        const SizedBox(height: 8),
                      if (attendance.checkOutTime != null)
                        _TimeRow(
                          icon: Icons.logout,
                          label: 'Check Out',
                          time: attendance.checkOutTime!,
                          color: Colors.orange,
                        ),
                      if (attendance.checkInTime != null && attendance.checkOutTime != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Duration: ${_calculateDuration(attendance.checkInTime!, attendance.checkOutTime!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDuration(DateTime checkIn, DateTime checkOut) {
    final duration = checkOut.difference(checkIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'checked_in':
        color = Colors.blue;
        label = 'Checked In';
        break;
      case 'checked_out':
        color = Colors.green;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = 'Absent';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime time;
  final Color color;

  const _TimeRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          DateFormat('hh:mm a').format(time),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
