import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/data/models/applicant_model.dart';
import 'package:dihaadi_app/data/models/requirement_model.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:dihaadi_app/ui/screens/owner/applicant_profile_screen.dart';

class OwnerApplicationsScreen extends StatefulWidget {
  final Requirement requirement;
  const OwnerApplicationsScreen({super.key, required this.requirement});

  @override
  State<OwnerApplicationsScreen> createState() =>
      _OwnerApplicationsScreenState();
}

class _OwnerApplicationsScreenState extends State<OwnerApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OwnerViewModel>()
          .fetchApplicantsForRequirement(widget.requirement.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Requests'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Consumer<OwnerViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pending = vm.applicants
              .where((a) => a.status == ApplicationStatus.pending)
              .toList();
          final history = vm.applicants
              .where((a) => a.status != ApplicationStatus.pending)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101B31),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Pending Requests (${pending.length})',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5DBE6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'History',
                          style: TextStyle(
                            color: Color(0xFF687087),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
                  children: [
                    const Text('Today',
                        style: TextStyle(
                            color: Color(0xFF7A8295),
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                    const SizedBox(height: 8),
                    ...pending.map((a) => _ApplicantCard(
                          applicant: a,
                          salaryText:
                              '₹ ${(widget.requirement.salary ?? 0).toStringAsFixed(0)} / day',
                          jobTitle: widget.requirement.title,
                          requirementId: widget.requirement.id,
                          onApprove: () =>
                              vm.acceptApplicant(widget.requirement.id, a.id),
                          onReject: () =>
                              vm.rejectApplicant(widget.requirement.id, a.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ApplicantProfileScreen(
                                  applicant: a,
                                  requirementId: widget.requirement.id,
                                  jobTitle: widget.requirement.title,
                                ),
                              ),
                            );
                          },
                        )),
                    const SizedBox(height: 14),
                    const Text('History',
                        style: TextStyle(
                            color: Color(0xFF7A8295),
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                    const SizedBox(height: 8),
                    ...history.map((a) => _ApplicantCard(
                          applicant: a,
                          salaryText:
                              '₹ ${(widget.requirement.salary ?? 0).toStringAsFixed(0)} / day',
                          jobTitle: widget.requirement.title,
                          requirementId: widget.requirement.id,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ApplicantProfileScreen(
                                  applicant: a,
                                  requirementId: widget.requirement.id,
                                  jobTitle: widget.requirement.title,
                                ),
                              ),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Applicant applicant;
  final String salaryText;
  final String jobTitle;
  final String requirementId;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const _ApplicantCard({
    required this.applicant,
    required this.salaryText,
    required this.jobTitle,
    required this.requirementId,
    this.onApprove,
    this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = applicant.status == ApplicationStatus.pending;
    final isApproved = applicant.status == ApplicationStatus.accepted;

    final statusColor = isPending
        ? const Color(0xFFF8E9A9)
        : isApproved
            ? const Color(0xFFCDF2DB)
            : const Color(0xFFF6D0CF);
    final statusTextColor = isPending
        ? const Color(0xFF8B7400)
        : isApproved
            ? const Color(0xFF1F7F57)
            : const Color(0xFFAD3430);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 16, child: Icon(Icons.person, size: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(applicant.workerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                              fontSize: 14)),
                      Text(
                          'Service Technician · ${applicant.experienceYears} yrs exp',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isPending
                        ? 'Pending'
                        : isApproved
                            ? 'Approved'
                            : 'Rejected',
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    salaryText,
                    style: const TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
                Text(
                  _formatTime(applicant.appliedDate),
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 6,
              children: [
                _MiniChip('Wiring'),
                _MiniChip('Drilling'),
                _MiniChip('Configuration'),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD2D8E4)),
                      minimumSize: const Size(74, 30),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Reject',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF5A647B))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF101B31),
                      minimumSize: const Size(78, 30),
                      padding: EdgeInsets.zero,
                    ),
                    child:
                        const Text('Approve', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final m = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }
}

class _MiniChip extends StatelessWidget {
  final String text;
  const _MiniChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF5C7193),
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
