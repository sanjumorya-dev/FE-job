import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';

class NotificationsScreen extends StatelessWidget {
  final bool isOwner;
  const NotificationsScreen({super.key, this.isOwner = false});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Application Accepted',
        'body': 'Your application has been accepted by an owner.',
        'icon': Icons.check_circle_outline,
      },
      {
        'title': 'Application Rejected',
        'body': 'One of your applications was rejected.',
        'icon': Icons.cancel_outlined,
      },
      {
        'title': isOwner ? 'New Applicant' : 'New Nearby Job',
        'body': isOwner
            ? 'A worker has applied for your posted requirement.'
            : 'A new job has been posted near your location.',
        'icon': isOwner ? Icons.people_outline : Icons.work_outline,
      },
    ];

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']! as String,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['body']! as String,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
