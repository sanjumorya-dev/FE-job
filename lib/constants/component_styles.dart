import 'package:flutter/material.dart';
import 'colors.dart';

/// WorkConnect Component Styles - Reusable widget styles
class AppComponentStyles {
  // Card Style
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surfaceSecondary,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderLight),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardDecorationNoShadow = BoxDecoration(
    color: AppColors.surfaceSecondary,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderLight),
  );

  // Button Styles
  static BoxDecoration primaryButtonStyle = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(24),
  );

  static BoxDecoration outlineButtonStyle = BoxDecoration(
    border: Border.all(color: AppColors.primary, width: 1.5),
    borderRadius: BorderRadius.circular(24),
    color: Colors.transparent,
  );

  static BoxDecoration successButtonStyle = BoxDecoration(
    color: AppColors.success,
    borderRadius: BorderRadius.circular(24),
  );

  static BoxDecoration errorButtonStyle = BoxDecoration(
    color: AppColors.error,
    borderRadius: BorderRadius.circular(24),
  );

  // Input Field Style
  static BoxDecoration inputFieldStyle = BoxDecoration(
    color: AppColors.surfaceSecondary,
    border: Border.all(color: AppColors.borderLight),
    borderRadius: BorderRadius.circular(24),
  );

  static BoxDecoration inputFieldFocusedStyle = BoxDecoration(
    color: AppColors.surfaceSecondary,
    border: Border.all(color: AppColors.primary, width: 1.5),
    borderRadius: BorderRadius.circular(24),
  );

  // Badge Styles
  static BoxDecoration badgeSuccessStyle = BoxDecoration(
    color: AppColors.successLight,
    borderRadius: BorderRadius.circular(4),
  );

  static BoxDecoration badgeWarningStyle = BoxDecoration(
    color: AppColors.warningLight,
    borderRadius: BorderRadius.circular(4),
  );

  static BoxDecoration badgeErrorStyle = BoxDecoration(
    color: AppColors.errorLight,
    borderRadius: BorderRadius.circular(4),
  );

  static BoxDecoration badgePrimaryStyle = BoxDecoration(
    color: AppColors.primaryLight,
    borderRadius: BorderRadius.circular(4),
  );

  // Chip Style
  static BoxDecoration chipStyle = BoxDecoration(
    color: AppColors.background,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration chipSelectedStyle = BoxDecoration(
    color: AppColors.primaryLight,
    border: Border.all(color: AppColors.primary),
    borderRadius: BorderRadius.circular(20),
  );

  // Tab Bar Style
  static BoxDecoration tabBarStyle = const BoxDecoration(
    border: Border(
      bottom: BorderSide(color: AppColors.divider),
    ),
  );

  // Floating Action Button Style
  static BoxDecoration fabStyle = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
