import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/data/models/requirement_model.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:dihaadi_app/constants/colors.dart';

class EditRequirementScreen extends StatefulWidget {
  final Requirement requirement;

  const EditRequirementScreen({super.key, required this.requirement});

  @override
  State<EditRequirementScreen> createState() => _EditRequirementScreenState();
}

class _EditRequirementScreenState extends State<EditRequirementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _salaryController;
  late TextEditingController _personNeedController;
  late TextEditingController _addressController;
  
  String? _selectedWorkTypeId;
  late int _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.requirement.title);
    _descriptionController = TextEditingController(text: widget.requirement.description);
    _salaryController = TextEditingController(text: widget.requirement.salary?.toString() ?? '');
    _personNeedController = TextEditingController(text: widget.requirement.personNeed?.toString() ?? '');
    _addressController = TextEditingController(text: widget.requirement.address ?? '');
    _selectedWorkTypeId = widget.requirement.workTypeId;
    _status = widget.requirement.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _personNeedController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _updateRequirement() async {
    if (_formKey.currentState!.validate()) {
      final request = CreateRequirementRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        workTypeIds: [if ((_selectedWorkTypeId ?? '').isNotEmpty) _selectedWorkTypeId!],
        salary: double.tryParse(_salaryController.text),
        personNeed: int.tryParse(_personNeedController.text) ?? 1,
        address: _addressController.text.trim(),
        status: _status,
        date: widget.requirement.date,
      );

      final success = await context.read<OwnerViewModel>().updateRequirement(
            widget.requirement.id,
            request,
          );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Requirement updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<OwnerViewModel>().error ?? 'Update failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                const SizedBox(height: 32),
                
                _buildInputField(
                  controller: _titleController,
                  label: "JOB TITLE",
                  hint: "Enter job title",
                  icon: Icons.title_rounded,
                  validator: (v) => v!.isEmpty ? 'Enter title' : null,
                ),
                
                const SizedBox(height: 24),
                
                _buildInputField(
                  controller: _descriptionController,
                  label: "DESCRIPTION",
                  hint: "Describe the job role",
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? 'Enter description' : null,
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _personNeedController,
                        label: "WORKERS",
                        hint: "Needed",
                        icon: Icons.people_outline_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Enter count' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: _salaryController,
                        label: "WAGE (₹)",
                        hint: "Daily",
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Enter salary' : null,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildInputField(
                  controller: _addressController,
                  label: "SITE ADDRESS",
                  hint: "Job site location",
                  icon: Icons.location_on_outlined,
                  validator: (v) => v!.isEmpty ? 'Enter address' : null,
                ),
                
                const SizedBox(height: 24),
                
                _buildStatusDropdown(),
                
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: context.watch<OwnerViewModel>().isLoading ? null : _updateRequirement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: context.watch<OwnerViewModel>().isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text(
                            "Update Changes",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
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
          'MANAGEMENT',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Edit Job',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
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
    TextInputType? keyboardType,
    int maxLines = 1,
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
          maxLines: maxLines,
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "JOB STATUS",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textHint,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: _status,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.info_outline_rounded, color: AppColors.textHint, size: 20),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: const [
            DropdownMenuItem(value: 0, child: Text("Open")),
            DropdownMenuItem(value: 1, child: Text("Hold")),
            DropdownMenuItem(value: 2, child: Text("Closed")),
          ],
          onChanged: (val) => setState(() => _status = val!),
        ),
      ],
    );
  }
}
