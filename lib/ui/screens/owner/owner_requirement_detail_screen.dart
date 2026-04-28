import 'package:flutter/material.dart';
import 'package:dihaadi_app/data/models/requirement_model.dart';
import 'package:dihaadi_app/data/services/requirement_service.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/screens/owner/edit_requirement_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_applications_screen.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OwnerRequirementDetailScreen extends StatefulWidget {
  final Requirement requirement;
  const OwnerRequirementDetailScreen({super.key, required this.requirement});

  @override
  State<OwnerRequirementDetailScreen> createState() =>
      _OwnerRequirementDetailScreenState();
}

class _OwnerRequirementDetailScreenState
    extends State<OwnerRequirementDetailScreen> {
  final RequirementService _requirementService = RequirementService();
  Requirement? _detailRequirement;
  bool _isLoading = true;
  String? _error;

  Requirement get requirement => _detailRequirement ?? widget.requirement;

  @override
  void initState() {
    super.initState();
    _fetchRequirementDetails();
  }

  Future<void> _fetchRequirementDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail =
          await _requirementService.getRequirementById(widget.requirement.id);
      if (!mounted) return;
      setState(() => _detailRequirement = detail);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRequirement = requirement;
    final skillLabels = currentRequirement.workTypes
        .map((workType) => workType.name)
        .where((name) => name.trim().isNotEmpty)
        .toList();
    if (skillLabels.isEmpty) {
      skillLabels.addAll(currentRequirement.workTypeIds);
    }
    final location = _formatLocation(currentRequirement);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Requirement Details'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context);
              } else if (value == 'hold') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hold action coming soon')),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Color(0xFFDD3E3E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'hold',
                child: Text(
                  'Hold',
                  style: TextStyle(
                    color: Color(0xFF171717),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRequirementDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (_error != null && _detailRequirement == null) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: .2),
                    ),
                  ),
                  child: const Text(
                    'Unable to load latest requirement details. Showing saved info.',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF5ED),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _statusText(currentRequirement.status),
                        style: const TextStyle(
                          color: Color(0xFF208F67),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentRequirement.title,
                      style: const TextStyle(
                        fontSize: 30,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      location.isEmpty ? 'Location not shared' : location,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _metricTile(
                    title: 'Wage / Salary',
                    value: _formatSalary(currentRequirement),
                    icon: Icons.currency_rupee_rounded,
                  ),
                  const SizedBox(width: 10),
                  _metricTile(
                    title: 'Workers Needed',
                    value: '${currentRequirement.personNeed ?? 0} People',
                    icon: Icons.group_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _metricTile(
                    title: 'Duration',
                    value: _formatDuration(currentRequirement),
                    icon: Icons.access_time_rounded,
                  ),
                  const SizedBox(width: 10),
                  _metricTile(
                    title: 'Gender Need',
                    value: _formatGenderNeed(currentRequirement),
                    icon: Icons.people_alt_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _sectionCard(
                'Description',
                currentRequirement.description.isEmpty
                    ? 'No description shared'
                    : currentRequirement.description,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Skills',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    if (skillLabels.isEmpty)
                      const Text(
                        'No skills selected',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: skillLabels
                            .map(
                              (label) => _SkillChip(
                                label,
                                backgroundColor: const Color(0xFFDDEEFF),
                                textColor: const Color(0xFF2D6CA2),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location.isEmpty ? 'Location not shared' : location,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCAE7F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.map_rounded,
                        size: 48,
                        color: Color(0xFF6CA6C9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            children: [
              SizedBox(
                height: 48,
                width: 56,
                child: OutlinedButton(
                  onPressed: () => _openEditScreen(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4D9E2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6A7486),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.edit_outlined, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OwnerApplicationsScreen(
                            requirement: currentRequirement,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF101B31),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('View All Applications'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: const Color(0xFF8A92A5)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF8A92A5)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              height: 1.45,
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _openEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditRequirementScreen(requirement: requirement),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Requirement?'),
        content: const Text(
          'This requirement will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    final success = await context
        .read<OwnerViewModel>()
        .deleteRequirement(requirement.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Requirement deleted successfully'
              : context.read<OwnerViewModel>().error ?? 'Delete failed',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  String _formatLocation(Requirement requirement) {
    final parts = [
      requirement.address,
      requirement.city,
      requirement.state,
      requirement.pincode,
      requirement.country,
    ];
    final values = <String>[];
    for (final part in parts) {
      final value = part?.trim();
      if (value != null && value.isNotEmpty && !values.contains(value)) {
        values.add(value);
      }
    }
    return values.join(', ');
  }

  String _formatSalary(Requirement requirement) {
    final salary = requirement.salary;
    if (salary == null) return 'Negotiable';
    return 'Rs ${salary.toStringAsFixed(0)}${_salarySuffix(requirement.salaryPeriod)}';
  }

  String _salarySuffix(String? salaryPeriod) {
    if (salaryPeriod == null || salaryPeriod.trim().isEmpty) return '/day';
    final value = salaryPeriod.trim().toLowerCase();
    if (value.startsWith('/')) return value;
    if (value == 'daily' || value == 'day') return '/day';
    if (value == 'weekly' || value == 'week') return '/week';
    if (value == 'monthly' || value == 'month') return '/month';
    return '/${salaryPeriod.trim()}';
  }

  String _formatDuration(Requirement requirement) {
    final start = requirement.dutyStartTime?.toLocal();
    final end = requirement.dutyEndTime?.toLocal();
    if (start == null || end == null) return 'Not set';

    final sameYear = start.year == end.year;
    final startFormat = DateFormat(sameYear ? 'MMM d' : 'MMM d, yyyy');
    final endFormat = DateFormat('MMM d, yyyy');
    final days = end.difference(start).inDays + 1;
    final dayText = days > 0 ? ' ($days days)' : '';
    return '${startFormat.format(start)} - ${endFormat.format(end)}$dayText';
  }

  String _formatGenderNeed(Requirement requirement) {
    final parts = [
      if (requirement.maleCount > 0) 'M ${requirement.maleCount}',
      if (requirement.femaleCount > 0) 'F ${requirement.femaleCount}',
    ];
    return parts.isEmpty ? 'Any' : parts.join(', ');
  }

  String _statusText(int status) {
    if (status == 1) return 'ON HOLD';
    if (status == 2) return 'COMPLETED';
    return 'ACTIVE / OPEN';
  }
}

class _SkillChip extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _SkillChip(
    this.text, {
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
