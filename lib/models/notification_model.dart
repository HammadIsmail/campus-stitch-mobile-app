class NotificationItemModel {
  final String id;
  final String campusId;
  final String type; // 'chat', 'voice', 'bike_request', 'bike_booked', 'market_request', 'market_sold', 'roommate_reply', 'rating_prompt', 'new_rating'
  final String title;
  final String body;
  final String time;
  final DateTime createdAt;
  bool read;
  final String? deeplink;
  final String? cta;
  final String? head; // 'Today' or 'Earlier'
  final Map<String, dynamic>? metadata;

  NotificationItemModel({
    required this.id,
    required this.campusId,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.createdAt,
    this.read = false,
    this.deeplink,
    this.cta,
    this.head,
    this.metadata,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    DateTime created = DateTime.now();
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    final diff = DateTime.now().difference(created);
    String timeFormatted = json['time']?.toString() ?? '';
    if (timeFormatted.isEmpty) {
      if (diff.inMinutes < 60) {
        timeFormatted = '${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        timeFormatted = '${diff.inHours}h';
      } else if (diff.inDays == 1) {
        timeFormatted = 'Yesterday';
      } else {
        timeFormatted = '${diff.inDays} days';
      }
    }

    return NotificationItemModel(
      id: json['id']?.toString() ?? '',
      campusId: json['campus_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'chat',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      time: timeFormatted,
      createdAt: created,
      read: json['read'] == true,
      deeplink: json['deeplink']?.toString(),
      cta: json['cta']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campus_id': campusId,
      'type': type,
      'title': title,
      'body': body,
      'time': time,
      'created_at': createdAt.toIso8601String(),
      'read': read,
      'deeplink': deeplink,
      'cta': cta,
      'metadata': metadata,
    };
  }
}
