import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../constants/colors.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String mobileNumber;
  final String countryCode;
  final void Function(String? token) onVerified;
  const OtpVerifyScreen({
    super.key,
    required this.mobileNumber,
    required this.onVerified,
    this.countryCode = '+91',
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _sending = false;
  bool _verifying = false;
  int _resendCooldown = 30; // seconds
  Timer? _cooldownTimer;
  final List<String> _otpDigits = ['', '', '', ''];
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
    _startCooldown();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _resendCooldown = 30;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _cooldownTimer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _sending = true);
    final ok = await context.read<AuthViewModel>().sendOtp(
          widget.mobileNumber,
          countryCode: widget.countryCode,
        );
    setState(() => _sending = false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
    _startCooldown();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete 4-digit OTP')),
      );
      return;
    }

    setState(() => _verifying = true);
    final token = await context.read<AuthViewModel>().verifyOtp(
          widget.mobileNumber,
          otp,
          countryCode: widget.countryCode,
        );
    setState(() => _verifying = false);

    if (token != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification successful'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onVerified(token);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
      // Clear OTP fields on failure
      setState(() {
        for (var i = 0; i < 4; i++) {
          _otpDigits[i] = '';
        }
      });
      _otpController.clear();
      _focusNodes[0].requestFocus();
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) value = value.substring(0, 1);
    setState(() => _otpDigits[index] = value);
    _otpController.text = _otpDigits.join();

    // Auto-focus next field
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all 4 digits entered
    if (_otpDigits.every((d) => d.isNotEmpty)) {
      _verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              
              const Text(
                'VERIFICATION CODE',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9AA1B4),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              
              // OTP Input Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Container(
                    width: 65,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _focusNodes[index].hasFocus 
                            ? const Color(0xFF2182F3) 
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: TextFormField(
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3A50),
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) {
                          _onOtpChanged(value, index);
                          if (value.isNotEmpty) {
                            setState(() {}); // Update border color
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 40),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _verifying ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F3A50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _verifying
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text(
                          "Verify & Continue",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Resend Section
              Center(
                child: Column(
                  children: [
                    Text(
                      _resendCooldown > 0
                          ? 'Wait for ${_resendCooldown}s to resend'
                          : "Didn't receive the code?",
                      style: const TextStyle(color: Color(0xFF6D7487), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    if (_resendCooldown == 0)
                      TextButton(
                        onPressed: _sending ? null : _sendOtp,
                        child: Text(
                          _sending ? 'Sending...' : 'Resend OTP',
                          style: const TextStyle(
                            color: Color(0xFF2182F3),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Security',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9AA1B4),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F3A50),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Color(0xFF6D7487), height: 1.5, fontFamily: 'Inter'),
            children: [
              const TextSpan(text: 'We have sent a 4-digit verification code to '),
              TextSpan(
                text: '${widget.countryCode} ${widget.mobileNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F3A50)),
              ),
              const TextSpan(text: '. Please enter it below.'),
            ],
          ),
        ),
      ],
    );
  }
}



