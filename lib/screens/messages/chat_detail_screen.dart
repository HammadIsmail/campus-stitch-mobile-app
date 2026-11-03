import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/sub_header.dart';
import '../../widgets/voice_message_bubble.dart';
import '../../widgets/voice_recorder_bar.dart';
import '../profile/user_profile_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final msgs = await ChatService.getMessages(
      conversationId: widget.conversation.id,
      campusId: widget.conversation.campusId,
    );

    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendTextMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    final user = await SessionStore.getUser();
    final campusId = user?.campusId ?? widget.conversation.campusId;

    // Optimistic append
    final tempMsg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversation.id,
      senderId: user?.id ?? 'u_me',
      senderName: user?.fullName ?? 'You',
      text: text,
      createdAt: DateTime.now(),
      isMe: true,
      status: 'sending',
    );

    setState(() {
      _messages.add(tempMsg);
    });
    _scrollToBottom();

    final sent = await ChatService.sendMessage(
      campusId: campusId,
      conversationId: widget.conversation.id,
      text: text,
      recipientId: widget.conversation.contactId,
      recipientName: widget.conversation.contactName,
      contextType: widget.conversation.contextType,
      contextTitle: widget.conversation.contextTitle,
    );

    if (sent != null && mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == tempMsg.id);
        if (idx != -1) {
          _messages[idx] = sent;
        }
      });
    }
  }

  Future<void> _startVoiceRecording() async {
    final hasPerm = await ChatService.hasMicPermission();
    if (!hasPerm) {
      _showPermissionDeniedDialog();
      return;
    }

    final path = await ChatService.startRecording();
    if (path != null && mounted) {
      setState(() => _isRecording = true);
    } else {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _handleSendVoice(
    String filePath,
    String duration,
    List<double> waveformPeaks,
  ) async {
    setState(() => _isRecording = false);

    final user = await SessionStore.getUser();
    final campusId = user?.campusId ?? widget.conversation.campusId;

    // Optimistic voice bubble
    final tempMsg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversation.id,
      senderId: user?.id ?? 'u_me',
      senderName: user?.fullName ?? 'You',
      voiceUrl: filePath,
      duration: duration,
      waveformPeaks: waveformPeaks,
      createdAt: DateTime.now(),
      isMe: true,
      status: 'sending',
    );

    setState(() {
      _messages.add(tempMsg);
    });
    _scrollToBottom();

    final sent = await ChatService.sendVoiceMessage(
      campusId: campusId,
      conversationId: widget.conversation.id,
      filePath: filePath,
      duration: duration,
      waveformPeaks: waveformPeaks,
      recipientId: widget.conversation.contactId,
      recipientName: widget.conversation.contactName,
      contextType: widget.conversation.contextType,
      contextTitle: widget.conversation.contextTitle,
    );

    if (sent != null && mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == tempMsg.id);
        if (idx != -1) {
          _messages[idx] = sent;
        }
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Microphone Access Needed'),
        content: const Text(
          'Please allow microphone permission in your device settings to record and send voice messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // SubHeader with peer name and context
            SubHeader(
              title: widget.conversation.contactName,
              onBack: () => Navigator.of(context).pop(),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(
                        userName: widget.conversation.contactName,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.textOnSoft,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.user, size: 13, color: colors.textOnSoft),
                    ],
                  ),
                ),
              ),
            ),

            // Context subtitle banner
            if (widget.conversation.contextTitle.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.tag, size: 14, color: colors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Regarding: ${widget.conversation.contextTitle}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Message list
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: colors.primary))
                  : _messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.messageSquare, size: 40, color: colors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'Say hello to ${widget.conversation.contactName}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Send a message or voice note to coordinate.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return _buildMessageItem(msg, colors);
                          },
                        ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: _isRecording
                  ? VoiceRecorderBar(
                      onSendVoice: _handleSendVoice,
                      onCancel: () => setState(() => _isRecording = false),
                      onPermissionDenied: _showPermissionDeniedDialog,
                    )
                  : Row(
                      children: [
                        // Text field
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                              border: Border.all(color: colors.inputBorder),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextField(
                              controller: _textController,
                              style: TextStyle(fontSize: 14, color: colors.textPrimary),
                              maxLines: null,
                              decoration: AppTheme.borderlessInput(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(fontSize: 14, color: colors.textMuted),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _sendTextMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Action button: Voice note or Send text
                        if (_textController.text.trim().isNotEmpty)
                          GestureDetector(
                            onTap: _sendTextMessage,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                LucideIcons.send,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _startVoiceRecording,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                LucideIcons.mic,
                                size: 20,
                                color: colors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessageModel msg, AppColorsExtension colors) {
    final isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: msg.isVoice
            ? VoiceMessageBubble(message: msg, isMe: isMe)
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(
                  color: isMe ? colors.primary : colors.surface,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                  border: isMe ? null : Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.text ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : colors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg.timeFormatted,
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white.withValues(alpha: 0.6) : colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
