class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? text;
  final String? voiceUrl;
  final String? duration; // e.g. "0:12"
  final List<double> waveformPeaks;
  final DateTime createdAt;
  final bool isMe;
  final String status; // 'sent', 'sending', 'failed'

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.text,
    this.voiceUrl,
    this.duration,
    this.waveformPeaks = const [],
    required this.createdAt,
    required this.isMe,
    this.status = 'sent',
  });

  bool get isVoice => voiceUrl != null && voiceUrl!.isNotEmpty;

  String get timeFormatted {
    final local = createdAt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:$minute $period';
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json['sender_id']?.toString() ?? '';
    final isMe = currentUserId != null
        ? senderId == currentUserId
        : (json['is_me'] == true || senderId == 'u_me');

    List<double> peaks = [];
    if (json['waveform_peaks'] is List) {
      peaks = (json['waveform_peaks'] as List)
          .map((v) => (v is num) ? v.toDouble() : 0.5)
          .toList();
    }

    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: senderId,
      senderName: json['sender_name']?.toString() ?? 'Student',
      text: json['text']?.toString(),
      voiceUrl: () {
        String? v = json['voice_url']?.toString();
        if (v == null || v.isEmpty) return null;
        if (v.startsWith('blob%3A') || v.startsWith('blob%3a')) {
          v = 'blob:${v.substring(7)}';
        }
        try {
          return Uri.decodeFull(v);
        } catch (_) {
          return v;
        }
      }(),
      duration: json['duration']?.toString(),
      waveformPeaks: peaks,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      isMe: isMe,
      status: json['status']?.toString() ?? 'sent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'text': text,
      'voice_url': voiceUrl,
      'duration': duration,
      'waveform_peaks': waveformPeaks,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}

class ConversationModel {
  final String id;
  final String contactId;
  final String contactName;
  final String contextType; // 'bike', 'market', 'roommate', 'service', 'general'
  final String? contextId;
  final String contextTitle;
  final String? contextSubtitle;
  final String lastMessage;
  final String lastTime;
  int unreadCount;
  final String campusId;
  final List<ChatMessageModel> messages;

  String get timeFormatted {
    if (lastTime.isEmpty || lastTime == 'Just now') return 'Just now';
    try {
      final dt = DateTime.tryParse(lastTime)?.toLocal();
      if (dt == null) return lastTime;
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) {
        return 'Just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24 && dt.day == now.day) {
        final hour = dt.hour;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$h12:$minute $period';
      } else if (diff.inDays < 7) {
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (_) {
      return lastTime;
    }
  }

  ConversationModel({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.contextType,
    this.contextId,
    required this.contextTitle,
    this.contextSubtitle,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    required this.campusId,
    this.messages = const [],
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final user1 = json['user_id_1']?.toString() ?? '';
    final user2 = json['user_id_2']?.toString() ?? '';
    final contactId = (currentUserId != null && currentUserId == user1) ? user2 : user1;

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      contactId: contactId.isNotEmpty ? contactId : (json['contact_id']?.toString() ?? 'u_peer'),
      contactName: json['contact_name']?.toString() ?? 'Campus Peer',
      contextType: json['context_type']?.toString() ?? 'general',
      contextId: json['context_id']?.toString(),
      contextTitle: json['context_title']?.toString() ?? 'Discussion',
      contextSubtitle: json['context_subtitle']?.toString(),
      lastMessage: json['last_message']?.toString() ?? '',
      lastTime: json['last_time']?.toString() ?? 'Just now',
      unreadCount: json['unread_count'] is int ? json['unread_count'] : 0,
      campusId: json['campus_id']?.toString() ?? '',
      messages: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contact_id': contactId,
      'contact_name': contactName,
      'context_type': contextType,
      'context_id': contextId,
      'context_title': contextTitle,
      'context_subtitle': contextSubtitle,
      'last_message': lastMessage,
      'last_time': lastTime,
      'unread_count': unreadCount,
      'campus_id': campusId,
    };
  }
}
