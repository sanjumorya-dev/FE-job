import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../data/models/requirement_model.dart';
import 'package:intl/intl.dart';

class WorkerJobCard extends StatelessWidget {
  final Requirement requirement;
  final bool isApplied;
  final VoidCallback onTap;

  const WorkerJobCard({
    super.key,
    required this.requirement,
    this.isApplied = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Formatting dates and duration
    final String dateRange = _formatDateRange();
    final String timeRange = _formatTimeRange();
    final String duration = _calculateDuration();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requirement.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.business_rounded,
                                size: 14, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text(
                              'Global Industries • 5.0 km away', // Mock data
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹ ${requirement.salary?.toStringAsFixed(0) ?? "0"}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        '/ day',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Schedule Info Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9F0), // Light cream logic from mockup
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 16, color: Colors.blueGrey.shade300),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$dateRange ($duration)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 16,
                      width: 1,
                      color: Colors.blueGrey.shade100,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 16, color: Colors.blueGrey.shade300),
                        const SizedBox(width: 8),
                        Text(
                          timeRange,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tags and Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skill Tags
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: requirement.workTypes.isEmpty
                          ? [
                              _buildTag('Helper'),
                              _buildTag('General'),
                            ]
                          : requirement.workTypes
                              .take(2)
                              .map((wt) => _buildTag(wt.name))
                              .toList(),
                    ),
                  ),

                  // Action Button or Status Badge
                  if (isApplied)
                    _buildStatusBadge('Requested', const Color(0xFFE8F4F9),
                        const Color(0xFF56A8C2))
                  else if (requirement.status == 0) // Assuming 0 is Active
                    _buildStatusBadge('Active', AppColors.successLight,
                        AppColors.success)
                  else
                    _buildApplyButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FF), // Very light blue
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Apply Now',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  String _formatDateRange() {
    if (requirement.dutyStartTime == null || requirement.dutyEndTime == null) {
      return 'Dates TBD';
    }
    final startFormat = DateFormat('MMM d').format(requirement.dutyStartTime!);
    final endFormat = DateFormat('MMM d').format(requirement.dutyEndTime!);
    return '$startFormat - $endFormat';
  }

  String _formatTimeRange() {
    if (requirement.dutyStartTime == null || requirement.dutyEndTime == null) {
      return '09:00 AM - 06:00 PM'; // Fallback
    }
    final startFormat = DateFormat('hh:mm a').format(requirement.dutyStartTime!);
    final endFormat = DateFormat('hh:mm a').format(requirement.dutyEndTime!);
    return '$startFormat - $endFormat';
  }

  String _calculateDuration() {
    if (requirement.dutyStartTime == null || requirement.dutyEndTime == null) {
      return '1 day';
    }
    final days =
        requirement.dutyEndTime!.difference(requirement.dutyStartTime!).inDays + 1;
    return '$days day${days > 1 ? 's' : ''}';
  }
}
