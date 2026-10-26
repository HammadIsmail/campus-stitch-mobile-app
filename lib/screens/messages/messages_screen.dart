import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/public_profile_dialog.dart';
import '../../widgets/verified_student_badge.dart';

class ChatMessage {
  final String id;
  final bool isMe;
  final String text;
  final String time;
  final bool isVoice;

  ChatMessage({
    required this.id,
    required this.isMe,
    required this.text,
    required this.time,
    this.isVoice = false,
  });
}

class ConversationItem {
  final String id;
  final String contactName;
  final bool contactVerified;
  final String roleBadge;
  final String contextTitle;
  final String contextSubtitle;
  final String lastMessage;
  final String lastTime;
  int unreadCount;
  final List<ChatMessage> messages;

  ConversationItem({
    required this.id,
    required this.contactName,
    required this.contactVerified,
    required this.roleBadge,
    required this.contextTitle,
    required this.contextSubtitle,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    required this.messages,
  });
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late List<ConversationItem> _conversations;

  @override
  void initState() {
    super.initState();
    _conversations = [];
  }

  void _openChat(ConversationItem conversation) {
    setState(() {
      conversation.unreadCount = 0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(conversation: conversation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Messages'),
      ),
      body: _conversations.isEmpty
          ? const EmptyStateView(
              icon: Icons.chat_bubble_outline,
              title: 'No Messages Yet',
              message: 'Direct messages with carpool hosts, marketplace sellers, and campus peers will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _conversations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final convo = _conversations[index];

                return InkWell(
                  onTap: () => _openChat(convo),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: convo.unreadCount > 0
                            ? (isDark ? AppColors.white : AppColors.black)
                            : (isDark ? AppColors.zinc800 : AppColors.zinc200),
                        width: convo.unreadCount > 0 ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isDark ? AppColors.zinc800 : AppColors.zinc200,
                          child: Text(
                            convo.contactName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.white : AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            convo.contactName,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (convo.contactVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, size: 14, color: AppColors.success),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    convo.lastTime,
                                    style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Context pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  convo.contextTitle,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.zinc500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                convo.lastMessage,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: convo.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                                  color: convo.unreadCount > 0
                                      ? (isDark ? AppColors.white : AppColors.black)
                                      : (isDark ? AppColors.zinc400 : AppColors.zinc600),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (convo.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.white : AppColors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${convo.unreadCount}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.black : AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final ConversationItem conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      widget.conversation.messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isMe: true,
          text: text,
          time: 'Just now',
        ),
      );
    });

    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            PublicProfileDialog.show(
              context,
              userId: widget.conversation.contactName,
              fallbackName: widget.conversation.contactName,
              fallbackVerified: widget.conversation.contactVerified,
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? AppColors.zinc800 : AppColors.zinc200,
                child: Text(
                  widget.conversation.contactName.isNotEmpty
                      ? widget.conversation.contactName[0].toUpperCase()
                      : 'S',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.conversation.contactName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.conversation.contactVerified) ...[
                          const SizedBox(width: 4),
                          const VerifiedStudentBadge(size: 14),
                        ],
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new, size: 11, color: AppColors.zinc500),
                      ],
                    ),
                    Text(
                      widget.conversation.contextTitle,
                      style: const TextStyle(fontSize: 10, color: AppColors.zinc500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Context bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppColors.zinc900 : AppColors.zinc100,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.zinc500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Campus Context: ${widget.conversation.contextSubtitle}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: widget.conversation.messages.length,
              itemBuilder: (context, index) {
                final msg = widget.conversation.messages[index];
                final isMe = msg.isMe;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? (isDark ? AppColors.white : AppColors.black)
                          : (isDark ? AppColors.darkCard : AppColors.zinc100),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      border: Border.all(
                        color: isMe
                            ? Colors.transparent
                            : (isDark ? AppColors.zinc800 : AppColors.zinc200),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: isMe
                                ? (isDark ? AppColors.black : AppColors.white)
                                : (isDark ? AppColors.white : AppColors.black),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.time,
                          style: TextStyle(
                            fontSize: 9,
                            color: isMe
                                ? (isDark ? AppColors.zinc600 : AppColors.zinc400)
                                : AppColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              border: Border(
                top: BorderSide(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message to peer...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? AppColors.white : AppColors.black,
                      foregroundColor: isDark ? AppColors.black : AppColors.white,
                    ),
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
