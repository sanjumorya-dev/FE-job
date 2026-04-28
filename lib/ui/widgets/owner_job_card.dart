import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/requirement_model.dart';

class OwnerJobCard extends StatelessWidget {
  final Requirement requirement;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const OwnerJobCard({
    super.key,
    required this.requirement,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        requirement.title.isEmpty
                            ? 'Untitled job'
                            : requirement.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF171A22),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StatusPill(label: _statusLabel()),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Color(0xFF7B8494),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        _shortLocation(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF697386),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.payments_outlined,
                        label: 'Salary',
                        value: _salaryText(),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.people_alt_outlined,
                        label: 'Needed',
                        value: '${requirement.personNeed ?? 0} persons',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Duration',
                        value: _formatDateRange(),
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: _InfoTile(
                        icon: Icons.watch_later_outlined,
                        label: 'Applications',
                        value: '1 pending',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                height: 30,
                width: 80,
                child: Stack(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Positioned(
                        left: i * 14,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _avatarColor(i),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            i == 2 ? '+3' : '',
                            style: const TextStyle(
                              color: Color(0xFF697386),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 13),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF171A22),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE9EDF3)),
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility_outlined, size: 13),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171A22),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel() {
    if (requirement.status == 1) return 'Pending';
    if (requirement.status == 2) return 'Draft';
    return 'Active';
  }

  String _formatDateRange() {
    if (requirement.dutyStartTime == null || requirement.dutyEndTime == null) {
      return 'Date TBD';
    }
    final startFormat = DateFormat('d MMM').format(requirement.dutyStartTime!);
    final endFormat = DateFormat('d MMM').format(requirement.dutyEndTime!);
    return '$startFormat - $endFormat';
  }

  String _salaryText() {
    final salary = requirement.salary?.toStringAsFixed(0) ?? '0';
    final period = requirement.salaryPeriod?.trim().toLowerCase();
    final suffix =
        period == null || period.isEmpty || period == 'daily' ? 'day' : period;
    return '₹$salary $suffix';
  }

  String _shortLocation() {
    final parts = [
      if ((requirement.city ?? '').trim().isNotEmpty) requirement.city!.trim(),
      if ((requirement.state ?? '').trim().isNotEmpty)
        requirement.state!.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    return requirement.address?.trim().isNotEmpty == true
        ? requirement.address!.trim()
        : 'Location TBD';
  }

  Color _avatarColor(int index) {
    const colors = [
      Color(0xFFD8E1EC),
      Color(0xFFC7D8C7),
      Color(0xFFF1F3F6),
    ];
    return colors[index % colors.length];
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7D8798),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF7E8798)),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7E8798),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF171A22),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
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
