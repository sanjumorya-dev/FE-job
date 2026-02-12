import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double height;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 320, // Increased default height for waves
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipPath(
        clipper: _HeaderClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.waveColor1.withValues(alpha: 0.9),
                AppColors.headerBackground,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40); // Start slightly up from bottom-left

    // Smoother curve with gentle slope
    path.quadraticBezierTo(
      size.width * 0.3, // Control point X (closer to left for gentle start)
      size.height + 40, // Control point Y (deeper for rounder curve)
      size.width * 0.7, // Mid point X
      size.height - 20, // Mid point Y
    );

    path.quadraticBezierTo(
      size.width * 0.85, // Control point X (smooth transition to right)
      size.height - 60, // Control point Y (rise up)
      size.width, // End point X
      size.height - 80, // End point Y (higher on right)
    );

    path.lineTo(size.width, 0); // Top-right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
