import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../offers/providers/feed_provider.dart';
import '../../crazy_deals/presentation/crazy_deals_banner.dart';
import '../../../shared/widgets/offer_card.dart';
import '../../../shared/widgets/offer_shimmer.dart';
import '../../../shared/providers/city_provider.dart';
import 'filter_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

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
  }

  Widget _buildCityChip(String? cityId) {
    final cityName = cityId != null
        ? {
            "1": "Amman",
            "2": "Irbid",
            "3": "Zarqa",
            "4": "Aqaba",
          }[cityId] ??
            "Select City"
        : "Select City";

    return GestureDetector(
      onTap: () {
        context.push('/select-city');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Text(cityName),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final cityId = ref.watch(cityProvider);
    final feedState = ref.watch(feedProvider);
    final hasActiveFilters = feedState.minDiscount != null ||
        feedState.category != null ||
        feedState.premiumOnly;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF97316),
            Color(0xFFFB923C),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildCityChip(cityId),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "Find the best offers 🔥",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => FilterBottomSheet(
                          initialDiscount: feedState.minDiscount,
                          initialCategory: feedState.category,
                          initialPremium: feedState.premiumOnly,
                          onApply: (discount, category, premium) {
                            ref
                                .read(feedProvider.notifier)
                                .applyFilters(discount, category, premium);
                          },
                        ),
                      );
                    },
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search offers...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      "Clothing",
      "Electronics",
      "Restaurants",
      "Cafes",
      "Beauty",
      "Home",
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(categories[index]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(feedProvider.notifier).loadInitial();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 🔥 Gradient Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // 🔥 Crazy Deals
              const SliverToBoxAdapter(
                child: CrazyDealsBanner(),
              ),

              // 🔥 Categories
              SliverToBoxAdapter(
                child: _buildCategories(),
              ),

              // 🔥 Feed
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: state.isLoading && state.offers.isEmpty
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const OfferShimmer(),
                          childCount: 5,
                        ),
                      )
                    : state.offers.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No offers found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Try adjusting your filters",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index < state.offers.length) {
                                  return OfferCard(offer: state.offers[index]);
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                              },
                              childCount:
                                  state.offers.length + (state.isLoading ? 1 : 0),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
