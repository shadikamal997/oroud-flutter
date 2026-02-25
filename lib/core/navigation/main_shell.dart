import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/offers/presentation/saved_offers_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/providers/unread_notification_count_provider.dart';
import '../../features/profile/providers/user_profile_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../widgets/offline_indicator.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    print("🏠 MainShell.build() called, _index = $_index");
    
    final isLoggedIn = ref.watch(authProvider);
    print("🔐 isLoggedIn = $isLoggedIn");
    
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

    // Watch profile only when logged in to redirect SHOP users to shop dashboard
    if (isLoggedIn) {
      final userProfileAsync = ref.watch(userProfileProvider);

      // Check if we need to redirect SHOP users
      return userProfileAsync.when(
        data: (user) {
          print('🔍 MainShell: profile loaded, user = $user');
          print('🔍 MainShell: user role = ${user?.role}');
          
          if (user?.role.toUpperCase() == 'SHOP') {
            print('⚠️ SHOP USER DETECTED → Redirecting to shop-dashboard');
            // Redirect immediately without rendering the shell
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                print('🔀 Executing redirect to /shop-dashboard');
                context.go('/shop-dashboard');
              }
            });
            // Show loading screen while redirect happens
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          print('✅ USER role detected, building MainShell');
          // Build normal user shell
          return _buildUserShell(unreadCountAsync);
        },
        loading: () {
          print('⏳ Loading user profile...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        error: (error, stack) {
          print('❌ Error loading profile: $error');
          
          // 🔥 FIX: 401 means tokens are invalid - logout user immediately
          if (error.toString().contains('401')) {
            print('🔥 401 Unauthorized - Logging out user');
            // Clear auth state and redirect to welcome
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ref.read(authProvider.notifier).logout();
                context.go('/welcome');
              }
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // For other errors, show user shell (network errors, etc.)
          return _buildUserShell(unreadCountAsync);
        },
      );
    }

    print("🎯 Building UserShell for non-logged-in user with _index = $_index");
    // Show user shell for non-logged-in users
    return _buildUserShell(unreadCountAsync);
  }
  
  Widget _buildUserShell(AsyncValue<int> unreadCountAsync) {
    print("📱 _buildUserShell called with _index = $_index");
    
    final screens = const [
      HomeScreen(),
      SavedOffersScreen(),
      ProfileScreen(),
    ];
    
    // ✅ FIX #7D: Protect against invalid index causing blank screen
    final safeIndex = _index.clamp(0, screens.length - 1);
    
    print("📺 Displaying screen at safe index $safeIndex (raw: $_index)");
    
    return Scaffold(
      body: Column(
        children: [
          const OfflineIndicator(),
          // 🔒 FIX #12B: Use IndexedStack to preserve screen state across tab switches
          // Prevents rebuilding screens every tap (causing blank screens & performance issues)
          Expanded(
            child: IndexedStack(
              index: safeIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  index: 0,
                  isSelected: _index == 0,
                ),
                _buildNavItem(
                  icon: Icons.favorite_rounded,
                  label: "Saved",
                  index: 1,
                  isSelected: _index == 1,
                ),
                _buildNavItemWithBadge(
                  icon: Icons.person_rounded,
                  label: "Profile",
                  index: 2,
                  isSelected: _index == 2,
                  unreadCountAsync: unreadCountAsync,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          print("👆 Tab tapped: $label (index $index)");
          setState(() {
            print("📍 Setting _index from $_index to $index");
            _index = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required AsyncValue<int> unreadCountAsync,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          print("👆 Tab tapped: $label (index $index)");
          setState(() {
            print("📍 Setting _index from $_index to $index");
            _index = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                  unreadCountAsync.when(
                    data: (count) {
                      if (count > 0) {
                        return Positioned(
                          right: -6,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              count > 9 ? "9+" : count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, stackTrace) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
