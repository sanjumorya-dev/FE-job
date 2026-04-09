import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class OwnerDashboardStats extends StatelessWidget {
  final int activeJobs;
  final int pendingApps;
  final int completedJobs;

  const OwnerDashboardStats({
    super.key,
    required this.activeJobs,
    required this.pendingApps,
    required this.completedJobs,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.business_center_rounded,
            value: activeJobs.toString(),
            label: 'Active Jobs',
            color: const Color(0xFF2182F3), // Primary Blue
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.pending_actions_rounded,
            value: pendingApps.toString(),
            label: 'Pending Apps',
            color: const Color(0xFFFF9F1C), // Vivid Orange
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.check_circle_rounded,
            value: completedJobs.toString(),
            label: 'Completed',
            color: const Color(0xFF2EC4B6), // Teal
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
