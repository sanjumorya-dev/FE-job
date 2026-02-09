import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'otp_verify_screen.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _sending = false;

  Future<void> _sendOtp() async {
    if (_mobileController.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final ok = await context
        .read<AuthViewModel>()
        .sendOtp(_mobileController.text.trim());
    setState(() => _sending = false);
    if (ok && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => OtpVerifyScreen(
          mobileNumber: _mobileController.text.trim(),
          onVerified: (token) {
            Navigator.of(context).pop(); // close OTP sheet
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(
                  mobileNumber: _mobileController.text.trim(), token: token),
            ));
          },
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to send OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Enter your registered mobile number to receive an OTP'),
            const SizedBox(height: 12),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sending ? null : _sendOtp,
              child: _sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}


