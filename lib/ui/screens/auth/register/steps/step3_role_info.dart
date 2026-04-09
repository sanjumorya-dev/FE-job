import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/data/models/user_model.dart';
import 'package:dihaadi_app/viewmodels/work_type_viewmodel.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/core/validators.dart';

class Step3RoleInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isWorker;
  final Function(List<String>) onWorkTypesChanged;
  final Function(UserRole) onRoleChanged;

  const Step3RoleInfo({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isWorker,
    required this.onWorkTypesChanged,
    required this.onRoleChanged,
  });

  @override
  State<Step3RoleInfo> createState() => _Step3RoleInfoState();
}

class _Step3RoleInfoState extends State<Step3RoleInfo> {
  late UserRole _selectedRole;
  final List<String> _selectedWorkTypeIds = [];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.isWorker ? UserRole.worker : UserRole.owner;

    // Fetch work types when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkTypeViewModel>().fetchWorkTypes();
    });
  }

  void _toggleWorkType(String id) {
    setState(() {
      if (_selectedWorkTypeIds.contains(id)) {
        _selectedWorkTypeIds.remove(id);
      } else {
        _selectedWorkTypeIds.add(id);
      }
      widget.onWorkTypesChanged(_selectedWorkTypeIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "CHOOSE YOUR ROLE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textHint,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RoleCard(
                  title: "Owner",
                  icon: Icons.business_center_outlined,
                  isSelected: _selectedRole == UserRole.owner,
                  onTap: () {
                    setState(() => _selectedRole = UserRole.owner);
                    widget.onRoleChanged(UserRole.owner);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RoleCard(
                  title: "Worker",
                  icon: Icons.person_search_outlined,
                  isSelected: _selectedRole == UserRole.worker,
                  onTap: () {
                    setState(() => _selectedRole = UserRole.worker);
                    widget.onRoleChanged(UserRole.worker);
                  },
                ),
              ),
            ],
          ),
          if (_selectedRole == UserRole.worker) ...[
            const SizedBox(height: 32),
            const Text(
              "SELECT YOUR SKILLS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textHint,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<WorkTypeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ));
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: viewModel.workTypes.map((type) {
                    final isSelected = _selectedWorkTypeIds.contains(type.id);
                    return FilterChip(
                      label: Text(type.name),
                      selected: isSelected,
                      onSelected: (_) => _toggleWorkType(type.id),
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.secondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
          const SizedBox(height: 32),
          _buildInputField(
            controller: widget.passwordController,
            label: "PASSWORD",
            hint: "Enter secure password",
            icon: Icons.lock_outline_rounded,
            isPassword: true,
          ),
          const SizedBox(height: 24),
          _buildInputField(
            controller: widget.confirmPasswordController,
            label: "CONFIRM PASSWORD",
            hint: "Re-enter password",
            icon: Icons.lock_reset_rounded,
            isPassword: true,
            isConfirm: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isConfirm = false,
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
          validator: (v) {
            if (isConfirm) {
              return Validators.validateConfirmPassword(v, widget.passwordController.text);
            }
            return Validators.validatePassword(v);
          },
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ] : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textHint,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

