import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dihaadi_app/data/models/requirement_model.dart';
import 'package:dihaadi_app/data/services/requirement_service.dart';
import 'package:dihaadi_app/ui/widgets/static_map_preview.dart';
import 'package:dihaadi_app/viewmodels/labour_viewmodel.dart';
import 'package:dihaadi_app/constants/colors.dart';

class JobDetailsScreen extends StatefulWidget {
  final Requirement job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final RequirementService _requirementService = RequirementService();
  Requirement? _detailJob;
  bool _isLoading = true;
  String? _error;

  Requirement get _job => _detailJob ?? widget.job;

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }

  Future<void> _fetchJobDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await _requirementService.getRequirementById(widget.job.id);
      if (!mounted) return;
      setState(() => _detailJob = detail);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    final workTypes =
        job.workTypes.map((e) => e.name).where((e) => e.isNotEmpty).toList();
    final locationParts = [
      if ((job.address ?? '').isNotEmpty) job.address!,
      if ((job.city ?? '').isNotEmpty) job.city!,
      if ((job.state ?? '').isNotEmpty) job.state!,
      if ((job.pincode ?? '').isNotEmpty) job.pincode!,
      if ((job.country ?? '').isNotEmpty) job.country!,
    ];
    final fullLocation = locationParts.join(', ');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Details'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchJobDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const LinearProgressIndicator(minHeight: 2),
            if (_error != null && _detailJob == null) ...[
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
                  'Unable to load latest job details. Showing saved job info.',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
            if (job.images.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  job.images.first,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Job Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  if (workTypes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: workTypes
                          .map(
                            (name) => Chip(
                              label: Text(name),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Job Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Salary',
                    value: job.salary != null
                        ? 'Rs ${job.salary!.toStringAsFixed(0)}${_salarySuffix(job.salaryPeriod)}'
                        : 'Negotiable',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailCard(
                    icon: Icons.group_outlined,
                    title: 'Workers Needed',
                    value: '${job.personNeed ?? 0}',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Location Card
            if (fullLocation.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fullLocation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMain,
                      ),
                    ),
                    if (job.latitude != null && job.longitude != null) ...[
                      const SizedBox(height: 12),
                      StaticMapPreview(
                        latitude: job.latitude!,
                        longitude: job.longitude!,
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Time & Gender Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Job Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (job.dutyStartTime != null && job.dutyEndTime != null)
                    _buildInfoRow(
                      Icons.access_time,
                      'Duty Time',
                      '${DateFormat('hh:mm a').format(job.dutyStartTime!)} - ${DateFormat('hh:mm a').format(job.dutyEndTime!)}',
                    ),
                  if (job.personNeed != null && job.personNeed! > 0)
                    _buildInfoRow(
                      Icons.people_outline,
                      'Total Workers',
                      '${job.personNeed}',
                    ),
                  if (job.maleCount > 0)
                    _buildInfoRow(
                      Icons.male,
                      'Male Workers',
                      '${job.maleCount}',
                    ),
                  if (job.femaleCount > 0)
                    _buildInfoRow(
                      Icons.female,
                      'Female Workers',
                      '${job.femaleCount}',
                    ),
                  if (job.date != null)
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'Posted Date',
                      DateFormat('dd MMM yyyy').format(job.date!.toLocal()),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final success =
                      await context.read<LabourViewModel>().applyForJob(job.id);
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Application submitted!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to apply'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.send, size: 20),
                label: const Text(
                  'Apply Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _salarySuffix(String? salaryPeriod) {
    if (salaryPeriod == null || salaryPeriod.isEmpty) return '/day';
    final value = salaryPeriod.toLowerCase();
    if (value.startsWith('/')) return salaryPeriod;
    if (value == 'daily' || value == 'day') return '/day';
    if (value == 'weekly' || value == 'week') return '/week';
    if (value == 'monthly' || value == 'month') return '/month';
    return '/$salaryPeriod';
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
