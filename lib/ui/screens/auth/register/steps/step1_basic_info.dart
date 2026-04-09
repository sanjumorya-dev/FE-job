import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/core/validators.dart';

class Step1BasicInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final TextEditingController countryCodeController;
  final TextEditingController aadharController;
  final Function(File?) onImageSelected;

  const Step1BasicInfo({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.mobileController,
    required this.countryCodeController,
    required this.aadharController,
    required this.onImageSelected,
  });

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController _digitsController;
  String _selectedCode = '+91';
  final List<String> _countryCodes = ['+91', '+1'];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
      widget.onImageSelected(_selectedImage);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.countryCodeController.text.trim().isNotEmpty
        ? widget.countryCodeController.text.trim()
        : '+91';
    _digitsController =
        TextEditingController(text: widget.mobileController.text.trim());
    widget.countryCodeController.text = _selectedCode;
    _digitsController.addListener(() {
      widget.mobileController.text = _digitsController.text;
    });
  }

  @override
  void dispose() {
    _digitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: widget.nameController,
            label: "FULL NAME",
            hint: "Enter your full name",
            icon: Icons.person_outline_rounded,
            validator: (v) => Validators.validateName(v),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _digitsController,
            label: "MOBILE NUMBER",
            hint: "Enter mobile number",
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length != 10) return 'Enter valid 10-digit number';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: widget.emailController,
            label: "EMAIL ADDRESS",
            hint: "rahul.sharma@example.com",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => Validators.validateEmail(v),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: widget.aadharController,
            label: "AADHAR NUMBER",
            hint: "1234 5678 9012",
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            maxLength: 12,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => Validators.validateAadhar(v),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
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
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
