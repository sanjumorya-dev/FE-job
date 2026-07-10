import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dihaadi_app/data/models/user_model.dart';
import 'package:dihaadi_app/viewmodels/auth_viewmodel.dart';
import 'package:dihaadi_app/core/di/injection_container.dart';
import 'package:dihaadi_app/data/services/media_service.dart';
import 'package:dihaadi_app/data/services/upload_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController aadharCtrl;
  late TextEditingController mobileCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController pincodeCtrl;
  late TextEditingController countryCtrl;

  late String originalMobile;
  late String _countryCode;
  bool _isSubmitting = false;
  bool _isMobileChanged = false;
  bool _mobileVerified = false;
  String? _mobileError;

  // Profile image state
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.name);
    emailCtrl = TextEditingController(text: widget.user.email ?? '');
    aadharCtrl = TextEditingController(text: widget.user.aadharNo ?? '');
    mobileCtrl = TextEditingController(text: widget.user.mobileNumber ?? '');
    originalMobile = widget.user.mobileNumber ?? '';
    _countryCode = (widget.user.countryCode ?? '+91').trim();
    _currentImageUrl = widget.user.imageUrl;

    // Address fields
    final addr = widget.user.addresses?.isNotEmpty == true
        ? widget.user.addresses!.first
        : null;
    addressCtrl = TextEditingController(text: addr?['address'] ?? '');
    cityCtrl = TextEditingController(text: addr?['city'] ?? '');
    stateCtrl = TextEditingController(text: addr?['state'] ?? '');
    pincodeCtrl = TextEditingController(text: addr?['pincode'] ?? '');
    countryCtrl = TextEditingController(text: addr?['country'] ?? 'India');

    mobileCtrl.addListener(() {
      setState(() {
        _isMobileChanged = mobileCtrl.text.trim() != originalMobile;
        if (_isMobileChanged) {
          _mobileVerified = false;
          _mobileError = null;
        }
      });
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    aadharCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pincodeCtrl.dispose();
    countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyMobileWithOtp() async {
    final messenger = ScaffoldMessenger.of(context);
    final newMobile = mobileCtrl.text.trim();

    if (newMobile.isEmpty) {
      setState(() => _mobileError = 'Mobile number cannot be empty');
      return;
    }

    // Send OTP
    setState(() => _mobileError = null);
    final authVm = context.read<AuthViewModel>();
    final otpSent = await authVm.sendOtp(newMobile, countryCode: _countryCode);

    if (!otpSent && mounted) {
      setState(() => _mobileError = 'Failed to send OTP');
      return;
    }

    if (!mounted) return;

    // Show OTP verification dialog
    final otp = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _OtpVerificationDialog(
        mobileNumber: newMobile,
        countryCode: _countryCode,
      ),
    );

    if (otp != null && mounted) {
      // Verify OTP
      final token = await authVm.verifyOtp(newMobile, otp, countryCode: _countryCode);
      if (token != null && mounted) {
        setState(() {
          _mobileVerified = true;
          _mobileError = null;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('Mobile number verified successfully')),
        );
      } else if (mounted) {
        setState(() => _mobileError = 'OTP verification failed');
        messenger.showSnackBar(
          const SnackBar(content: Text('Invalid OTP')),
        );
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final mediaService = sl<MediaService>();
    final uploadService = sl<UploadService>();

    // Show bottom sheet to choose source
    if (!mounted) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _isUploadingImage = true);

    try {
      File? image;
      if (source == ImageSource.gallery) {
        image = await mediaService.pickImageFromGallery();
      } else {
        image = await mediaService.pickImageFromCamera();
      }

      if (image == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      // Upload the image
      final imageUrl = await uploadService.uploadProfileImage(image);

      if (mounted) {
        setState(() {
          _selectedImage = image;
          _currentImageUrl = imageUrl;
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_isMobileChanged && !_mobileVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your new mobile number')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authVm = context.read<AuthViewModel>();
      final updateData = {
        'Name': nameCtrl.text.trim(),
        'Email': emailCtrl.text.trim(),
        'AadharNo': aadharCtrl.text.trim(),
        if (_isMobileChanged) 'MobileNumber': mobileCtrl.text.trim(),
        'CountryCode': _countryCode,
        'Address': addressCtrl.text.trim(),
        'City': cityCtrl.text.trim(),
        'State': stateCtrl.text.trim(),
        'Pincode': pincodeCtrl.text.trim(),
        'Country': countryCtrl.text.trim(),
        if (_currentImageUrl != null) 'ImageUrl': _currentImageUrl,
      };

      final success = await authVm.updateProfile(updateData);
      setState(() => _isSubmitting = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authVm.error ?? 'Failed to update profile')),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Picker
            Center(
              child: GestureDetector(
                onTap: _isUploadingImage ? null : _pickProfileImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : (_currentImageUrl != null &&
                                    _currentImageUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(_currentImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (_selectedImage == null &&
                              (_currentImageUrl == null ||
                                  _currentImageUrl!.isEmpty))
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    if (_isUploadingImage)
                      const Positioned.fill(
                        child: CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // Aadhar Field
            TextField(
              controller: aadharCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Aadhar Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 16),

            // Mobile Field with OTP Verification
            TextField(
              controller: mobileCtrl,
              keyboardType: TextInputType.phone,
              enabled: !_mobileVerified,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.phone),
                suffixIcon: _isMobileChanged
                    ? (_mobileVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : IconButton(
                            icon: const Icon(Icons.verified_user),
                            onPressed: _verifyMobileWithOtp,
                          ))
                    : null,
                errorText: _mobileError,
              ),
            ),
            if (_isMobileChanged && !_mobileVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _verifyMobileWithOtp,
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Verify Mobile with OTP'),
                ),
              ),
            const SizedBox(height: 24),

            // Address Section
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Address Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Address Field
            TextField(
              controller: addressCtrl,
              decoration: InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // City Field
            TextField(
              controller: cityCtrl,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),

            // State Field
            TextField(
              controller: stateCtrl,
              decoration: InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.map),
              ),
            ),
            const SizedBox(height: 16),

            // Pincode Field
            TextField(
              controller: pincodeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.pin),
              ),
            ),
            const SizedBox(height: 16),

            // Country Field
            TextField(
              controller: countryCtrl,
              decoration: InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.public),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpVerificationDialog extends StatefulWidget {
  final String mobileNumber;
  final String countryCode;

  const _OtpVerificationDialog({
    required this.mobileNumber,
    required this.countryCode,
  });

  @override
  State<_OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<_OtpVerificationDialog> {
  late TextEditingController otpCtrl;
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    otpCtrl = TextEditingController();
  }

  @override
  void dispose() {
    otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (otpCtrl.text.trim().isEmpty) {
      setState(() => _error = 'OTP cannot be empty');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final authVm = context.read<AuthViewModel>();
    final token =
        await authVm.verifyOtp(
          widget.mobileNumber,
          otpCtrl.text.trim(),
          countryCode: widget.countryCode,
        );

    setState(() => _isVerifying = false);

    if (mounted) {
      if (token != null) {
        Navigator.pop(context, otpCtrl.text.trim());
      } else {
        setState(() => _error = 'Invalid OTP');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify Mobile Number'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('We sent an OTP to ${widget.countryCode} ${widget.mobileNumber}'),
          const SizedBox(height: 16),
          TextField(
            controller: otpCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter OTP',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verify,
          child: _isVerifying
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}


