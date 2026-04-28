import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/data/models/chat_model.dart';
import 'package:dihaadi_app/data/services/chat_service.dart';
import 'package:dihaadi_app/ui/screens/labour/worker_chat_detail_screen.dart';

class WorkerChatListScreen extends StatefulWidget {
  const WorkerChatListScreen({super.key});

  @override
  State<WorkerChatListScreen> createState() => _WorkerChatListScreenState();
}

class _WorkerChatListScreenState extends State<WorkerChatListScreen> {
  final ChatService _chatService = ChatService();
  List<ChatConversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final conversations = await _chatService.getConversations();
      if (!mounted) return;
      setState(() => _conversations = conversations);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _WorkerChatSearchDelegate(_conversations),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchConversations,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Center(child: Text('Unable to load conversations')),
          ],
        ),
      );
    }
    if (_conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchConversations,
        child: ListView(
          children: const [SizedBox(height: 180), _WorkerEmptyChatState()],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchConversations,
      child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return _WorkerChatListItem(
                  conversation: conversation,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerChatDetailScreen(
                          conversation: conversation,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _WorkerChatListItem extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const _WorkerChatListItem({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person,
                      size: 32, color: AppColors.textSecondary),
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.participantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: conversation.unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.jobTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: conversation.unreadCount > 0
                                ? AppColors.textMain
                                : AppColors.textSecondary,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final minute = time.minute.toString().padLeft(2, '0');
      final suffix = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $suffix';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

class _WorkerEmptyChatState extends StatelessWidget {
  const _WorkerEmptyChatState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'No Messages Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Messages from employers will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WorkerChatSearchDelegate extends SearchDelegate<String> {
  final List<ChatConversation> conversations;

  _WorkerChatSearchDelegate(this.conversations);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filtered = conversations
        .where((c) =>
            c.participantName.toLowerCase().contains(query.toLowerCase()) ||
            c.jobTitle.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final conversation = filtered[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(conversation.participantName),
          subtitle: Text(conversation.jobTitle),
          onTap: () {
            query = conversation.participantName;
          },
        );
      },
    );
  }
}

