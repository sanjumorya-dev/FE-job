import 'package:flutter/material.dart';

/// WorkConnect Color Palette - Based on Figma Design System
class AppColors {
  // Primary Colors
  static const Color primary = Color.fromARGB(255, 0, 127, 231); // Primary Blue
  static const Color primaryLight = Color(0xFFBBDEFB); // Light Blue
  static const Color primaryDark = Color(0xFF1976D2); // Dark Blue

  // Success & Status Colors
  static const Color success = Color(0xFF4CAF50); // Success Green
  static const Color successLight = Color(0xFFC8E6C9); // Light Green
  static const Color successDark = Color(0xFF388E3C); // Dark Green

  // Warning & Alert Colors
  static const Color warning =
      Color(0xFF2196F3); // Warning Orange (using primary for consistency)
  static const Color warningOrange = Color(0xFFFF7800); // Pure Warning Orange
  static const Color warningLight = Color(0xFFFFE0B2); // Light Orange

  // Error & Destructive Colors
  static const Color error = Color(0xFFF74536); // Error Red
  static const Color errorLight = Color(0xFFFFCDD2); // Light Red
  static const Color errorDark = Color(0xFFC62828); // Dark Red

  // Text Colors
  static const Color textMain = Color(0xFF333333); // Main Text
  static const Color textSecondary = Color(0xFF666666); // Secondary Text
  static const Color textHint = Color(0xFF999999); // Hint Text
  static const Color textInverse = Color(0xFFFFFFFF); // White Text

  // Background & Surface Colors
  static const Color background = Color(0xFFF9FAFC); // App Background
  static const Color surface = Color(0xFFFFFFFF); // Surface/Card Background
  static const Color surfaceSecondary = Color(0xFFF5F5F5); // Secondary Surface
  static const Color overlay = Color(0xF0000000); // Semi-transparent overlay

  // Border & Divider Colors
  static const Color border = Color(0xFFC0C0C0); // Border Color
  static const Color borderLight = Color(0xFFE0E0E0); // Light Border
  static const Color divider = Color(0xFFE0E0E0); // Divider Color

  // Semantic Colors
  static const Color active = Color(0xFF2196F3); // Active state
  static const Color inactive = Color(0xFFBDBDBD); // Inactive state
  static const Color pending = Color(0xFFFF7800); // Pending state
  static const Color disabled = Color(0xFFCCCCCC); // Disabled state

  // Gradient & Special
  static const Color shadowColor = Color(0x1F000000); // Shadow color
}
