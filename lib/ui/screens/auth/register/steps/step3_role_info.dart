import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/data/models/user_model.dart';
import 'package:dihaadi_app/viewmodels/work_type_viewmodel.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/widgets/work_type_dropdown.dart';

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
              "Account Security & Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: widget.passwordController,
              decoration: InputDecoration(
                labelText: "Set Password",
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon:
                    const Icon(Icons.lock, color: AppColors.textSecondary),
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
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              obscureText: true,
              style: const TextStyle(color: AppColors.textMain),
              validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.confirmPasswordController,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppColors.textSecondary),
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
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              obscureText: true,
              style: const TextStyle(color: AppColors.textMain),
              validator: (v) => v != widget.passwordController.text
                  ? "Passwords do not match"
                  : null,
            ),
            const SizedBox(height: 24),
            const Text(
              "Select Your Role",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    title: "Applicant",
                    description: "Looking for jobs",
                    icon: Icons.person_search,
                    isSelected: _selectedRole == UserRole.worker,
                    onTap: () {
                      setState(() => _selectedRole = UserRole.worker);
                      widget.onRoleChanged(UserRole.worker);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleCard(
                    title: "Employer",
                    description: "Looking to hire",
                    icon: Icons.business_center,
                    isSelected: _selectedRole == UserRole.owner,
                    onTap: () {
                      setState(() => _selectedRole = UserRole.owner);
                      widget.onRoleChanged(UserRole.owner);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_selectedRole == UserRole.worker) ...[
              const Text(
                "Select Your Skills / Work Types",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<WorkTypeViewModel>(
                builder: (context, viewModel, child) {
                  final items = viewModel.workTypes
                      .map((workType) => WorkTypeItem(
                            id: workType.id,
                            name: workType.name,
                            description: workType.description,
                          ))
                      .toList();

                  return WorkTypeDropdown(
                    items: items,
                    selectedIds: _selectedWorkTypeIds,
                    onSelected: _toggleWorkType,
                    onRemoved: _toggleWorkType,
                    isLoading: viewModel.isLoading,
                    error: viewModel.error,
                    onRetry: () {
                      context.read<WorkTypeViewModel>().fetchWorkTypes();
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text(
                "Select at least one skill",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
