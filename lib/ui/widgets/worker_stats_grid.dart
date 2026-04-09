import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class WorkerStatsGrid extends StatelessWidget {
  final int tasksCompleted;
  final int requestedJobs;
  final double monthlyEarnings;
  final double averageRating;

  const WorkerStatsGrid({
    super.key,
    required this.tasksCompleted,
    required this.requestedJobs,
    required this.monthlyEarnings,
    this.averageRating = 4.8,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
        children: [
          _buildStatCard(
            icon: Icons.check_circle_rounded,
            value: tasksCompleted.toString(),
            label: 'COMPLETED',
            color: const Color(0xFF2EC4B6), // Teal
          ),
          _buildStatCard(
            icon: Icons.send_rounded,
            value: requestedJobs.toString(),
            label: 'APPLIED',
            color: const Color(0xFFFF9F1C), // Vivid Orange
          ),
          _buildStatCard(
            icon: Icons.payments_rounded,
            value: '₹${monthlyEarnings.toStringAsFixed(0)}',
            label: 'EARNINGS',
            color: const Color(0xFF2182F3), // Primary Blue
          ),
          _buildStatCard(
            icon: Icons.star_rounded,
            value: averageRating.toString(),
            label: 'RATING',
            color: const Color(0xFFFFD166), // Saffron
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
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
