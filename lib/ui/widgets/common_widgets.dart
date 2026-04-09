import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';

/// Reusable Primary Button Component
class WorkConnectButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final IconData? icon;

  const WorkConnectButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.primary : AppColors.disabled,
          disabledBackgroundColor: AppColors.disabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    enabled ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Reusable Secondary/Outline Button Component
class WorkConnectOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final double? width;
  final IconData? icon;
  final Color? color;

  const WorkConnectOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.width,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: enabled ? buttonColor : AppColors.disabled,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: buttonColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: enabled ? buttonColor : AppColors.disabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Text Input Field Component
class WorkConnectTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;

  const WorkConnectTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
  });

  @override
  State<WorkConnectTextField> createState() => _WorkConnectTextFieldState();
}

class _WorkConnectTextFieldState extends State<WorkConnectTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.body14Bold.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines ?? 1,
          readOnly: widget.readOnly,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixIconPressed ??
                        (widget.obscureText
                            ? () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              }
                            : null),
                    child: Icon(
                      widget.suffixIcon,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable Card Component
class WorkConnectCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool clickable;
  final Color? backgroundColor;
  final bool withShadow;

  const WorkConnectCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.clickable = false,
    this.backgroundColor,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: clickable ? onTap : null,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: withShadow
              ? [
                  const BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// Reusable Status Badge Component
class WorkConnectBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final bool outlined;

  const WorkConnectBadge({
    super.key,
    required this.label,
    this.type = BadgeType.primary,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case BadgeType.success:
        backgroundColor =
            outlined ? Colors.transparent : AppColors.successLight;
        textColor = AppColors.successDark;
        break;
      case BadgeType.warning:
        backgroundColor =
            outlined ? Colors.transparent : AppColors.warningLight;
        textColor = AppColors.warningOrange;
        break;
      case BadgeType.error:
        backgroundColor = outlined ? Colors.transparent : AppColors.errorLight;
        textColor = AppColors.errorDark;
        break;
      case BadgeType.pending:
        backgroundColor =
            outlined ? Colors.transparent : AppColors.warningLight;
        textColor = AppColors.warningOrange;
        break;
      case BadgeType.active:
        backgroundColor =
            outlined ? Colors.transparent : AppColors.primaryLight;
        textColor = AppColors.primaryDark;
        break;
      case BadgeType.primary:
        backgroundColor =
            outlined ? Colors.transparent : AppColors.primaryLight;
        textColor = AppColors.primaryDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: outlined ? Border.all(color: textColor, width: 1) : null,
      ),
      child: Text(
        label,
        style: AppTypography.label12.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum BadgeType {
  primary,
  success,
  warning,
  error,
  pending,
  active,
}
