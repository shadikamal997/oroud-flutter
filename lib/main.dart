import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/api/api_client.dart';
import 'core/api/endpoints.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize notification service
  final notificationService = NotificationService();
  
  // Register device token with backend
  await notificationService.init((token) async {
    try {
      final api = ApiClient();
      await api.post(
        Endpoints.registerDevice,
        data: {"token": token},
      );
      print("Device token registered: $token");
    } catch (e) {
      print("Failed to register device token: $e");
    }
  });
  
  // Setup message handlers
  notificationService.setupMessageHandlers((title, body) {
    print("Foreground notification: $title - $body");
  });
  
  runApp(const ProviderScope(child: OroudApp()));
}

class OroudApp extends StatelessWidget {
  const OroudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Oroud',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
