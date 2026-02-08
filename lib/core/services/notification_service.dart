import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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
  }

  void setupMessageHandlers(
    Function(String title, String body) onForegroundMessage,
  ) {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        onForegroundMessage(
          notification.title ?? 'New Notification',
          notification.body ?? '',
        );
      }
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap when app is in background
      print("Background message tapped: ${message.notification?.title}");
    });
  }
}
