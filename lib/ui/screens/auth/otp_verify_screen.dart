import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String mobileNumber;
  final void Function(String? token) onVerified;
  const OtpVerifyScreen(
      {super.key, required this.mobileNumber, required this.onVerified});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _sending = false;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  Future<void> _sendOtp() async {
    setState(() => _sending = true);
    final ok = await context.read<AuthViewModel>().sendOtp(widget.mobileNumber);
    setState(() => _sending = false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to send OTP')));
    }
  }

  Future<void> _verify() async {
    if (_otpController.text.trim().isEmpty) return;
    setState(() => _verifying = true);
    final token = await context
        .read<AuthViewModel>()
        .verifyOtp(widget.mobileNumber, _otpController.text.trim());
    setState(() => _verifying = false);
    if (token != null) {
      widget.onVerified(token);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Verify OTP',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                    'We sent an OTP to ${widget.mobileNumber}. Please enter it below.'),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: _verifying ? null : _verify,
                    child: _verifying
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verify')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _sending ? null : _sendOtp,
                  child: _sending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Resend OTP'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


