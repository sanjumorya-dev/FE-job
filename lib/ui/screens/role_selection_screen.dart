import 'package:flutter/material.dart';
import 'package:dihaadi_app/ui/screens/auth/login_screen.dart';
import 'package:dihaadi_app/data/models/user_model.dart';
import 'package:dihaadi_app/constants/colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) =>
                              const LoginScreen(role: UserRole.worker)),
                    );
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration placeholder
                      Container(
                        width: 260,
                        height: 320,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Icon(Icons.group,
                              size: 140, color: theme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Welcome to AppName',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lorem ipsum dolor sit amet elit volutpat consectetur adipiscing',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Dots indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(false),
                          const SizedBox(width: 6),
                          _dot(true),
                          const SizedBox(width: 6),
                          _dot(false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) =>
                              const LoginScreen(role: UserRole.worker)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Get Started',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) => Builder(builder: (context) {
        final color = Theme.of(context).primaryColor;
        return Container(
          width: active ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? color : AppColors.borderLight,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      });
}
