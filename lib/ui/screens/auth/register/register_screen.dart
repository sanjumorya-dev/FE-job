import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:dihaadi_app/data/models/user_model.dart';
import 'package:dihaadi_app/viewmodels/auth_viewmodel.dart';
import 'package:dihaadi_app/viewmodels/work_type_viewmodel.dart';
import 'steps/step1_basic_info.dart';
import 'steps/step2_address_info.dart';
import 'steps/step3_role_info.dart';
// import '../login_screen.dart';
import '../otp_verify_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_dashboard.dart';
import 'package:dihaadi_app/ui/screens/labour/labour_dashboard.dart';
import 'package:dihaadi_app/ui/widgets/auth_header.dart';
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
            const SnackBar(content: Text("Please select at least one skill")),
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
    }
  }

  void _submit() async {
    setState(() => _isLoading = true);

    final request = CreateUserRequest(
      name: nameController.text,
      email: emailController.text.isNotEmpty ? emailController.text : null,
      mobileNumber: mobileController.text,
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
      // After successful registration, prompt user to verify OTP
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => OtpVerifyScreen(
          mobileNumber: mobileController.text.trim(),
          onVerified: (token) {
            Navigator.of(context).pop(); // close OTP sheet
            if (!mounted) return;
            // Navigate straight to dashboard based on selected role
            if (selectedRole == UserRole.owner) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const OwnerDashboard()),
                (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const LabourDashboard()),
                (route) => false,
              );
            }
          },
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                context.read<AuthViewModel>().error ?? "Registration failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkTypeViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundBeige,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const Align(
              alignment: Alignment.topCenter,
              child: AuthHeader(
                title: "Sign Up!",
                subtitle: "Create Account",
                height: 340,
              ),
            ),
            // Dot Patterns
            Positioned.fill(
              child: _buildDotPatterns(),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 240),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Custom Progress Indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            child: Row(
                              children: List.generate(
                                  3,
                                  (index) => Expanded(
                                        child: Container(
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: index <= _currentStep
                                                ? AppColors.primary
                                                : Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      )),
                            ),
                          ),
                          // Form Steps
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: IndexedStack(
                              index: _currentStep,
                              children: [
                                Step1BasicInfo(
                                  formKey: _formKeys[0],
                                  nameController: nameController,
                                  emailController: emailController,
                                  mobileController: mobileController,
                                  aadharController: aadharController,
                                  onImageSelected: (image) =>
                                      selectedImage = image,
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
                                  confirmPasswordController:
                                      confirmPasswordController,
                                  isWorker: selectedRole == UserRole.worker,
                                  onWorkTypesChanged: (types) =>
                                      selectedWorkTypes = types,
                                  onRoleChanged: (role) =>
                                      setState(() => selectedRole = role),
                                ),
                              ],
                            ),
                          ),
                          // Navigation Buttons
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              children: [
                                if (_currentStep > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: IconButton(
                                      onPressed: _prevStep,
                                      icon: const Icon(Icons.arrow_back_ios,
                                          color: Colors.grey),
                                    ),
                                  ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _nextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _currentStep == 2
                                                ? "Sign Up"
                                                : "Next",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotPatterns() {
    return Stack(
      children: [
        // Top-right dots
        Positioned(
          top: 50,
          right: 20,
          child: _buildDotGrid(),
        ),
        // Bottom-left dots
        Positioned(
          bottom: 40,
          left: 20,
          child: _buildDotGrid(),
        ),
      ],
    );
  }

  Widget _buildDotGrid() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _DotGridPainter(),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    const dotRadius = 2.0;
    const spacing = 8.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
