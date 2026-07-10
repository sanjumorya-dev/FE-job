import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/data/models/applicant_model.dart';
import 'package:dihaadi_app/data/models/chat_model.dart';
import 'package:dihaadi_app/data/models/requirement_model.dart';
import 'package:dihaadi_app/data/services/requirement_service.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_chat_detail_screen.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ApplicantProfileScreen extends StatefulWidget {
  final Applicant applicant;
  final String requirementId;
  final String jobTitle;

  const ApplicantProfileScreen({
    super.key,
    required this.applicant,
    required this.requirementId,
    required this.jobTitle,
  });

  @override
  State<ApplicantProfileScreen> createState() => _ApplicantProfileScreenState();
}

class _ApplicantProfileScreenState extends State<ApplicantProfileScreen> {
  final RequirementService _requirementService = RequirementService();
  Requirement? _requirement;
  bool _isRequirementLoading = false;

  Applicant get applicant => widget.applicant;
  String get requirementId => widget.requirementId;
  String get jobTitle {
    final fetchedTitle = _requirement?.title.trim();
    if (fetchedTitle != null && fetchedTitle.isNotEmpty) return fetchedTitle;
    return widget.jobTitle;
  }

  List<String> get _skillLabels {
    final names = _requirement?.workTypes
            .map((workType) => workType.name.trim())
            .where((name) => name.isNotEmpty)
            .toList() ??
        const <String>[];

    if (names.isNotEmpty) return names;
    return applicant.workTypes.where((workType) => workType.trim().isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchRequirement();
  }

  Future<void> _fetchRequirement() async {
    if (requirementId.trim().isEmpty) return;

    setState(() => _isRequirementLoading = true);
    try {
      final requirement =
          await _requirementService.getRequirementById(requirementId);
      if (!mounted) return;
      setState(() => _requirement = requirement);
    } catch (_) {
      // Keep showing the applicant and passed job title if details fail.
    } finally {
      if (mounted) setState(() => _isRequirementLoading = false);
    }
  }

  void _makeCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${applicant.workerName}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openChat(BuildContext context) {
    final conversation = ChatConversation(
      id: '${applicant.id}_$requirementId',
      participantId: applicant.id,
      participantName: applicant.workerName,
      participantImage: null,
      jobTitle: jobTitle,
      requirementId: requirementId,
      lastMessage: 'Start of conversation',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerChatDetailScreen(conversation: conversation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = applicant.status == ApplicationStatus.accepted;
    final isPending = applicant.status == ApplicationStatus.pending;
    final skillLabels = _skillLabels;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: _TopIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Applicant Details',
          style: TextStyle(
            color: Color(0xFF151924),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 42),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: const _TopIconButton(icon: Icons.more_horiz_rounded),
              onSelected: (value) {
                if (value == 'chat') {
                  _openChat(context);
                } else if (value == 'call') {
                  _makeCall(context);
                }
              },
              itemBuilder: (context) => [
                if (isAccepted)
                  const PopupMenuItem(
                    value: 'chat',
                    child: _MenuAction(icon: Icons.chat, label: 'Send Message'),
                  ),
                if (isAccepted)
                  const PopupMenuItem(
                    value: 'call',
                    child: _MenuAction(icon: Icons.phone, label: 'Make Call'),
                  ),
                if (!isAccepted)
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('No actions available'),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isPending
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 18,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                            color: AppColors.error.withValues(alpha: .28),
                          ),
                          backgroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAcceptDialog(context),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Approve Request'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF07090D),
                          elevation: 0,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : isAccepted
              ? SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    color: AppColors.background,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openChat(context),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF07090D),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _makeCall(context),
                            icon: const Icon(Icons.phone_outlined),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF07090D),
                              backgroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, isPending ? 18 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isRequirementLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              Center(
                child: Column(
                  children: [
                    _ApplicantAvatar(name: applicant.workerName),
                    const SizedBox(height: 12),
                    Text(
                      applicant.workerName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF151924),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${applicant.experienceYears} yrs experience',
                      style: const TextStyle(
                        color: Color(0xFF697386),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StatusPill(
                      text: _getStatusText(applicant.status),
                      color: _getStatusColor(applicant.status),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Experience',
                      value: '${applicant.experienceYears} yrs',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Availability',
                      value: isAccepted ? 'Approved' : 'Immediate',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Application Info'),
              const SizedBox(height: 10),
              _DetailLine(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF21B58E),
                title: 'Applied ${_formatRelativeDate(applicant.appliedDate)}',
                subtitle: 'Application received at ${_formatTime(applicant.appliedDate)} via Mobile App.',
              ),
              const SizedBox(height: 14),
              _DetailLine(
                icon: Icons.work_outline_rounded,
                iconColor: AppColors.primary,
                title: 'Applied For',
                subtitle: jobTitle.isEmpty ? 'Job request' : jobTitle,
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Personal Info'),
              const SizedBox(height: 10),
              _DetailLine(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF21B58E),
                title: 'Gender',
                subtitle: applicant.gender.isEmpty ? 'Not shared' : applicant.gender,
              ),
              const SizedBox(height: 14),
              _DetailLine(
                icon: Icons.phone_outlined,
                iconColor: AppColors.primary,
                title: 'Mobile Number',
                subtitle: applicant.mobileNumber.isEmpty
                    ? 'Not shared'
                    : applicant.mobileNumber,
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Skills & Expertise'),
              const SizedBox(height: 12),
              if (skillLabels.isEmpty)
                const Text(
                  'No skills shared',
                  style: TextStyle(
                    color: Color(0xFF687386),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      skillLabels.map((workType) => _SkillChip(workType)).toList(),
                ),
              const SizedBox(height: 24),
              const _SectionTitle('About Applicant'),
              const SizedBox(height: 10),
              Text(
                _aboutApplicant,
                style: const TextStyle(
                  color: Color(0xFF475266),
                  fontSize: 13,
                  height: 1.58,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _aboutApplicant {
    final experience = applicant.experienceYears <= 0
        ? 'practical'
        : '${applicant.experienceYears} years of';
    return 'Hardworking individual with $experience experience assisting teams on residential and commercial work. Punctual and ready for physical labour tasks.';
  }

  void _showAcceptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Accept Applicant?'),
        content: const Text(
          'Once accepted, you can chat and call this worker. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<OwnerViewModel>().acceptApplicant(
                    requirementId,
                    applicant.id,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Applicant accepted!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07090D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Applicant?'),
        content: const Text('Are you sure you want to reject this applicant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<OwnerViewModel>().rejectApplicant(
                    requirementId,
                    applicant.id,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Applicant rejected'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return const Color(0xFFE1A100);
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending Review';
      case ApplicationStatus.accepted:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final localDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(localDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return 'on ${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 17, color: const Color(0xFF202633)),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: child,
    );
  }
}

class _ApplicantAvatar extends StatelessWidget {
  final String name;

  const _ApplicantAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF7F8FA),
          border: Border.all(color: const Color(0xFFE5E8EE)),
        ),
        alignment: Alignment.center,
        child: Text(
          initials.isEmpty ? 'A' : initials,
          style: const TextStyle(
            color: Color(0xFF151924),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusPill({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEFF1F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A8394),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF151924),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF151924),
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _DetailLine({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF151924),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF687386),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF586274),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuAction({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}
