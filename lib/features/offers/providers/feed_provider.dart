import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/offer_model.dart';
import '../../../shared/providers/city_provider.dart';

class FeedState {
  final List<Offer> offers;
  final bool isLoading;
  final int page;
  final bool hasMore;
  final int? minDiscount;
  final String? category;
  final bool premiumOnly;

  FeedState({
    required this.offers,
    required this.isLoading,
    required this.page,
    required this.hasMore,
    this.minDiscount,
    this.category,
    this.premiumOnly = false,
  });

  FeedState copyWith({
    List<Offer>? offers,
    bool? isLoading,
    int? page,
    bool? hasMore,
    int? minDiscount,
    String? category,
    bool? premiumOnly,
  }) {
    return FeedState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      minDiscount: minDiscount ?? this.minDiscount,
      category: category ?? this.category,
      premiumOnly: premiumOnly ?? this.premiumOnly,
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
      final cityId = ref.read(cityProvider);
      final api = ref.read(apiClientProvider);
      final response = await api.get(
        Endpoints.feed,
        query: {
          if (cityId != null) "cityId": cityId,
          "page": 1,
          "limit": 20,
          if (state.minDiscount != null && state.minDiscount! > 0)
            "minDiscount": state.minDiscount,
          if (state.category != null) "category": state.category,
          if (state.premiumOnly) "premiumOnly": true,
        },
      );

      final data = response.data["data"] as List;

      final offers = data.map((e) => Offer.fromJson(e)).toList();

      state = FeedState(
        offers: offers,
        isLoading: false,
        page: 1,
        hasMore: offers.length == 20,
        minDiscount: state.minDiscount,
        category: state.category,
        premiumOnly: state.premiumOnly,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // TODO: Add error state handling
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.page + 1;
      final cityId = ref.read(cityProvider);

      final api = ref.read(apiClientProvider);
      final response = await api.get(
        Endpoints.feed,
        query: {
          if (cityId != null) "cityId": cityId,
          "page": nextPage,
          "limit": 20,
          if (state.minDiscount != null && state.minDiscount! > 0)
            "minDiscount": state.minDiscount,
          if (state.category != null) "category": state.category,
          if (state.premiumOnly) "premiumOnly": true,
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
      // TODO: Add error state handling
    }
  }

  Future<void> applyFilters(
    int? discount,
    String? category,
    bool premium,
  ) async {
    state = FeedState(
      offers: [],
      isLoading: false,
      page: 1,
      hasMore: true,
      minDiscount: discount,
      category: category,
      premiumOnly: premium,
    );

    await loadInitial();
  }
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(() {
  return FeedNotifier();
});
