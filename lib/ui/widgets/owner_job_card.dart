import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../data/models/requirement_model.dart';
import 'package:intl/intl.dart';

class OwnerJobCard extends StatelessWidget {
  final Requirement requirement;
  final VoidCallback onTap;

  const OwnerJobCard({
    super.key,
    required this.requirement,
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

              // Info Grid Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9F0), // Light beige/cream
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridItem(
                              Icons.calendar_today_rounded,
                              '$dateRange ($duration)',
                              const Color(0xFFA67C52)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGridItem(Icons.access_time_rounded,
                              timeRange, const Color(0xFFA67C52)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridItem(Icons.people_alt_rounded,
                              '${requirement.personNeed ?? 0} workers needed',
                              const Color(0xFFA67C52)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGridItem(
                              Icons.info_outline_rounded,
                              _getStatusInfo(),
                              const Color(0xFFA67C52)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tags and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: requirement.workTypes.isEmpty
                          ? [_buildTag('Helper'), _buildTag('Packaging')]
                          : requirement.workTypes
                              .take(2)
                              .map((wt) => _buildTag(wt.name))
                              .toList(),
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'View',
                      const Color(0xFFE7F1FF),
                      AppColors.primary,
                      onTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Edit',
                      AppColors.primary,
                      Colors.white,
                      () {
                        // Edit logic handled in dashboard
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    String label = 'Active';
    Color bgColor = AppColors.successLight;
    Color textColor = AppColors.success;

    if (requirement.status == 1) {
      label = 'On Hold';
      bgColor = const Color(0xFFFFF4E5);
      textColor = const Color(0xFFFF9800);
    } else if (requirement.status == 2) {
      label = 'Closed';
      bgColor = const Color(0xFFF1F3F5);
      textColor = const Color(0xFF6D7487);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, Color bgColor, Color textColor, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getStatusInfo() {
    if (requirement.status == 1) return 'Requirement on hold';
    if (requirement.status == 2) return 'Hiring completed';
    return '14 applicants received'; // Mock but based on image
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
      return '07:00 AM - 06:00 PM';
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
