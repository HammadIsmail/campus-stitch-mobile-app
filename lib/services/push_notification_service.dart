import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('Handling background notification: ${message.messageId}');
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Call once at app launch or after user authentication
  static Future<void> initialize({String? userId}) async {
    if (_isInitialized) {
      if (userId != null) await syncToken(userId);
      return;
    }

    try {
      // 1. Initialize Firebase Core
      await Firebase.initializeApp();

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Request permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('Push notifications authorized');

        // 4. Setup local notifications for foreground alerts
        await _setupLocalNotifications();

        // 5. Get and sync token
        await syncToken(userId);

        // 6. Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _sendTokenToBackend(newToken, userId);
        });

        // 7. Listen for foreground notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _showForegroundNotification(message);
        });

        // 8. Handle user tapping notification
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('User tapped notification: ${message.data}');
        });

        _isInitialized = true;
      }
    } catch (e) {
      // Gracefully catches if google-services.json is not yet added
      debugPrint('PushNotificationService initialization notice: $e');
    }
  }

  static Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    // Create high importance Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'campus_stitch_high_importance',
      'CampusStitch Notifications',
      description: 'Used for important campus alerts, carpool updates, and messages.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'campus_stitch_high_importance',
      'CampusStitch Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// Fetch FCM Token and register it with the Next.js/Supabase backend
  static Future<String?> syncToken(String? userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Device Token: $token');
        await _sendTokenToBackend(token, userId);
        return token;
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
    return null;
  }

  static Future<void> _sendTokenToBackend(String token, String? userId) async {
    try {
      final body = <String, dynamic>{
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      };
      if (userId != null) {
        body['userId'] = userId;
      }

      await ApiClient.post(
        ApiConstants.pushToken,
        body: body,
      );
    } catch (e) {
      debugPrint('Error syncing push token with backend: $e');
    }
  }
}
