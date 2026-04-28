import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/data/models/notification_model.dart' as app;
import 'package:dihaadi_app/data/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isOwner;
  const NotificationsScreen({super.key, this.isOwner = false});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<app.Notification> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _service.getNotifications();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(app.Notification item) async {
    if (item.isRead) return;
    try {
      await _service.markNotificationAsRead(item.id);
      if (!mounted) return;
      setState(() {
        final index = _items.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          final current = _items[index];
          _items[index] = app.Notification(
            id: current.id,
            title: current.title,
            body: current.body,
            type: current.type,
            isRead: true,
            createdAt: current.createdAt,
            referenceId: current.referenceId,
          );
        }
      });
    } catch (_) {
      // Keep the notification visible; read state can refresh next pull.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: ListView(
          children: [
            const SizedBox(height: 180),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load notifications',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: _items.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 180),
                Center(child: Text('No notifications yet')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _NotificationTile(
                  item: item,
                  onTap: () => _markAsRead(item),
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final app.Notification item;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : AppColors.primary.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconFor(item.type), size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(app.NotificationType type) {
    return switch (type) {
      app.NotificationType.applicationAccepted => Icons.check_circle_outline,
      app.NotificationType.applicationRejected => Icons.cancel_outlined,
      app.NotificationType.newApplicant => Icons.people_outline,
      app.NotificationType.newJob => Icons.work_outline,
      app.NotificationType.requirementCompleted => Icons.task_alt,
      app.NotificationType.ratingReceived => Icons.star_border_rounded,
      app.NotificationType.system => Icons.info_outline,
      app.NotificationType.unknown => Icons.notifications_none,
    };
  }
}
