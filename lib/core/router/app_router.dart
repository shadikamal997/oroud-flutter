import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../navigation/main_shell.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/shop_register_screen.dart';
import '../../features/auth/presentation/password_reset_request_screen.dart';
import '../../features/auth/presentation/password_reset_verify_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/language/language_selection_screen.dart';
import '../../features/offers/presentation/offer_detail_screen.dart';
import '../../features/offers/presentation/offer_details_screen.dart';
import '../../features/offers/presentation/saved_offers_screen.dart';
import '../../features/offers/models/offer_model.dart';
import '../../features/profile/presentation/city_selection_screen.dart';
import '../../features/profile/presentation/following_screen.dart';
import '../../features/profile/presentation/user_notifications_screen.dart';
import '../../features/profile/presentation/reviews_history_screen.dart';
import '../../features/profile/presentation/my_claims_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/change_password_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/help_support_screen.dart';
import '../../features/profile/presentation/pro_upgrade_screen.dart';
import '../../features/shop/presentation/shop_dashboard_screen.dart';
import '../../debug/test_ad_creation.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/chat/presentation/chat_conversation_screen.dart';
import '../../features/notifications/presentation/notification_history_screen.dart';
import '../../features/categories/presentation/favorite_categories_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../debug/clear_data_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final isLoggedIn = container.read(authProvider);
    final onSplash = state.uri.path == '/splash';
    final onLanguageSelection = state.uri.path == '/language-selection';
    final onWelcome = state.uri.path == '/welcome';
    final onAuthScreen = state.uri.path == '/login' || 
                        state.uri.path == '/register' || 
                        state.uri.path == '/shop-register';
    final onPasswordReset = state.uri.path.startsWith('/password-reset');
    
    // Public routes that guests can access (browsing features)
    final publicRoutes = [
      '/',                          // Home screen
      '/search',                    // Search
      '/select-city',               // City selection
    ];
    final isPublicRoute = publicRoutes.contains(state.uri.path) ||
                         state.uri.path.startsWith('/offer/');  // Offer details

    // Protected routes that require authentication
    final protectedRoutes = [
      '/saved-offers',              // Saved offers
      '/following',                 // Following shops
      '/notifications',             // Notifications
      '/my-reviews',                // Review history
      '/my-claims',                 // Claimed offers
      '/edit-profile',              // Edit profile
      '/change-password',           // Change password
      '/settings',                  // Settings
      '/help-support',              // Help & support
      '/pro-upgrade',               // Pro upgrade
      '/shop-dashboard',            // Shop dashboard
      '/chat',                      // Chat list
      '/categories/favorites',      // Favorite categories
    ];
    final isProtectedRoute = protectedRoutes.any((route) => 
      state.uri.path.startsWith(route)
    );

    // Allow splash screen without redirect
    if (onSplash) {
      return null;
    }

    // Allow welcome screen without redirect
    if (onWelcome) {
      return null;
    }

    // Allow password reset flow without login
    if (onPasswordReset) {
      return null;
    }

    // Allow public routes for guests
    if (isPublicRoute) {
      return null;
    }

    // Redirect to welcome if trying to access protected routes without auth
    if (isProtectedRoute && !isLoggedIn) {
      return '/';  // Go to home instead of welcome for better UX
    }

    // Not logged in and not on auth screen → redirect to home
    if (!isLoggedIn && !onAuthScreen && !isPublicRoute) {
      return '/';  // Go to home instead of welcome for better UX
    }

    // Logged in and on auth screen → redirect based on user role
    if (isLoggedIn && onAuthScreen) {
      // Let login/register screens handle navigation themselves
      // They will check user role and redirect appropriately
      return null;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language-selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/shop-register',
      builder: (context, state) => const ShopRegisterScreen(),
    ),
    GoRoute(
      path: '/password-reset/request',
      builder: (context, state) => const PasswordResetRequestScreen(),
    ),
    GoRoute(
      path: '/password-reset/verify',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return PasswordResetVerifyScreen(email: email);
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/offer/:id',
      builder: (context, state) {
        final offerId = state.pathParameters['id']!;
        // Check if extra is provided (old navigation with Offer object)
        final extra = state.extra;
        if (extra is Offer) {
          return OfferDetailScreen(offer: extra);
        }
        // New navigation with just ID (uses provider to fetch)
        return OfferDetailsScreen(offerId: offerId);
      },
    ),
    GoRoute(
      path: '/select-city',
      builder: (context, state) => const CitySelectionScreen(),
    ),
    GoRoute(
      path: '/saved-offers',
      builder: (context, state) => const SavedOffersScreen(),
    ),
    GoRoute(
      path: '/following',
      builder: (context, state) => const FollowingScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const UserNotificationsScreen(),
    ),
    GoRoute(
      path: '/my-reviews',
      builder: (context, state) => const ReviewsHistoryScreen(),
    ),
    GoRoute(
      path: '/my-claims',
      builder: (context, state) => const MyClaimsScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/pro-upgrade',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final featureName = extra?['featureName'] as String?;
        final description = extra?['description'] as String?;
        return ProUpgradeScreen(
          featureName: featureName,
          description: description,
        );
      },
    ),
    // Shop Dashboard (new clean version)
    GoRoute(
      path: '/shop-dashboard',
      builder: (context, state) => const ShopDashboardScreen(),
    ),
    // Test Ad Creation (temporary route for testing Firebase ads)
    GoRoute(
      path: '/test-ads',
      builder: (context, state) => const TestAdCreation(),
    ),
    // 🔥 NEW FEATURES
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:conversationId',
      name: 'chatConversation',
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId']!;
        final shopName = state.uri.queryParameters['shopName'] ?? 'Shop';
        return ChatConversationScreen(
          conversationId: conversationId,
          shopName: shopName,
        );
      },
    ),
    GoRoute(
      path: '/notifications/history',
      name: 'notificationHistory',
      builder: (context, state) => const NotificationHistoryScreen(),
    ),
    GoRoute(
      path: '/categories/favorites',
      name: 'favoriteCategories',
      builder: (context, state) => const FavoriteCategoriesScreen(),
    ),
    // Admin Panel
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminScreen(),
    ),
    // Debug: Clear All Data
    GoRoute(
      path: '/clear-data',
      name: 'clearData',
      builder: (context, state) => const ClearDataScreen(),
    ),
  ],
);
