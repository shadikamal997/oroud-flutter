import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  GoRouter? _router;

  /// Initialize notification service and register FCM token
  Future<void> init(Function(String) sendTokenToBackend) async {
    // Request permission for iOS
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the device token
    final token = await _messaging.getToken();

    if (token != null) {
      sendTokenToBackend(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      sendTokenToBackend(newToken);
    });
    
    // Initialize local notifications for foreground display
    await _initLocalNotifications();
  }

  /// Initialize local notifications
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  /// Setup message handlers with navigation support
  void setupMessageHandlers(
    Function(String title, String body) onForegroundMessage,
  ) {
    // Handle foreground messages (show local notification)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        onForegroundMessage(
          notification.title ?? 'New Notification',
          notification.body ?? '',
        );
        
        // Show local notification for foreground messages
        _showLocalNotification(
          notification.title ?? 'New Notification',
          notification.body ?? '',
          message.data,
        );
      }
    });

    // Handle background message taps (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateFromNotification(message.data);
    });
    
    // Check for initial message (app launched from notification)
    _checkInitialMessage();
  }
  
  /// Set router for navigation
  void setRouter(GoRouter router) {
    _router = router;
  }

  /// Show local notification (for foreground messages)
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'oroud_channel',
      'Oroud Notifications',
      channelDescription: 'Notifications from Oroud app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: jsonEncode(data),
    );
  }

  /// Handle notification tap (local notification)
  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _navigateFromNotification(data);
    }
  }

  /// Check for initial message (app launched from notification)
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromNotification(initialMessage.data);
    }
  }

  /// Navigate based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    if (_router == null) {
      print('❌ Router not initialized for notification navigation');
      return;
    }

    final type = data['type'] as String?;
    final offerId = data['offerId'] as String?;
    final shopId = data['shopId'] as String?;

    print('🧭 Navigation from notification: type=$type, offerId=$offerId, shopId=$shopId');

    switch (type) {
      case 'new_offer':
      case 'offer_expiring':
        if (offerId != null) {
          _router!.go('/offer/$offerId');
        }
        break;

      case 'shop_verified':
      case 'new_review':
        if (shopId != null) {
          _router!.go('/shop/$shopId');
        }
        break;

      case 'category_offers':
        // Navigate to home feed
        _router!.go('/');
        break;

      default:
        _router!.go('/');
    }
  }
}
