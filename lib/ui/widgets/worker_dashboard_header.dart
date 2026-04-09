import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class WorkerDashboardHeader extends StatelessWidget {
  final String userName;
  final String? location;
  final String? imageUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const WorkerDashboardHeader({
    super.key,
    required this.userName,
    this.location,
    this.imageUrl,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.background,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: AppColors.textHint),
                          ),
                        )
                      : const Icon(Icons.person, color: AppColors.textHint),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HELLO, $userName'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        location ?? 'Mumbai, MH',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onNotificationTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, color: AppColors.secondary, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
