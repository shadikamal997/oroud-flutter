import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'shared/widgets/error_boundary.dart';
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
  
  // Global error handler - catches ALL Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("🔥 GLOBAL ERROR: ${details.exception}");
    debugPrint("📍 Context: ${details.context}");
    debugPrintStack(stackTrace: details.stack);
  };
  
  // Initialize Firebase with error handling
  try {
    print("\n🔥 Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully!\n");
  } catch (e, stack) {
    print("\n❌ FIREBASE INITIALIZATION ERROR:");
    print(e);
    print(stack);
    print("\n");
  }
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize notification service
  final notificationService = NotificationService();
  
  // Register device token with backend
  await notificationService.init((token) async {
    print("\n");
    print("═══════════════════════════════════════");
    print("📱 FCM TOKEN RECEIVED:");
    print(token);
    print("═══════════════════════════════════════");
    print("\n");
    
    try {
      final api = ApiClient();
      await api.post(
        Endpoints.registerDevice,
        data: {"token": token},
      );
      print("✅ Device token registered successfully!");
    } catch (e) {
      print("❌ Failed to register device token: $e");
    }
  });
  
  // Setup message handlers
  notificationService.setupMessageHandlers((title, body) {
    print("Foreground notification: $title - $body");
  });
  
  // Set router for navigation (will be set after app builds)
  notificationService.setRouter(appRouter);
  
  runApp(const ProviderScope(child: OroudApp()));
}

class OroudApp extends ConsumerWidget {
  const OroudApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Oroud',
      
      // Localization configuration
      locale: locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Theme with Cairo font
      theme: AppTheme.lightTheme.copyWith(
        textTheme: AppTheme.lightTheme.textTheme.apply(
          fontFamily: 'Cairo',
        ),
      ),
      
      routerConfig: appRouter,
      builder: (context, child) {
        return ErrorBoundary(
          onError: (error, stackTrace) {
            // Log error to analytics service in production
            debugPrint('App Error: $error');
            debugPrint('StackTrace: $stackTrace');
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
