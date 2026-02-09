import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../data/models/user_model.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String mobileNumber;
  final String? token;
  const ResetPasswordScreen(
      {super.key, required this.mobileNumber, this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    final pass = _passwordController.text.trim();
    final conf = _confirmController.text.trim();
    if (pass.isEmpty || conf.isEmpty) return;
    if (pass != conf) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (widget.token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Missing reset token')));
      }
      return;
    }
    setState(() => _submitting = true);
    final ok =
        await context.read<AuthViewModel>().resetPassword(widget.token!, pass);
    setState(() => _submitting = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password reset successful. Please login.')));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => const LoginScreen(role: UserRole.worker)),
          (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reset password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
