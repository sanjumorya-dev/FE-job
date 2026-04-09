import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/screens/labour/worker_chat_list_screen.dart';
import 'package:dihaadi_app/ui/screens/labour/worker_rate_owner_screen.dart';

class WorkerChatDetailScreen extends StatefulWidget {
  final WorkerChatConversation conversation;

  const WorkerChatDetailScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<WorkerChatDetailScreen> createState() => _WorkerChatDetailScreenState();
}

class _WorkerChatDetailScreenState extends State<WorkerChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<WorkerChatMessage> _messages = [
    WorkerChatMessage(
      id: '1',
      text: 'Hi, your application has been accepted!',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: WorkerMessageStatus.read,
    ),
    WorkerChatMessage(
      id: '2',
      text: 'Thank you! When should I start?',
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      status: WorkerMessageStatus.read,
    ),
    WorkerChatMessage(
      id: '3',
      text: 'Please reach the site by 10 AM tomorrow',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      status: WorkerMessageStatus.read,
    ),
  ];

  bool _isJobCompleted = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = WorkerChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageController.text.trim(),
      isSentByMe: true,
      timestamp: DateTime.now(),
      status: WorkerMessageStatus.sent,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _makeCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Initiating call...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showJobCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Job Completed?'),
        content: const Text(
          'Have you completed this job? You can rate the employer after completion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeJob();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _completeJob() {
    setState(() {
      _isJobCompleted = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerRateOwnerScreen(
              ownerName: widget.conversation.ownerName,
              jobTitle: widget.conversation.jobTitle,
            ),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job marked as completed!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 18,
                  child: Icon(Icons.person, size: 20),
                ),
                if (widget.conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.ownerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.conversation.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.conversation.isOnline
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _makeCall,
            tooltip: 'Make Call',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'complete') {
                _showJobCompletionDialog();
              }
            },
            itemBuilder: (context) => [
              if (!_isJobCompleted)
                const PopupMenuItem(
                  value: 'complete',
                  child: Text('Mark Job as Completed'),
                ),
              const PopupMenuItem(
                value: 'block',
                child: Text('Report Issue'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Job Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.work_outline,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.conversation.jobTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (_isJobCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _WorkerMessageBubble(message: message);
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
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

class _WorkerMessageBubble extends StatelessWidget {
  final WorkerChatMessage message;

  const _WorkerMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isSentByMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textMain,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == WorkerMessageStatus.read
                              ? Icons.done_all
                              : Icons.done,
                          size: 14,
                          color: message.status == WorkerMessageStatus.read
                              ? Colors.blue
                              : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class WorkerChatMessage {
  final String id;
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final WorkerMessageStatus status;

  WorkerChatMessage({
    required this.id,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    required this.status,
  });
}

enum WorkerMessageStatus { sent, delivered, read }
