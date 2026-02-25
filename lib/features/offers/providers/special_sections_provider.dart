import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/offer_model.dart';
import '../../../shared/providers/city_provider.dart';
import '../../../shared/providers/area_provider.dart';

// 🔥 TRENDING NOW PROVIDER
class TrendingState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;

  TrendingState({
    required this.offers,
    required this.isLoading,
    this.error,
  });
}

class TrendingNotifier extends Notifier<TrendingState> {
  @override
  TrendingState build() {
    // Auto-load trending offers on initialization
    _loadTrending();
    return TrendingState(offers: [], isLoading: true);
  }

  Future<void> _loadTrending() async {
    try {
      final cityId = ref.read(cityProvider);
      final areaId = ref.read(areaProvider);
      final api = ref.read(apiClientProvider);

      final response = await api.get(
        '${Endpoints.offers}/trending',
        query: {
          'cityId': ?cityId,
          'areaId': ?areaId,
        },
      );

      final data = response.data as List;
      final offers = data.map((e) => Offer.fromJson(e)).toList();

      state = TrendingState(offers: offers, isLoading: false);
    } catch (e) {
      state = TrendingState(
        offers: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = TrendingState(offers: [], isLoading: true);
    await _loadTrending();
  }
}

final trendingProvider = NotifierProvider<TrendingNotifier, TrendingState>(
  () => TrendingNotifier(),
);

// ⏳ ENDING SOON PROVIDER
class EndingSoonState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;

  EndingSoonState({
    required this.offers,
    required this.isLoading,
    this.error,
  });
}

class EndingSoonNotifier extends Notifier<EndingSoonState> {
  @override
  EndingSoonState build() {
    _loadEndingSoon();
    return EndingSoonState(offers: [], isLoading: true);
  }

  Future<void> _loadEndingSoon() async {
    try {
      final cityId = ref.read(cityProvider);
      final areaId = ref.read(areaProvider);
      final api = ref.read(apiClientProvider);

      final response = await api.get(
        '${Endpoints.offers}/ending-soon',
        query: {
          'cityId': ?cityId,
          'areaId': ?areaId,
        },
      );

      final data = response.data as List;
      final offers = data.map((e) => Offer.fromJson(e)).toList();

      state = EndingSoonState(offers: offers, isLoading: false);
    } catch (e) {
      state = EndingSoonState(
        offers: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = EndingSoonState(offers: [], isLoading: true);
    await _loadEndingSoon();
  }
}

final endingSoonProvider = NotifierProvider<EndingSoonNotifier, EndingSoonState>(
  () => EndingSoonNotifier(),
);

// 🆕 NEW TODAY PROVIDER
class NewTodayState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;

  NewTodayState({
    required this.offers,
    required this.isLoading,
    this.error,
  });
}

class NewTodayNotifier extends Notifier<NewTodayState> {
  @override
  NewTodayState build() {
    _loadNewToday();
    return NewTodayState(offers: [], isLoading: true);
  }

  Future<void> _loadNewToday() async {
    try {
      final cityId = ref.read(cityProvider);
      final areaId = ref.read(areaProvider);
      final api = ref.read(apiClientProvider);

      final response = await api.get(
        '${Endpoints.offers}/new-today',
        query: {
          'cityId': ?cityId,
          'areaId': ?areaId,
        },
      );

      final data = response.data as List;
      final offers = data.map((e) => Offer.fromJson(e)).toList();

      state = NewTodayState(offers: offers, isLoading: false);
    } catch (e) {
      state = NewTodayState(
        offers: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = NewTodayState(offers: [], isLoading: true);
    await _loadNewToday();
  }
}

final newTodayProvider = NotifierProvider<NewTodayNotifier, NewTodayState>(
  () => NewTodayNotifier(),
);

// 💎 PREMIUM PICKS PROVIDER
class PremiumState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;

  PremiumState({
    required this.offers,
    required this.isLoading,
    this.error,
  });
}

class PremiumNotifier extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    _loadPremium();
    return PremiumState(offers: [], isLoading: true);
  }

  Future<void> _loadPremium() async {
    try {
      final cityId = ref.read(cityProvider);
      final areaId = ref.read(areaProvider);
      final api = ref.read(apiClientProvider);

      final response = await api.get(
        '${Endpoints.offers}/premium',
        query: {
          'cityId': ?cityId,
          'areaId': ?areaId,
        },
      );

      final data = response.data as List;
      final offers = data.map((e) => Offer.fromJson(e)).toList();

      state = PremiumState(offers: offers, isLoading: false);
    } catch (e) {
      state = PremiumState(
        offers: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = PremiumState(offers: [], isLoading: true);
    await _loadPremium();
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, PremiumState>(
  () => PremiumNotifier(),
);

// ⭐ RECOMMENDED FOR YOU PROVIDER - Personalized recommendations
class RecommendedState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;

  RecommendedState({
    required this.offers,
    required this.isLoading,
    this.error,
  });
}

class RecommendedNotifier extends Notifier<RecommendedState> {
  @override
  RecommendedState build() {
    // Auto-load recommended offers on initialization
    _loadRecommended();
    return RecommendedState(offers: [], isLoading: true);
  }

  Future<void> _loadRecommended() async {
    try {
      final cityId = ref.read(cityProvider);
      final areaId = ref.read(areaProvider);
      final api = ref.read(apiClientProvider);

      final response = await api.get(
        '${Endpoints.offers}/recommended',
        query: {
          'cityId': ?cityId,
          'areaId': ?areaId,
        },
      );

      final data = response.data as List;
      final offers = data.map((e) => Offer.fromJson(e)).toList();

      state = RecommendedState(offers: offers, isLoading: false);
    } catch (e) {
      state = RecommendedState(
        offers: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = RecommendedState(offers: [], isLoading: true);
    await _loadRecommended();
  }
}

final recommendedProvider = NotifierProvider<RecommendedNotifier, RecommendedState>(
  () => RecommendedNotifier(),
);

// 📍 NEARBY OFFERS PROVIDER - Location-based discovery
// Uses FutureProvider.family for clean architecture
// Takes Position from locationProvider and returns nearby offers
final nearbyProvider = FutureProvider.family<List<Offer>, Position>(
  (ref, position) async {
    final api = ref.read(apiClientProvider);

    final response = await api.get(
      '${Endpoints.offers}/nearby',
      query: {
        'lat': position.latitude.toString(),
        'lng': position.longitude.toString(),
        'radius': '5', // 5km radius
      },
    );

    final data = response.data as List;
    return data.map((e) => Offer.fromJson(e)).toList();
  },
);

// ⚡ FLASH DEALS PROVIDER
class FlashDealsState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;

  FlashDealsState({
    required this.offers,
    required this.isLoading,
    this.error,
  });
}

class FlashDealsNotifier extends Notifier<FlashDealsState> {
  @override
  FlashDealsState build() {
    _loadFlashDeals();
    return FlashDealsState(offers: [], isLoading: true);
  }

  Future<void> _loadFlashDeals() async {
    try {
      final cityId = ref.read(cityProvider);
      final areaId = ref.read(areaProvider);
      final api = ref.read(apiClientProvider);

      final response = await api.get(
        '${Endpoints.offers}/flash-deals',
        query: {
          'cityId': ?cityId,
          'areaId': ?areaId,
        },
      );

      final data = response.data as List;
      final offers = data.map((e) => Offer.fromJson(e)).toList();

      state = FlashDealsState(offers: offers, isLoading: false);
    } catch (e) {
      state = FlashDealsState(
        offers: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = FlashDealsState(offers: [], isLoading: true);
    await _loadFlashDeals();
  }
}

final flashDealsProvider = NotifierProvider<FlashDealsNotifier, FlashDealsState>(
  () => FlashDealsNotifier(),
);

// 🎯 LIMITED OFFERS PROVIDER
class LimitedOffersState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;

  LimitedOffersState({
    required this.offers,
    required this.isLoading,
    this.error,
  });
}

class LimitedOffersNotifier extends Notifier<LimitedOffersState> {
  @override
  LimitedOffersState build() {
    _loadLimitedOffers();
    return LimitedOffersState(offers: [], isLoading: true);
  }

  Future<void> _loadLimitedOffers() async {
    try {
      final cityId = ref.read(cityProvider);
      final areaId = ref.read(areaProvider);
      final api = ref.read(apiClientProvider);

      final response = await api.get(
        '${Endpoints.offers}/limited',
        query: {
          'cityId': ?cityId,
          'areaId': ?areaId,
        },
      );

      final data = response.data as List;
      final offers = data.map((e) => Offer.fromJson(e)).toList();

      state = LimitedOffersState(offers: offers, isLoading: false);
    } catch (e) {
      state = LimitedOffersState(
        offers: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = LimitedOffersState(offers: [], isLoading: true);
    await _loadLimitedOffers();
  }
}

final limitedOffersProvider = NotifierProvider<LimitedOffersNotifier, LimitedOffersState>(
  () => LimitedOffersNotifier(),
);
