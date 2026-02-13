import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String subtitle;
  final String? imageUrl;
  final bool isOwner;
  final String? location;
  final bool isAvailable;
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
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.waveColor1, AppColors.headerBackground],
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey ${userName.split(' ').first}!',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE4E7EE),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: AppColors.textHint, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Search',
                        style: TextStyle(color: AppColors.textHint, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onNotificationTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dashboard_customize_rounded,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
