import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:dihaadi_app/data/models/user_model.dart';
import 'package:dihaadi_app/viewmodels/auth_viewmodel.dart';
import 'package:dihaadi_app/viewmodels/work_type_viewmodel.dart';
import 'steps/step1_basic_info.dart';
import 'steps/step2_address_info.dart';
import 'steps/step3_role_info.dart';
import '../login_screen.dart';
import '../otp_verify_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_dashboard_new.dart';
import 'package:dihaadi_app/ui/screens/labour/labour_dashboard_new.dart';
import 'package:dihaadi_app/constants/colors.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Data Holders
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  final TextEditingController aadharController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController countryController =
      TextEditingController(text: 'India');

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  List<String> selectedWorkTypes = [];
  File? selectedImage;
  late UserRole selectedRole;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.role;
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep == 2 && selectedRole == UserRole.worker) {
        if (selectedWorkTypes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please select at least one skill"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        _submit();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return "Personal Details";
      case 1:
        return "Address Details";
      case 2:
        return "Role & Security";
      default:
        return "";
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return "Tell us about yourself to get started.";
      case 1:
        return "Where are you located? (Auto-fill available)";
      case 2:
        return "Choose your role and set a secure password.";
      default:
        return "";
    }
  }

  @override
  void _submit() async {
    setState(() => _isLoading = true);

    final request = CreateUserRequest(
      name: nameController.text,
      email: emailController.text.isNotEmpty ? emailController.text : null,
      mobileNumber: mobileController.text.trim(),
      countryCode: countryCodeController.text.trim(),
      aadharNo: aadharController.text.isNotEmpty ? aadharController.text : null,
      address: addressController.text,
      city: cityController.text,
      state: stateController.text,
      pincode: pincodeController.text,
      country: countryController.text,
      password: passwordController.text,
      role: selectedRole,
      workTypeIds: selectedRole == UserRole.worker ? selectedWorkTypes : null,
      image: selectedImage,
    );

    final success = await context.read<AuthViewModel>().register(request);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(
            mobileNumber: mobileController.text.trim(),
            countryCode: countryCodeController.text.trim(),
            onVerified: (token) {
              Navigator.of(context).pop(); // close OTP screen
              Navigator.of(context).pop(); // close register screen

              if (!mounted) return;

              if (selectedRole == UserRole.owner) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OwnerDashboardNew()),
                  (route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LabourDashboardNew()),
                  (route) => false,
                );
              }
            },
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthViewModel>().error ?? "Registration failed"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkTypeViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildProgressBar(),
                      const SizedBox(height: 32),
                      IndexedStack(
                        index: _currentStep,
                        children: [
                          Step1BasicInfo(
                            formKey: _formKeys[0],
                            nameController: nameController,
                            emailController: emailController,
                            mobileController: mobileController,
                            countryCodeController: countryCodeController,
                            aadharController: aadharController,
                            onImageSelected: (image) => selectedImage = image,
                          ),
                          Step2AddressInfo(
                            formKey: _formKeys[1],
                            addressController: addressController,
                            cityController: cityController,
                            stateController: stateController,
                            pincodeController: pincodeController,
                            countryController: countryController,
                          ),
                          Step3RoleInfo(
                            formKey: _formKeys[2],
                            passwordController: passwordController,
                            confirmPasswordController: confirmPasswordController,
                            isWorker: selectedRole == UserRole.worker,
                            onWorkTypesChanged: (types) => selectedWorkTypes = types,
                            onRoleChanged: (role) => setState(() => selectedRole = role),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildBottomAction(),
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
          onTap: _prevStep,
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
        Text(
          'STEP ${_currentStep + 1} OF 3',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getStepTitle(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getStepSubtitle(),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 6,
          width: MediaQuery.of(context).size.width * ((_currentStep + 1) / 3) - 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(
                      _currentStep == 2 ? "Complete Registration" : "Continue",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          if (_currentStep == 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(role: widget.role),
                      ),
                    );
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
