import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../offers/providers/feed_provider.dart';
import '../../../shared/widgets/offer_card.dart';
import '../../../shared/widgets/offer_shimmer.dart';
import '../../ads/widgets/ad_banner.dart';
import '../../../shared/models/ad_model.dart';
import '../../../core/providers/category_providers.dart';
import '../../../core/models/category_model.dart';
import 'widgets/premium_slider_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  String? _selectedCategoryId; // 🔥 Changed to store ID instead of name
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Icon mapping for categories (fallback if backend doesn't provide icons)
  final Map<String, IconData> _categoryIcons = {
    'Electronics': Icons.devices_rounded,
    'Fashion': Icons.checkroom_rounded,
    'Shoes': Icons.shopping_bag_rounded,
    'Beauty': Icons.spa_rounded,
    'Restaurants': Icons.restaurant_rounded,
    'Cafes': Icons.local_cafe_rounded,
    'Supermarkets': Icons.shopping_cart_rounded,
    'Fitness': Icons.fitness_center_rounded,
    'Home & Decor': Icons.home_rounded,
    'Furniture': Icons.chair_rounded,
    'Car Services': Icons.directions_car_rounded,
    'Kids': Icons.child_care_rounded,
    'Pets': Icons.pets_rounded,
    'Gifts': Icons.card_giftcard_rounded,
    'Services': Icons.room_service_rounded,
  };

  @override
  void initState() {
    super.initState();
    ref.read(feedProvider.notifier).loadInitial();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(feedProvider.notifier).loadMore();
      }
    });

    _searchController.addListener(_onSearchChanged);

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final searchTerm = _searchController.text.trim();
      ref.read(feedProvider.notifier).setSearch(
            searchTerm.isEmpty ? null : searchTerm,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(feedProvider.notifier).loadInitial();
            },
            color: const Color(0xFFB86E45),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
              // Top Bar
              SliverToBoxAdapter(
                child: _buildTopBar(),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _buildPremiumSearchBar(),
                ),
              ),

              // Categories
              SliverToBoxAdapter(
                child: _buildCategoriesSection(),
              ),

              // 💎 Premium Slider - Paid offers only
              const SliverToBoxAdapter(
                child: PremiumSliderWidget(),
              ),

              // Firebase-Powered Hero Ads (Real-time across devices)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: AdBanner(
                    placement: AdPlacement.HERO,
                    height: 200,
                  ),
                ),
              ),

              // Trending Now Section
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  icon: Icons.local_fire_department_rounded,
                  title: 'Trending Now',
                  onSeeAll: () {
                    // Navigate to trending
                  },
                ),
              ),

              // Trending Grid
              feedState.isLoading && feedState.offers.isEmpty
                  ? SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const OfferShimmer(),
                          childCount: 4,
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= feedState.offers.length) {
                              return null;
                            }
                            return OfferCard(offer: feedState.offers[index]);
                          },
                          childCount: feedState.offers.length > 6
                              ? 6
                              : feedState.offers.length,
                        ),
                      ),
                    ),

              // Flash Deals Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: _buildSectionHeader(
                    icon: Icons.flash_on_rounded,
                    title: 'Flash Deals',
                    onSeeAll: () {
                      // Navigate to flash deals
                    },
                  ),
                ),
              ),

              // Flash Deals List
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 310,
                  child: feedState.isLoading && feedState.offers.isEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: 3,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 200,
                              child: const OfferShimmer(),
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: feedState.offers.length > 5
                              ? 5
                              : feedState.offers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 200,
                                child: OfferCard(offer: feedState.offers[index]),
                              ),
                            );
                          },
                        ),
                ),
              ),
              // Firebase-Powered Feed Ads (Real-time across devices)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AdBanner(
                    placement: AdPlacement.HOME_FEED,
                    height: 150,
                  ),
                ),
              ),

              // Nearby Shops Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: _buildSectionHeader(
                    icon: Icons.store_rounded,
                    title: 'Nearby Shops',
                    onSeeAll: () {
                      context.push('/shops');
                    },
                  ),
                ),
              ),

              // Nearby Shops Horizontal Scroll
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: 5,
                    itemBuilder: (context, index) => _buildShopCard(index),
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
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
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'O',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
          const Spacer(),
          // Title
          const Text(
            'Home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2A2A),
              fontFamily: 'serif',
            ),
          ),
          const Spacer(),
          // Chat Button with Badge
          GestureDetector(
            onTap: () => context.push('/chat'),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFFB86E45),
                      size: 18,
                    ),
                  ),
                  // Badge for unread messages (can be dynamic later)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Notifications Button with Badge
          GestureDetector(
            onTap: () => context.push('/notifications/history'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFFB86E45),
                      size: 18,
                    ),
                  ),
                  // Badge for unread notifications (can be dynamic later)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.search_rounded,
            color: Color(0xFFB86E45),
            size: 24,
          ),
          hintText: 'Search shops and offers',
          hintStyle: TextStyle(
            color: Color(0xFF999999),
            fontSize: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2A2A),
              fontFamily: 'serif',
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesProvider);
            
            return categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategoryId == category.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedCategoryId == category.id) {
                            _selectedCategoryId = null;
                          } else {
                            _selectedCategoryId = category.id;
                          }
                        });

                        // 🔥 Fixed: Send categoryId instead of category name
                        ref.read(feedProvider.notifier).applyCategoryFilter(_selectedCategoryId);
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3ECE6),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFFB86E45),
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _categoryIcons[category.name] ?? Icons.category_rounded,
                                color: const Color(0xFFB86E45),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Text(
                                category.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? const Color(0xFFB86E45)
                                      : const Color(0xFF2E3431),
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.normal,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              loading: () => SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFFB86E45),
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (error, stack) => SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Failed to load categories',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSponsoredSlider() {
    // Mock sponsored data - replace with real data from backend
    final sponsoredOffers = [
      {
        'title': 'Flash Sale Today',
        'subtitle': 'Up to 70% off electronics',
        'image': 'https://via.placeholder.com/400x180/B86E45/FFFFFF?text=Sponsored+1',
      },
      {
        'title': 'Weekend Special',
        'subtitle': 'Buy 1 Get 1 Free',
        'image': 'https://via.placeholder.com/400x180/CC7F54/FFFFFF?text=Sponsored+2',
      },
      {
        'title': 'Limited Time Offer',
        'subtitle': 'Save 50% on fashion',
        'image': 'https://via.placeholder.com/400x180/2E3431/FFFFFF?text=Sponsored+3',
      },
    ];

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: sponsoredOffers.length,
        itemBuilder: (context, index) {
          final offer = sponsoredOffers[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background Image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB86E45),
                          const Color(0xFFCC7F54),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  
                  // Dark gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sponsored badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Sponsored',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          offer['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // View Offer button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB86E45).withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'View Offer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB86E45),
            size: 28,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2A2A),
                fontFamily: 'serif',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onSeeAll != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB86E45),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShopCard(int index) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Image
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.store_rounded,
                color: Color(0xFFB86E45),
                size: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Shop ${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2A2A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 11,
                      color: Color(0xFF999999),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${(index + 1) * 0.5} km',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 26,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFB86E45),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Center(
                    child: Text(
                      'Follow',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB86E45),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
