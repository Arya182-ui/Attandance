import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo widget that can be used throughout the app
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  
  const AppLogo({
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
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.assignment_turned_in,
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
///       AppLogo(width: 32, height: 32),
///       SizedBox(width: 8),
///       Text('Student Attendance'),
///     ],
///   ),
/// )
///
/// // In Login Screen
/// Column(
///   children: [
///     AppLogo(width: 120, height: 120),
///     SizedBox(height: 16),
///     Text('Welcome to Attendance System'),
///   ],
/// )