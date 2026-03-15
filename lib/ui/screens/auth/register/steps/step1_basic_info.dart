import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dihaadi_app/constants/colors.dart';

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
          const Text(
            "Sign up",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Add Photo",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: "Full Name",
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon:
                  const Icon(Icons.person, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            style: const TextStyle(color: AppColors.textMain),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < 3) return 'Enter Full Name';
              if (v.contains(RegExp(r'[0-9]'))) return 'Only text allowed';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: DropdownButton<String>(
                  value: _selectedCode,
                  underline: const SizedBox.shrink(),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textMain),
                  items: _countryCodes
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _selectedCode = v;
                      widget.countryCodeController.text = _selectedCode;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _digitsController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon:
                        const Icon(Icons.phone, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textMain),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // maxLength: 10,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length != 10) return 'Enter valid 10-digit mobile';
                    if (int.tryParse(v) == null) return 'Only digits allowed';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.emailController,
            decoration: InputDecoration(
              labelText: "Email Address",
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon:
                  const Icon(Icons.email, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            style: const TextStyle(color: AppColors.textMain),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;

              final email = value.trim();
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );

              if (!emailRegex.hasMatch(email)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.aadharController,
            decoration: InputDecoration(
              labelText: "Aadhar Number",
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon:
                  const Icon(Icons.badge, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            style: const TextStyle(color: AppColors.textMain),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 12,
            validator: (v) {
              if (v != null && v.length != 12) {
                return 'Enter valid 12-digit Aadhar';
              }
              if (v != null && int.tryParse(v) == null) {
                return 'Only digits allowed';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
