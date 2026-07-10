import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';

/// A reusable empty state widget with icon and text.
/// Shown when a list has no items to display.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double? iconSize;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.subtitle,
    this.iconSize = 64,
    this.action,
  });

  /// Predefined empty state for "No Jobs Found"
  const EmptyState.noJobs({
    super.key,
    this.action,
  })  : icon = Icons.work_off_rounded,
        title = 'No Jobs Found',
        subtitle = 'There are no jobs to display right now.',
        iconSize = 64;

  /// Predefined empty state for "No Applications"
  const EmptyState.noApplications({
    super.key,
    this.action,
  })  : icon = Icons.assignment_late_rounded,
        title = 'No Applications',
        subtitle = 'No applications have been received yet.',
        iconSize = 64;

  /// Predefined empty state for "No Messages"
  const EmptyState.noMessages({
    super.key,
    this.action,
  })  : icon = Icons.chat_bubble_outline_rounded,
        title = 'No Messages',
        subtitle = 'Start a conversation to see messages here.',
        iconSize = 64;

  /// Predefined empty state for search results
  const EmptyState.noResults({
    super.key,
    this.action,
  })  : icon = Icons.search_off_rounded,
        title = 'No Results',
        subtitle = 'Try adjusting your search or filters.',
        iconSize = 64;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  shape: BoxShape.circle,
                ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
