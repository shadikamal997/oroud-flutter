import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/saved_provider.dart';
import '../../../shared/widgets/offer_card.dart';
import '../../auth/providers/auth_provider.dart';

class SavedOffersScreen extends ConsumerStatefulWidget {
  const SavedOffersScreen({super.key});

  @override
  ConsumerState<SavedOffersScreen> createState() => _SavedOffersScreenState();
}

class _SavedOffersScreenState extends ConsumerState<SavedOffersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider);

    // Show premium guest view for non-logged in users
    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F2EE),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Circular icon with gradient
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    const Text(
                      'Save Your Favorites',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2A2A),
                        fontFamily: 'serif',
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      'Create an account to save your favorite offers and access them anytime, anywhere',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Feature tiles
                    _buildFeatureTile(
                      icon: Icons.bookmark_added_outlined,
                      title: 'Quick Access',
                      description: 'Save offers and find them instantly',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Get Notified',
                      description: 'Receive alerts when saved offers expire',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureTile(
                      icon: Icons.sync_outlined,
                      title: 'Sync Everywhere',
                      description: 'Access your saved offers on any device',
                    ),
                    const SizedBox(height: 48),
                    
                    // Sign In Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/login'),
                          borderRadius: BorderRadius.circular(20),
                          child: const Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Create Account Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFB86E45),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/register'),
                          borderRadius: BorderRadius.circular(20),
                          child: const Center(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: Color(0xFFB86E45),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Logged-in users see their saved offers
    final savedAsync = ref.watch(savedOffersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildCustomHeader(context),
            
            // Content
            Expanded(
              child: savedAsync.when(
                loading: () => Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Loading your favorites...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2A2A2A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (err, stack) {
                  debugPrint("SAVED OFFERS ERROR: $err");
                  
                  // If 401 or auth error, show login prompt
                  final errorMessage = err.toString();
                  if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
                    return Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.lock_outlined,
                                  size: 50,
                                  color: Color(0xFFB86E45),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Login Required",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A2A2A),
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Please sign in to view your saved offers",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: 50,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Something went wrong",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A2A2A),
                                fontFamily: 'serif',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              err.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              width: 200,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    ref.invalidate(savedOffersProvider);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: const Center(
                                    child: Text(
                                      "Try Again",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                data: (offers) {
                  if (offers.isEmpty) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: const _EmptySavedState(),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(savedOffersProvider);
                    },
                    color: const Color(0xFFB86E45),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: OfferCard(offer: offers[index]),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon box with gradient
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Saved Offers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2A2A),
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB86E45).withValues(alpha: 0.2),
                        const Color(0xFFCC7F54).withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 50,
                    color: Color(0xFFB86E45),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "No Saved Offers Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2A2A),
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start exploring and save your favorite offers to find them here anytime",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
