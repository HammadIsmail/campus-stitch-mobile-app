import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api/api_constants.dart';
import '../core/storage/session_store.dart';
import '../models/notification_model.dart';

class NotificationService {
  /// Fetch notifications for the user on their campus
  static Future<List<NotificationItemModel>> getNotifications({
    required String campusId,
    String filter = 'All',
  }) async {
    try {
      final user = await SessionStore.getUser();
      final uri = Uri.parse(
        '${ApiConstants.notifications}?campus_id=$campusId&userId=${user?.id ?? ""}&filter=$filter',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['notifications'] is List) {
          final items = (body['notifications'] as List)
              .map((n) => NotificationItemModel.fromJson(n))
              .toList();

          // Organize into Today and Earlier heads
          _organizeNotificationHeads(items);
          return items;
        }
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
    return [];
  }

  /// Mark single notification as read
  static Future<bool> markAsRead(String id, {required String campusId}) async {
    try {
      final res = await http.patch(
        Uri.parse(ApiConstants.notifications),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'campus_id': campusId,
        }),
      ).timeout(const Duration(seconds: 6));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead({required String campusId}) async {
    try {
      final user = await SessionStore.getUser();
      final res = await http.patch(
        Uri.parse(ApiConstants.notifications),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'campus_id': campusId,
          'user_id': user?.id,
          'all': true,
        }),
      ).timeout(const Duration(seconds: 6));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  static void _organizeNotificationHeads(List<NotificationItemModel> list) {
    bool foundToday = false;
    bool foundEarlier = false;

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      final isToday = item.time.endsWith('m') ||
          item.time.endsWith('h') ||
          item.time.toLowerCase() == 'today';

      if (isToday) {
        if (!foundToday) {
          list[i] = NotificationItemModel(
            id: item.id,
            campusId: item.campusId,
            type: item.type,
            title: item.title,
            body: item.body,
            time: item.time,
            createdAt: item.createdAt,
            read: item.read,
            deeplink: item.deeplink,
            cta: item.cta,
            head: 'Today',
            metadata: item.metadata,
          );
          foundToday = true;
        }
      } else {
        if (!foundEarlier) {
          list[i] = NotificationItemModel(
            id: item.id,
            campusId: item.campusId,
            type: item.type,
            title: item.title,
            body: item.body,
            time: item.time,
            createdAt: item.createdAt,
            read: item.read,
            deeplink: item.deeplink,
            cta: item.cta,
            head: 'Earlier',
            metadata: item.metadata,
          );
          foundEarlier = true;
        }
      }
    }
  }
}
