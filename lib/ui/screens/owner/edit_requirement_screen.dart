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
  // Use status integer from API (0=Open, 1=Hold, 2=Closed) - check model
  // RequirementStatus enum: open=0, hold=1, closed=2
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
        title: _titleController.text,
        description: _descriptionController.text,
        workTypeId: _selectedWorkTypeId!, // Force non-null as it should be selected
        salary: double.tryParse(_salaryController.text),
        personNeed: int.tryParse(_personNeedController.text) ?? 1, // Default to 1 if parsing fails
        address: _addressController.text,
        status: _status,
        date: widget.requirement.date, // Keep original date or update? Usually keep creation date
      );

      final success = await context.read<OwnerViewModel>().updateRequirement(
            widget.requirement.id,
            request,
          );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Requirement updated successfully'), backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<OwnerViewModel>().error ?? 'Update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Requirement'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Job Title'),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('e.g., Construction Worker Needed'),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Describe the job role and tasks'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('People Needed'),
              TextFormField(
                controller: _personNeedController,
                decoration: _inputDecoration('e.g., 5'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter number of people' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Salary / Wage (per day)'),
              TextFormField(
                controller: _salaryController,
                decoration: _inputDecoration('e.g., 500').copyWith(prefixText: '₹ '),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter salary' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Location / Address'),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration('Job site address'),
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Status'),
              DropdownButtonFormField<int>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Open")), // 0: Open
                  DropdownMenuItem(value: 1, child: Text("Hold")), // 1: Hold
                  DropdownMenuItem(value: 2, child: Text("Closed")), // 2: Closed
                ],
                onChanged: (val) => setState(() => _status = val!),
                decoration: _inputDecoration('Select Status'),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: context.watch<OwnerViewModel>().isLoading ? null : _updateRequirement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: context.watch<OwnerViewModel>().isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Requirement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textMain),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
