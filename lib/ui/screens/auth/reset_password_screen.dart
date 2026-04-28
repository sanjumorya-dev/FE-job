import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/core/validators.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
                content: const Text('Missing reset token'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating));
      }
      return;
    }

    setState(() => _submitting = true);
    final ok =
        await context.read<AuthViewModel>().resetPassword(widget.token!, _passwordController.text.trim());
    setState(() => _submitting = false);
    
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Password reset successful. Please login.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating));
          
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => const LoginScreen(role: UserRole.worker)),
          (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to reset password'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 48),
                
                _buildInputField(
                  controller: _passwordController,
                  label: "NEW PASSWORD",
                  hint: "Enter new password",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (v) => Validators.validatePassword(v),
                ),
                
                const SizedBox(height: 24),
                
                _buildInputField(
                  controller: _confirmController,
                  label: "CONFIRM PASSWORD",
                  hint: "Re-enter new password",
                  icon: Icons.lock_reset_rounded,
                  isPassword: true,
                  validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
                ),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _submitting
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text(
                            "Reset Password",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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
          'SECURE ACCOUNT',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Set a new secure password for your account to regain access.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textHint,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14, fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
