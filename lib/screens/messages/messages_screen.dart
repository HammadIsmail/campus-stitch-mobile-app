import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/storage/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/avatar_circle.dart';
import '../../widgets/state_view.dart';
import '../../widgets/sub_header.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ConversationModel> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await SessionStore.getUser();
      final campusId = user?.campusId ?? 'camp_fast_isb';
      final convos = await ChatService.getConversations(campusId: campusId);

      if (mounted) {
        setState(() {
          _conversations = convos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load messages';
          _isLoading = false;
        });
      }
    }
  }

  void _openChat(ConversationModel conversation) {
    setState(() {
      conversation.unreadCount = 0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(conversation: conversation),
      ),
    ).then((_) => _loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Messages',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _buildBody(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppColorsExtension colors) {
    if (_isLoading) {
      return const StateView.loadingList();
    }

    if (_errorMessage != null) {
      return StateView.offline(onRetry: _loadConversations);
    }

    if (_conversations.isEmpty) {
      return StateView.empty(
        title: 'No messages yet',
        body: 'Chats with campus peers for bike rentals, buy requests, or roommates will appear here.',
        icon: LucideIcons.messageSquare,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: colors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _conversations.length,
        separatorBuilder: (_, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final convo = _conversations[index];
          final isUnread = convo.unreadCount > 0;

          return InkWell(
            onTap: () => _openChat(convo),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnread ? colors.primary.withValues(alpha: 0.5) : colors.border,
                  width: isUnread ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  AvatarCircle(
                    name: convo.contactName,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              convo.contactName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              convo.lastTime,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isUnread ? colors.primary : colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        if (convo.contextTitle.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.primarySoft.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              convo.contextTitle,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.textOnSoft,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          convo.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: isUnread ? colors.textPrimary : colors.textMuted,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
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
