import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String subtitle;
  final String? imageUrl;
  final bool isOwner;
  final String? location; // For Owner
  final bool isAvailable; // For Labour
  final VoidCallback? onNotificationTap;
  final ValueChanged<bool>? onAvailabilityChanged;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.subtitle,
    this.imageUrl,
    this.isOwner = true,
    this.location,
    this.isAvailable = false,
    this.onNotificationTap,
    this.onAvailabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOwner
              ? [AppColors.waveColor1, AppColors.headerBackground]
              : [AppColors.waveColor2, AppColors.waveColor1],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glassStroke, width: 2),
                  image: DecorationImage(
                    image: imageUrl != null && imageUrl!.isNotEmpty
                        ? NetworkImage(imageUrl!)
                        : const AssetImage('assets/images/placeholder_profile.png')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textMain,
                        size: 24,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isOwner && location != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.textMain,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location!,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isOwner)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => onAvailabilityChanged?.call(!isAvailable),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAvailable ? 'Available for Work' : 'Unavailable',
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
