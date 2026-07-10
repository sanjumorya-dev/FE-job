import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/viewmodels/auth_viewmodel.dart';
import 'package:dihaadi_app/data/models/user_model.dart';
import 'role_selection_screen.dart';
import 'owner/owner_dashboard.dart';
import 'labour/labour_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check if user is already logged in
    final isLoggedIn = await context.read<AuthViewModel>().checkAuthStatus();

    if (isLoggedIn && mounted) {
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        // Check both roleName (from API) and role enum
        final isOwner = user.roleName?.toLowerCase() == 'owner' ||
            user.role == UserRole.owner;

        if (isOwner) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OwnerDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LabourDashboard()),
          );
        }
      } else {
        // Logged in but no user data, go to role selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    } else {
      // Not logged in, show role selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Job",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Connect Employers",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
