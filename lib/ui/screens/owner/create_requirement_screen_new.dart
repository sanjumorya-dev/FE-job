import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/data/models/requirement_model.dart';
import 'package:dihaadi_app/data/models/work_type_model.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:dihaadi_app/data/services/work_type_service.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:intl/intl.dart';

class CreateRequirementScreen extends StatefulWidget {
  const CreateRequirementScreen({super.key});

  @override
  State<CreateRequirementScreen> createState() =>
      _CreateRequirementScreenState();
}

class _CreateRequirementScreenState extends State<CreateRequirementScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkTypeService _workTypeService = WorkTypeService();

  // Controllers
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final salaryController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController();

  // State
  List<String> selectedWorkTypeIds = [];
  List<WorkType> workTypes = [];
  int personNeed = 1;
  int maleCount = 0;
  int femaleCount = 0;
  DateTime? dutyStartTime;
  DateTime? dutyEndTime;
  bool _isLoading = false;
  bool _isLoadingWorkTypes = true;
  String? _workTypeError;

  @override
  void initState() {
    super.initState();
    _loadWorkTypes();
  }

  Future<void> _loadWorkTypes() async {
    try {
      final types = await _workTypeService.getWorkTypes();
      setState(() {
        workTypes = types;
        _isLoadingWorkTypes = false;
        // Set first work type as default if available
        if (workTypes.isNotEmpty) {
          selectedWorkTypeIds = [workTypes[0].id];
        }
      });
    } catch (e) {
      setState(() {
        _workTypeError = e.toString();
        _isLoadingWorkTypes = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    salaryController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          dutyStartTime = picked;
        } else {
          dutyEndTime = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedWorkTypeIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a work type")));
        return;
      }

      if (dutyStartTime == null || dutyEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select start and end dates")));
        return;
      }

      setState(() => _isLoading = true);

      final request = CreateRequirementRequest(
        workTypeIds: selectedWorkTypeIds,
        title: titleController.text.trim(),
        description: descController.text.trim(),
        personNeed: personNeed,
        maleCount: maleCount,
        femaleCount: femaleCount,
        dutyStartTime: dutyStartTime,
        dutyEndTime: dutyEndTime,
        salary: double.tryParse(salaryController.text),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        city: cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),
        state: stateController.text.trim().isEmpty
            ? null
            : stateController.text.trim(),
        pincode: pincodeController.text.trim().isEmpty
            ? null
            : pincodeController.text.trim(),
        country: countryController.text.trim().isEmpty
            ? null
            : countryController.text.trim(),
      );

      final success =
          await context.read<OwnerViewModel>().createRequirement(request);
      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Requirement Created!")));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.read<OwnerViewModel>().error ??
                "Failed to create requirement")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Requirement")),
      body: _isLoadingWorkTypes
          ? const Center(child: CircularProgressIndicator())
          : _workTypeError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text("Error loading work types: $_workTypeError"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadWorkTypes,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Work Type Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedWorkTypeIds.isNotEmpty ? selectedWorkTypeIds.first : null,
                          decoration: const InputDecoration(
                            labelText: "Work Type",
                            border: OutlineInputBorder(),
                          ),
                          items: workTypes
                              .map((e) => DropdownMenuItem(
                                  value: e.id, child: Text(e.name)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedWorkTypeIds = v == null ? [] : [v]),
                          validator: (v) =>
                              v == null ? "Please select a work type" : null,
                        ),
                        const SizedBox(height: 16),

                        // Title
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: "Job Title",
                            hintText: "e.g. Site Supervisor",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Title is required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (v) =>
                              v!.isEmpty ? "Description is required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Salary
                        TextFormField(
                          controller: salaryController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Salary (₹)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Location Section
                        const Text(
                          "Location Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Address
                        TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: "Address",
                            hintText: "Street address",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // City and State
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: cityController,
                                decoration: const InputDecoration(
                                  labelText: "City",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: stateController,
                                decoration: const InputDecoration(
                                  labelText: "State",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Pincode and Country
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: pincodeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Pincode",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: countryController,
                                decoration: const InputDecoration(
                                  labelText: "Country",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // People Requirements
                        const Text(
                          "People Requirements",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Total Needed
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Needed"),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => setState(() =>
                                      personNeed > 1 ? personNeed-- : null),
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  "$personNeed",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(() => personNeed++),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Male Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Male"),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => setState(
                                      () => maleCount > 0 ? maleCount-- : null),
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  "$maleCount",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(() {
                                    if (maleCount + femaleCount < personNeed) {
                                      maleCount++;
                                    }
                                  }),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Female Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Female"),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => setState(() =>
                                      femaleCount > 0 ? femaleCount-- : null),
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  "$femaleCount",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(() {
                                    if (maleCount + femaleCount < personNeed) {
                                      femaleCount++;
                                    }
                                  }),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Duty Duration
                        const Text(
                          "Duty Duration",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context, true),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: "Start Date",
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    dutyStartTime != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(dutyStartTime!)
                                        : "Select",
                                    style: TextStyle(
                                      color: dutyStartTime != null
                                          ? AppColors.textMain
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context, false),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: "End Date",
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    dutyEndTime != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(dutyEndTime!)
                                        : "Select",
                                    style: TextStyle(
                                      color: dutyEndTime != null
                                          ? AppColors.textMain
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Create Requirement",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
