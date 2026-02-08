import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../navigation/main_shell.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/offers/presentation/offer_detail_screen.dart';
import '../../features/offers/models/offer_model.dart';
import '../../features/profile/presentation/city_selection_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final isLoggedIn = container.read(authProvider);
    final loggingIn = state.uri.path == '/login';

    // Not logged in and not on login page → redirect to login
    if (!isLoggedIn && !loggingIn) {
      return '/login';
    }

    // Logged in and on login page → redirect to home
    if (isLoggedIn && loggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/offer/:id',
      builder: (context, state) {
        final offer = state.extra as Offer;
        return OfferDetailScreen(offer: offer);
      },
    ),
    GoRoute(
      path: '/select-city',
      builder: (context, state) => const CitySelectionScreen(),
    ),
  ],
);
