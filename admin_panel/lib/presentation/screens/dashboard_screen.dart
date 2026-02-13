import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/admin_auth_provider.dart';
import 'students_screen.dart';
import 'institute_settings_screen.dart';
import 'attendance_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(adminAuthStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No user found')),
          );
        }

        return _DashboardContent(user: user);
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

class _DashboardContent extends ConsumerStatefulWidget {
  final UserEntity user;

  const _DashboardContent({required this.user});

  @override
  ConsumerState<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<_DashboardContent> {
  int _selectedIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return _OverviewScreen(onNavigate: _navigateToTab);
      case 1:
        return const StudentsScreen();
      case 2:
        return const AttendanceScreen();
      case 3:
        return const InstituteSettingsScreen();
      default:
        return _OverviewScreen(onNavigate: _navigateToTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(adminAuthNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Students'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Attendance'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Institute Settings'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _getScreen(_selectedIndex),
    );
  }
}

class _OverviewScreen extends ConsumerWidget {
  final Function(int) onNavigate;
  
  const _OverviewScreen({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        MediaQuery.of(context).size.width > 400 ? 'System Active' : 'Active',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your geo-fenced attendance system',
            style: TextStyle(
              color: Colors.grey,
              fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                double childAspectRatio = 1.1;
                
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                  childAspectRatio = 1.3;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 3;
                  childAspectRatio = 1.2;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 2;
                  childAspectRatio = 1.1;
                } else {
                  crossAxisCount = 1;
                  childAspectRatio = 2.5;
                }
                
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
              children: [
                _DashboardCard(
                  title: 'Manage Students',
                  subtitle: 'Add, edit & view students',
                  icon: Icons.people_outline,
                  color: Colors.blue,
                  gradientColors: [Colors.blue.shade300, Colors.blue.shade600],
                  onTap: () => onNavigate(1),
                ),
                _DashboardCard(
                  title: 'View Attendance',
                  subtitle: 'Track & export records',
                  icon: Icons.assignment_turned_in_outlined,
                  color: Colors.green,
                  gradientColors: [Colors.green.shade300, Colors.green.shade600],
                  onTap: () => onNavigate(2),
                ),
                _DashboardCard(
                  title: 'Institute Settings',
                  subtitle: 'Configure location & radius',
                  icon: Icons.location_on_outlined,
                  color: Colors.orange,
                  gradientColors: [Colors.orange.shade300, Colors.orange.shade600],
                  onTap: () => onNavigate(3),
                ),
                _DashboardCard(
                  title: 'Quick Actions',
                  subtitle: 'Export data & reports',
                  icon: Icons.speed,
                  color: Colors.purple,
                  gradientColors: [Colors.purple.shade300, Colors.purple.shade600],
                  onTap: () {
                    // Show quick actions bottom sheet
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _QuickActionsSheet(onNavigate: onNavigate),
                    );
                  },
                ),
              ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Card(
      elevation: isSmallScreen ? 4 : 8,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon, 
                    size: isSmallScreen ? 20 : 28, 
                    color: Colors.white
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 11,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  final Function(int) onNavigate;
  
  const _QuickActionsSheet({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.download, color: Colors.green),
            ),
            title: const Text('Export Attendance'),
            subtitle: const Text('Download attendance records as CSV'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              onNavigate(2);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add, color: Colors.blue),
            ),
            title: const Text('Add New Student'),
            subtitle: const Text('Quickly register a new student'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              onNavigate(1);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings, color: Colors.orange),
            ),
            title: const Text('Update Geo-Fence'),
            subtitle: const Text('Modify institute location settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              onNavigate(3);
            },
          ),
        ],
      ),
    );
  }
}
