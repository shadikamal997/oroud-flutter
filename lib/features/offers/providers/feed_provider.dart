import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/offer_model.dart' show Offer, OfferType;
import '../../../shared/providers/city_provider.dart';

class FeedState {
  final List<Offer> offers;
  final bool isLoading;
  final int page;
  final bool hasMore;
  final int? minDiscount;
  final String? categoryId; // 🔥 Changed from 'category' to 'categoryId'
  final bool premiumOnly;
  final String? cityId;
  final String? areaId;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final bool endingSoon;
  final bool verifiedOnly;
  final OfferType? offerType; // 🔥 NEW: Filter by offer type

  FeedState({
    required this.offers,
    required this.isLoading,
    required this.page,
    required this.hasMore,
    this.minDiscount,
    this.categoryId, // 🔥 Changed
    this.premiumOnly = false,
    this.cityId,
    this.areaId,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.endingSoon = false,
    this.verifiedOnly = false,
    this.offerType, // 🔥 NEW
  });

  FeedState copyWith({
    List<Offer>? offers,
    bool? isLoading,
    int? page,
    bool? hasMore,
    int? minDiscount,
    String? categoryId, // 🔥 Changed
    bool? premiumOnly,
    String? cityId,
    String? areaId,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? endingSoon,
    bool? verifiedOnly,
    OfferType? offerType, // 🔥 NEW
  }) {
    return FeedState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      minDiscount: minDiscount ?? this.minDiscount,
      categoryId: categoryId ?? this.categoryId, // 🔥 Changed
      premiumOnly: premiumOnly ?? this.premiumOnly,
      cityId: cityId ?? this.cityId,
      areaId: areaId ?? this.areaId,
      search: search ?? this.search,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      endingSoon: endingSoon ?? this.endingSoon,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      offerType: offerType ?? this.offerType, // 🔥 NEW
    );
  }
}

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() {
    return FeedState(
      offers: [],
      isLoading: false,
      page: 1,
      hasMore: true,
    );
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, page: 1);

    try {
      final selectedCityId = state.cityId ?? ref.read(cityProvider);
      
      final api = ref.read(apiClientProvider);
      final response = await api.get(
        Endpoints.feed,
        query: {
          if (selectedCityId != null) "cityId": selectedCityId,
          if (state.areaId != null) "areaId": state.areaId,
          if (state.search != null && state.search!.isNotEmpty) "search": state.search,
          "page": 1,
          "limit": 20,
          if (state.minDiscount != null && state.minDiscount! > 0)
            "minDiscount": state.minDiscount,
          if (state.minPrice != null) "minPrice": state.minPrice,
          if (state.maxPrice != null) "maxPrice": state.maxPrice,
          if (state.endingSoon) "endingSoon": true,
          if (state.verifiedOnly) "verifiedOnly": true,
          if (state.categoryId != null) "categoryId": state.categoryId, // 🔥 Fixed: Send categoryId
          if (state.premiumOnly) "premiumOnly": true,
        },
      );

      final data = response.data["data"] as List;
      final offers = data.map((e) => Offer.fromJson(e)).toList();

      // 🔥 DEBUG: Print offer types
      for (var offer in offers.take(3)) {
        print('🔥 Offer: ${offer.title}');
        print('   Type: ${offer.offerType}');
        print('   Category: ${offer.category}');
        if (offer.maxClaims != null) {
          print('   Claims: ${offer.claimedCount}/${offer.maxClaims}');
        }
        if (offer.validUntil != null) {
          print('   Valid Until: ${offer.validUntil}');
        }
      }

      state = FeedState(
        offers: offers,
        isLoading: false,
        page: 1,
        hasMore: offers.length == 20,
        minDiscount: state.minDiscount,
        categoryId: state.categoryId, // 🔥 Fixed
        premiumOnly: state.premiumOnly,
        cityId: state.cityId,
        areaId: state.areaId,
        offerType: state.offerType, // 🔥 NEW
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.page + 1;
      final selectedCityId = state.cityId ?? ref.read(cityProvider);

      final api = ref.read(apiClientProvider);
      final response = await api.get(
        Endpoints.feed,
        query: {
          if (selectedCityId != null) "cityId": selectedCityId,
          if (state.areaId != null) "areaId": state.areaId,
          if (state.search != null && state.search!.isNotEmpty) "search": state.search,
          "page": nextPage,
          "limit": 20,
          if (state.minDiscount != null && state.minDiscount! > 0)
            "minDiscount": state.minDiscount,
          if (state.minPrice != null) "minPrice": state.minPrice,
          if (state.maxPrice != null) "maxPrice": state.maxPrice,
          if (state.endingSoon) "endingSoon": true,
          if (state.verifiedOnly) "verifiedOnly": true,
          if (state.categoryId != null) "categoryId": state.categoryId, // 🔥 Fixed
          if (state.premiumOnly) "premiumOnly": true,
          if (state.offerType != null) "offerType": state.offerType!.name,
        },
      );

      final data = response.data["data"] as List;
      final newOffers = data.map((e) => Offer.fromJson(e)).toList();

      state = state.copyWith(
        offers: [...state.offers, ...newOffers],
        isLoading: false,
        page: nextPage,
        hasMore: newOffers.length == 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setSearch(String? searchTerm) {
    state = state.copyWith(search: searchTerm, page: 1, offers: []);
    loadInitial();
  }

  Future<void> applyFilters(
    int? discount,
    String? categoryId, // 🔥 Changed parameter name
    bool premium,
    String? cityId,
    String? areaId,
    double? minPrice,
    double? maxPrice,
    bool endingSoon,
    bool verifiedOnly,
  ) async {
    state = FeedState(
      offers: [],
      isLoading: false,
      page: 1,
      hasMore: true,
      minDiscount: discount,
      categoryId: categoryId, // 🔥 Fixed
      premiumOnly: premium,
      cityId: cityId,
      areaId: areaId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      endingSoon: endingSoon,
      verifiedOnly: verifiedOnly,
      search: state.search,
      offerType: state.offerType, // 🔥 Preserve offer type filter
    );

    await loadInitial();
  }

  // 🔥 NEW: Simplified method for category filtering from home screen
  Future<void> applyCategoryFilter(String? categoryId) async {
    state = state.copyWith(
      categoryId: categoryId,
      offers: [],
      page: 1,
      isLoading: false,
      hasMore: true,
    );
    await loadInitial();
  }

  // 🔥 NEW: Apply offer type filter
  Future<void> applyOfferTypeFilter(OfferType? type) async {
    state = FeedState(
      offers: [],
      isLoading: false,
      page: 1,
      hasMore: true,
      minDiscount: state.minDiscount,
      categoryId: state.categoryId, // 🔥 Fixed
      premiumOnly: state.premiumOnly,
      cityId: state.cityId,
      areaId: state.areaId,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      endingSoon: state.endingSoon,
      verifiedOnly: state.verifiedOnly,
      search: state.search,
      offerType: type, // 🔥 NEW: Set offer type
    );

    await loadInitial();
  }
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(() {
  return FeedNotifier();
});
