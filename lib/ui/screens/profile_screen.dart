import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/labour_viewmodel.dart';
import '../../../data/models/user_model.dart';
import 'role_selection_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import '../../../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        final user = viewModel.currentUser;
        if (user == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F8FA),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isOwner = user.role == UserRole.owner;
        final bottomSafeInset = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FA),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: bottomSafeInset + 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Edit Profile Button Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF171A22),
                          letterSpacing: -0.5,
                        ),
                      ),
                      // Edit Profile button
                      InkWell(
                        onTap: () async {
                          final authVm = context.read<AuthViewModel>();
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(user: user),
                            ),
                          );
                          if (result == true) {
                            authVm.fetchProfile();
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0EA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Color(0xFFFF5123),
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF5123),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Avatar & Main Info Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with verified badge
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fit=crop&w=150&h=150',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF208F67),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF171A22),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOwner
                                  ? 'Mehta Logistics Pvt. Ltd.'
                                  : 'General Construction / Mason',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7A8394),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Tags
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  // Verification tag
                                  _buildProfileTag(
                                    icon: Icons.shield_outlined,
                                    label: isOwner ? 'Verified Owner' : 'Verified Worker',
                                    backgroundColor: const Color(0xFFFFF0EA),
                                    textColor: const Color(0xFFFF5123),
                                  ),
                                  const SizedBox(width: 8),
                                  // Location tag
                                  _buildProfileTag(
                                    icon: Icons.location_on_outlined,
                                    label: 'Delhi NCR',
                                    backgroundColor: const Color(0xFFEFF3F7),
                                    textColor: const Color(0xFF7A8394),
                                  ),
                                  const SizedBox(width: 8),
                                  // Member since tag
                                  _buildProfileTag(
                                    icon: Icons.calendar_today_outlined,
                                    label: isOwner ? 'Since 2021' : 'Since 2023',
                                    backgroundColor: const Color(0xFFEFF3F7),
                                    textColor: const Color(0xFF7A8394),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  _buildStatsRow(isOwner),
                  const SizedBox(height: 20),

                  // Complete Profile Card Banner
                  _buildCompleteProfileBanner(isOwner),
                  const SizedBox(height: 28),

                  // Customized sections based on role
                  if (isOwner) ..._buildOwnerSections(context) else ..._buildWorkerSections(context),

                  const SizedBox(height: 16),

                  // Sign Out Button
                  _buildSignOutButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTag({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isOwner) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              value: isOwner ? '47' : '54',
              label: isOwner ? 'Requirements\nPosted' : 'Jobs\nCompleted',
            ),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFE5E9EB)),
          Expanded(
            child: _buildStatItem(
              value: isOwner ? '312' : '12',
              label: isOwner ? 'Workers\nHired' : 'Active\nApplications',
            ),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFE5E9EB)),
          Expanded(
            child: _buildStatItem(
              value: isOwner ? '4.7' : '4.8',
              label: 'Avg.\nRating',
            ),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFE5E9EB)),
          Expanded(
            child: _buildStatItem(
              value: isOwner ? '94%' : '98%',
              label: 'On-time\nRate',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF171A22),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF7A8394),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteProfileBanner(bool isOwner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Lightning bolt box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5123),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.flash_on_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwner ? 'Complete your profile — 82%' : 'Complete your profile — 90%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171A22),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOwner ? 'Add GSTIN to unlock bulk hiring' : 'Add Aadhaar to unlock bulk jobs',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A8394),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Progress bar
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                width: isOwner ? 60 * 0.82 : 60 * 0.90,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5123),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOwnerSections(BuildContext context) {
    return [
      // COMPANY
      const Text(
        'COMPANY',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7A8394),
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 8),
      _buildSectionContainer([
        _buildListTile(
          icon: Icons.business_outlined,
          title: 'Company Profile',
          subtitle: 'Mehta Logistics Pvt. Ltd.',
          onTap: () => _showComingSoon(context, 'Company Profile'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.verified_user_outlined,
          title: 'Verification',
          subtitle: 'GST, PAN, Trade License',
          trailingWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF208F67),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Verified',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          onTap: () => _showComingSoon(context, 'Verification settings'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.payment_outlined,
          title: 'Payment Settings',
          subtitle: 'Bank account · UPI linked',
          onTap: () => _showComingSoon(context, 'Payment Settings'),
        ),
      ]),
      const SizedBox(height: 24),

      // PERFORMANCE
      const Text(
        'PERFORMANCE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7A8394),
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 8),
      _buildSectionContainer([
        _buildListTile(
          icon: Icons.star_outline_rounded,
          title: 'Ratings & Reviews',
          subtitle: '4.7 avg · 89 reviews',
          onTap: () => _showComingSoon(context, 'Ratings & Reviews'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.bar_chart_rounded,
          title: 'Business Analytics',
          subtitle: 'Hiring trends & spend',
          onTap: () => _showComingSoon(context, 'Business Analytics'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Attendance History',
          subtitle: 'Last 90 days',
          onTap: () => _showComingSoon(context, 'Attendance History'),
        ),
      ]),
      const SizedBox(height: 24),

      // ACCOUNT
      const Text(
        'ACCOUNT',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7A8394),
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 8),
      _buildSectionContainer([
        _buildListTile(
          icon: Icons.language_rounded,
          title: 'Language Preferences',
          subtitle: 'English, Hindi',
          onTap: () => _showComingSoon(context, 'Language Preferences'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          subtitle: 'Push, SMS, Email',
          trailingWidget: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5123),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '3',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          onTap: () => _showComingSoon(context, 'Notifications Settings'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Security, data, privacy',
          onTap: () => _showComingSoon(context, 'Settings'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQs, contact us',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HelpSupportScreen(role: UserRole.owner),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildWorkerSections(BuildContext context) {
    return [
      // WORK PROFILE
      const Text(
        'WORK PROFILE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7A8394),
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 8),
      _buildSectionContainer([
        _buildListTile(
          icon: Icons.handyman_outlined,
          title: 'Skills & Categories',
          subtitle: 'General Labor, Mason, Painter',
          onTap: () => _showComingSoon(context, 'Skills & Categories'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.verified_user_outlined,
          title: 'Aadhaar Verification',
          subtitle: 'Aadhaar Verified',
          trailingWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF208F67),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Verified',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          onTap: () => _showComingSoon(context, 'Aadhaar Verification'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Bank Account & Wallet',
          subtitle: 'UPI linked',
          onTap: () => _showComingSoon(context, 'Wallet Settings'),
        ),
      ]),
      const SizedBox(height: 24),

      // PERFORMANCE
      const Text(
        'PERFORMANCE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7A8394),
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 8),
      _buildSectionContainer([
        _buildListTile(
          icon: Icons.star_outline_rounded,
          title: 'Ratings & Reviews',
          subtitle: '4.8 avg · 45 reviews',
          onTap: () => _showComingSoon(context, 'Ratings & Reviews'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.monetization_on_outlined,
          title: 'Earnings Analytics',
          subtitle: 'Monthly trends & payout history',
          onTap: () => _showComingSoon(context, 'Earnings Analytics'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.calendar_month_outlined,
          title: 'Attendance History',
          subtitle: 'Last 90 days',
          onTap: () => _showComingSoon(context, 'Attendance History'),
        ),
      ]),
      const SizedBox(height: 24),

      // ACCOUNT
      const Text(
        'ACCOUNT',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7A8394),
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 8),
      _buildSectionContainer([
        _buildListTile(
          icon: Icons.language_rounded,
          title: 'Language Preferences',
          subtitle: 'English, Hindi',
          onTap: () => _showComingSoon(context, 'Language Preferences'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          subtitle: 'Push, SMS, Email',
          trailingWidget: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5123),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '3',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          onTap: () => _showComingSoon(context, 'Notifications Settings'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Security, data, privacy',
          onTap: () => _showComingSoon(context, 'Settings'),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9EB)),
        _buildListTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQs, contact us',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HelpSupportScreen(role: UserRole.worker),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF7A8394),
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF171A22),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF7A8394),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingWidget != null) ...[
            trailingWidget,
            const SizedBox(width: 8),
          ],
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9AA1B4),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E9EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFF5123),
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5123),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthViewModel>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
