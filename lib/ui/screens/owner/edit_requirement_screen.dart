import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/data/models/requirement_model.dart';
import 'package:dihaadi_app/data/models/work_type_model.dart';
import 'package:dihaadi_app/data/services/common_service.dart';
import 'package:dihaadi_app/data/services/work_type_service.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';

class EditRequirementScreen extends StatefulWidget {
  final Requirement requirement;

  const EditRequirementScreen({super.key, required this.requirement});

  @override
  State<EditRequirementScreen> createState() => _EditRequirementScreenState();
}

class _EditRequirementScreenState extends State<EditRequirementScreen> {
  final WorkTypeService _workTypeService = WorkTypeService();
  final CommonService _commonService = CommonService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _salaryController;
  late final TextEditingController _addressController;

  String? _city;
  String? _state;
  String? _pincode;
  String? _country;
  late int _personNeed;
  late int _maleCount;
  late int _femaleCount;
  DateTime? _dutyStartTime;
  DateTime? _dutyEndTime;

  List<WorkType> _workTypes = [];
  List<PlacePrediction> _placePredictions = [];
  List<String> _selectedWorkTypeIds = [];
  bool _isLoadingWorkTypes = true;
  bool _isSearchingPlaces = false;
  bool _showPredictions = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.requirement.title);
    _descriptionController =
        TextEditingController(text: widget.requirement.description);
    _salaryController =
        TextEditingController(text: widget.requirement.salary?.toString() ?? '');
    _addressController =
        TextEditingController(text: widget.requirement.address ?? '');

    _city = widget.requirement.city;
    _state = widget.requirement.state;
    _pincode = widget.requirement.pincode;
    _country = widget.requirement.country;
    _personNeed = widget.requirement.personNeed ?? 1;
    _maleCount = widget.requirement.maleCount;
    _femaleCount = widget.requirement.femaleCount;
    _dutyStartTime = widget.requirement.dutyStartTime;
    _dutyEndTime = widget.requirement.dutyEndTime;
    _selectedWorkTypeIds =
        widget.requirement.workTypeIds.where((id) => id.trim().isNotEmpty).toList();
    _loadWorkTypes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadWorkTypes() async {
    try {
      final types = await _workTypeService.getWorkTypes();
      if (!mounted) return;

      final selectedNames = widget.requirement.workTypes
          .map((workType) => workType.name.trim().toLowerCase())
          .where((name) => name.isNotEmpty)
          .toSet();

      setState(() {
        _workTypes = types;
        if (_selectedWorkTypeIds.isEmpty && selectedNames.isNotEmpty) {
          _selectedWorkTypeIds = types
              .where(
                (type) => selectedNames.contains(type.name.trim().toLowerCase()),
              )
              .map((type) => type.id)
              .where((id) => id.trim().isNotEmpty)
              .toList();
        }
        _isLoadingWorkTypes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingWorkTypes = false);
    }
  }

  void _searchPlaces(String input) {
    _searchDebounce?.cancel();

    if (input.trim().length < 3) {
      setState(() {
        _placePredictions = [];
        _showPredictions = false;
        _isSearchingPlaces = false;
      });
      return;
    }

    setState(() => _isSearchingPlaces = true);
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final predictions = await _commonService.searchPlaces(input.trim());
        if (!mounted) return;
        setState(() {
          _placePredictions = predictions;
          _showPredictions = predictions.isNotEmpty;
          _isSearchingPlaces = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _placePredictions = [];
          _showPredictions = false;
          _isSearchingPlaces = false;
        });
      }
    });
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _showPredictions = false;
      _placePredictions = [];
      _addressController.text = prediction.description;
      _isSearchingPlaces = true;
    });

    try {
      final details = await _commonService.getPlaceDetails(prediction.placeId);
      if (!mounted) return;
      setState(() {
        if (details.formattedAddress.trim().isNotEmpty) {
          _addressController.text = details.formattedAddress.trim();
        }
        _city = _addressComponent(details, 'locality') ?? _city;
        _state = _addressComponent(
              details,
              'administrative_area_level_1',
              preferShortName: true,
            ) ??
            _state;
        _pincode = _addressComponent(details, 'postal_code') ?? _pincode;
        _country = _addressComponent(
              details,
              'country',
              preferShortName: true,
            ) ??
            _country;
        _isSearchingPlaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingPlaces = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load selected address details'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _addressComponent(
    PlaceDetails details,
    String type, {
    bool preferShortName = false,
  }) {
    for (final component in details.addressComponents) {
      if (!component.types.contains(type)) continue;
      final preferred = preferShortName ? component.shortName : component.longName;
      final fallback = preferShortName ? component.longName : component.shortName;
      if (preferred.trim().isNotEmpty) return preferred.trim();
      if (fallback.trim().isNotEmpty) return fallback.trim();
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final current = isStart ? _dutyStartTime : _dutyEndTime;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _dutyStartTime = picked;
        if (_dutyEndTime != null && _dutyEndTime!.isBefore(picked)) {
          _dutyEndTime = picked;
        }
      } else {
        _dutyEndTime = picked;
      }
    });
  }

  Future<void> _updateRequirement() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWorkTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one work type'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_dutyStartTime == null || _dutyEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select duty start and end date'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final request = CreateRequirementRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      workTypeIds: _selectedWorkTypeIds,
      personNeed: _personNeed,
      maleCount: _maleCount,
      femaleCount: _femaleCount,
      dutyStartTime: _dutyStartTime,
      dutyEndTime: _dutyEndTime,
      salaryPeriod: widget.requirement.salaryPeriod ?? 'Daily',
      salary: double.tryParse(_salaryController.text.trim()),
      address: _addressController.text.trim(),
      city: _city,
      state: _state,
      pincode: _pincode,
      country: _country,
      status: widget.requirement.status,
      date: widget.requirement.date,
    );

    final success = await context.read<OwnerViewModel>().updateRequirement(
          widget.requirement.id,
          request,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Requirement updated successfully'
              : context.read<OwnerViewModel>().error ?? 'Update failed',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildIntroBanner(),
                const SizedBox(height: 30),
                _buildSectionHeader('Basic details', 'Required'),
                const SizedBox(height: 12),
                _buildBasicDetailsSection(),
                const SizedBox(height: 30),
                _buildSectionHeader('Job info', 'Update form'),
                const SizedBox(height: 12),
                _buildJobInfoSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Owner workspace',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9AA1B4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Edit Requirement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update requirement in\none clean form',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F3A50),
              height: 1.2,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Keep job info, worker count, dates, and site details current.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6D7487),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F3A50),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9AA1B4),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildBasicDetailsSection() {
    return Column(
      children: [
        _buildWorkTypeSelector(),
        const SizedBox(height: 12),
        _buildTextBox(
          label: 'Job title',
          controller: _titleController,
          hint: 'Enter job title',
          validator: (value) => value!.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 12),
        _buildTextBox(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Describe the work, site condition, tools, timing, and expectations.',
          maxLines: null,
          validator: (value) => value!.isEmpty ? 'Description is required' : null,
        ),
      ],
    );
  }

  Widget _buildWorkTypeSelector() {
    return _buildInputContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WORK TYPES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textHint,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingWorkTypes)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_workTypes.isEmpty)
            const Text(
              'No work types available',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _workTypes.map((type) {
                final isSelected = _selectedWorkTypeIds.contains(type.id);
                return FilterChip(
                  label: Text(type.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWorkTypeIds.add(type.id);
                      } else {
                        _selectedWorkTypeIds.remove(type.id);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.secondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade200,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextBox({
    required String label,
    required TextEditingController controller,
    required String hint,
    int? maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return _buildInputContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9AA1B4),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF728EAC),
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4A5568),
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfoSection() {
    return Column(
      children: [
        _buildIconInput(
          icon: Icons.currency_rupee,
          label: 'Salary',
          controller: _salaryController,
          hint: 'Enter daily wage in Rs',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Salary is required' : null,
        ),
        const SizedBox(height: 12),
        _buildAddressInput(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCounterBox(
                'Male\nrequired',
                _maleCount,
                Icons.person_outline_rounded,
                (value) => setState(() => _maleCount = value),
                _maleCount + _femaleCount < _personNeed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCounterBox(
                'Female\nrequired',
                _femaleCount,
                Icons.group_outlined,
                (value) => setState(() => _femaleCount = value),
                _maleCount + _femaleCount < _personNeed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCounterBox(
                'Total\nneeded',
                _personNeed,
                Icons.work_outline_rounded,
                (value) {
                  setState(() {
                    _personNeed = value;
                    while (_maleCount + _femaleCount > _personNeed) {
                      if (_femaleCount > 0) {
                        _femaleCount--;
                      } else if (_maleCount > 0) {
                        _maleCount--;
                      } else {
                        break;
                      }
                    }
                  });
                },
                true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateBox(
                'Start date',
                _dutyStartTime,
                () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateBox(
                'End date',
                _dutyEndTime,
                () => _selectDate(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconInput({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return _buildInputContainer(
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF9AA1B4)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9AA1B4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF728EAC),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A5568),
                    fontWeight: FontWeight.bold,
                  ),
                  validator: validator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInput() {
    return _buildInputContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 22,
              color: Color(0xFF9AA1B4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA1B4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_isSearchingPlaces)
                      const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                  ],
                ),
                TextFormField(
                  controller: _addressController,
                  onChanged: _searchPlaces,
                  decoration: const InputDecoration(
                    hintText: 'Add city, area, or full address',
                    hintStyle: TextStyle(
                      color: Color(0xFF728EAC),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                    height: 1.2,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Address is required' : null,
                ),
                if (_showPredictions && _placePredictions.isNotEmpty)
                  _buildAddressPredictions(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.near_me_outlined,
              size: 20,
              color: Color(0xFF9AA1B4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBox(
    String label,
    int value,
    IconData icon,
    ValueChanged<int> onChanged,
    bool canIncrease,
  ) {
    return _buildInputContainer(
      child: Column(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: const Color(0xFF9AA1B4)),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9AA1B4),
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F3A50),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (value > 0) onChanged(value - 1);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 14,
                    color: Color(0xFF2F3A50),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (canIncrease) onChanged(value + 1);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F3A50),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: _buildInputContainer(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9AA1B4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date != null
                        ? DateFormat('dd MMM, yyyy').format(date.toLocal())
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: date != null
                          ? const Color(0xFF2182F3)
                          : const Color(0xFF728EAC),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 36,
              width: 36,
              decoration:
                  const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: Color(0xFF9AA1B4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressPredictions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _placePredictions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final prediction = _placePredictions[index];
          return ListTile(
            dense: true,
            title: Text(
              prediction.mainText.isEmpty
                  ? prediction.description
                  : prediction.mainText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(prediction.secondaryText),
            onTap: () => _selectPlace(prediction),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLoading = context.watch<OwnerViewModel>().isLoading;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : _updateRequirement,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2182F3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Update Requirement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}
