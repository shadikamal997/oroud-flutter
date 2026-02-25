import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';

part 'my_offers_provider.freezed.dart';

@freezed
class MyOffersState with _$MyOffersState {
  const factory MyOffersState.initial() = _Initial;
  const factory MyOffersState.loading() = _Loading;
  const factory MyOffersState.loaded(MyOffersData data) = _Loaded;
  const factory MyOffersState.error(String message) = _Error;
}

class MyOffersData {
  final Map<String, dynamic> shop;
  final OffersSummary summary;
  final OffersCategories offers;

  MyOffersData({
    required this.shop,
    required this.summary,
    required this.offers,
  });

  factory MyOffersData.fromJson(Map<String, dynamic> json) {
    return MyOffersData(
      shop: json['shop'] as Map<String, dynamic>,
      summary: OffersSummary.fromJson(json['summary'] as Map<String, dynamic>),
      offers: OffersCategories.fromJson(json['offers'] as Map<String, dynamic>),
    );
  }
}

class OffersSummary {
  final int total;
  final int active;
  final int expired;
  final int inactive;

  OffersSummary({
    required this.total,
    required this.active,
    required this.expired,
    required this.inactive,
  });

  factory OffersSummary.fromJson(Map<String, dynamic> json) {
    return OffersSummary(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      expired: json['expired'] as int? ?? 0,
      inactive: json['inactive'] as int? ?? 0,
    );
  }
}

class OffersCategories {
  final List<dynamic> active;
  final List<dynamic> expired;
  final List<dynamic> inactive;

  OffersCategories({
    required this.active,
    required this.expired,
    required this.inactive,
  });

  factory OffersCategories.fromJson(Map<String, dynamic> json) {
    return OffersCategories(
      active: json['active'] as List<dynamic>? ?? [],
      expired: json['expired'] as List<dynamic>? ?? [],
      inactive: json['inactive'] as List<dynamic>? ?? [],
    );
  }
}

class MyOffersNotifier extends Notifier<MyOffersState> {
  @override
  MyOffersState build() {
    loadOffers();
    return const MyOffersState.initial();
  }

  Future<void> loadOffers() async {
    state = const MyOffersState.loading();
    
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('${Endpoints.offers}/my-offers');
      
      if (response.statusCode == 200) {
        final data = MyOffersData.fromJson(response.data);
        state = MyOffersState.loaded(data);
      } else {
        state = MyOffersState.error(
          response.data['message'] ?? 'Failed to load offers',
        );
      }
    } catch (e) {
      state = MyOffersState.error(e.toString());
    }
  }

  Future<void> refresh() async {
    await loadOffers();
  }

  Future<void> deleteOffer(String offerId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.delete('${Endpoints.offers}/$offerId');
      
      // Refresh the list after deletion
      await loadOffers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOffer(String offerId, Map<String, dynamic> data) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.patch('${Endpoints.offers}/$offerId', data: data);
      
      // Refresh the list after update
      await loadOffers();
    } catch (e) {
      rethrow;
    }
  }
}

final myOffersProvider = NotifierProvider<MyOffersNotifier, MyOffersState>(
  () => MyOffersNotifier(),
);
