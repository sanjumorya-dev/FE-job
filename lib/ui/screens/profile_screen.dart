import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'role_selection_screen.dart';
import 'edit_profile_screen.dart';
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
          return Center(
            child: Text(
              "Not logged in",
              style: TextStyle(color: AppColors.textMain),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Avatar
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surface,
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      user.email ?? user.mobileNumber ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Account Settings Section
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Personal Information
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      label: 'Personal Information',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(user: user),
                          ),
                        );
                        if (result == true && mounted) {
                          context.read<AuthViewModel>().fetchProfile();
                        }
                      },
                    ),
                    // Notifications
                    _buildSettingsTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {
                        // TODO: Navigate to notifications settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Notifications settings coming soon')),
                        );
                      },
                    ),
                    // Security
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      label: 'Security',
                      onTap: () {
                        // TODO: Navigate to security settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Security settings coming soon')),
                        );
                      },
                    ),
                    // Change Password
                    _buildSettingsTile(
                      icon: Icons.lock_outlined,
                      label: 'Change Password',
                      onTap: () {
                        // TODO: Navigate to change password screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Change password coming soon')),
                        );
                      },
                    ),
                    // Help & Support
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      onTap: () {
                        // TODO: Navigate to help & support
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Help & Support coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Log Out
                    _buildSettingsTile(
                      icon: Icons.logout_outlined,
                      label: 'Log Out',
                      isDestructive: true,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color:
                      isDestructive ? AppColors.error : AppColors.textSecondary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          isDestructive ? AppColors.error : AppColors.textMain,
                      fontWeight:
                          isDestructive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
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
