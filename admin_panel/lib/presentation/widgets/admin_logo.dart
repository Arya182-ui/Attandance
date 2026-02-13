import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Admin Panel Logo widget
class AdminLogo extends StatelessWidget {
  final double? width;
  final double? height;
  
  const AdminLogo({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
      width: width ?? 80,
      height: height ?? 80,
      fit: BoxFit.contain,
      placeholderBuilder: (context) {
        // Fallback if SVG doesn't load
        return Container(
          width: width ?? 80,
          height: height ?? 80,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: (width ?? 80) * 0.6,
          ),
        );
      },
    );
  }
}

/// Usage Examples:
/// 
/// // In AppBar
/// AppBar(
///   title: Row(
///     children: [
///       AdminLogo(width: 32, height: 32),
///       SizedBox(width: 8),
///       Text('Admin Panel'),
///     ],
///   ),
/// )
///
/// // In Dashboard
/// Column(
///   children: [
///     AdminLogo(width: 100, height: 100),
///     SizedBox(height: 16),
///     Text('Attendance Management System'),
///   ],
/// )