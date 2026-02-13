import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;
import '../providers/admin_attendance_provider.dart';
import '../providers/student_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final filters = AttendanceFilters(
      startDate: _startDate,
      endDate: _endDate,
      studentId: _selectedStudentId,
    );
    final attendanceAsync = ref.watch(filteredAttendanceProvider(filters));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Records',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: attendanceAsync.hasValue && attendanceAsync.value!.isNotEmpty
                      ? () => _exportToCSV(attendanceAsync.value!)
                      : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: 200,
                          child: _DatePickerField(
                            label: 'Start Date',
                            date: _startDate,
                            onDateSelected: (date) {
                              setState(() => _startDate = date);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: _DatePickerField(
                            label: 'End Date',
                            date: _endDate,
                            onDateSelected: (date) {
                              setState(() => _endDate = date);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: studentsAsync.when(
                            data: (students) => DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Student',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedStudentId,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Students'),
                                ),
                                ...students.map((student) => DropdownMenuItem(
                                  value: student.id,
                                  child: Text(student.name),
                                )),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedStudentId = value);
                              },
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const Text('Error loading students'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _selectedStudentId = null;
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: attendanceAsync.when(
                data: (attendanceList) {
                  if (attendanceList.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No attendance records found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Student ID')),
                          DataColumn(label: Text('Check In')),
                          DataColumn(label: Text('Check Out')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: attendanceList.map((attendance) {
                          return DataRow(
                            cells: [
                              DataCell(Text(DateFormat('MMM dd, yyyy').format(attendance.date))),
                              DataCell(Text(attendance.studentId)),
                              DataCell(Text(
                                attendance.checkInTime != null
                                    ? DateFormat('hh:mm a').format(attendance.checkInTime!)
                                    : '-',
                              )),
                              DataCell(Text(
                                attendance.checkOutTime != null
                                    ? DateFormat('hh:mm a').format(attendance.checkOutTime!)
                                    : '-',
                              )),
                              DataCell(_StatusChip(status: attendance.status)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToCSV(List attendanceList) {
    List<List<dynamic>> rows = [
      ['Date', 'Student ID', 'Check In', 'Check Out', 'Status'],
    ];

    for (var attendance in attendanceList) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(attendance.date),
        attendance.studentId,
        attendance.checkInTime != null
            ? DateFormat('HH:mm:ss').format(attendance.checkInTime!)
            : '',
        attendance.checkOutTime != null
            ? DateFormat('HH:mm:ss').format(attendance.checkOutTime!)
            : '',
        attendance.status,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final bytes = csv.codeUnits;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'attendance_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.csv';
    html.document.body?.children.add(anchor);

    anchor.click();

    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV exported successfully')),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime?) onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        onDateSelected(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onDateSelected(null),
                )
              : const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null ? DateFormat('MMM dd, yyyy').format(date!) : 'Select date',
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
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
