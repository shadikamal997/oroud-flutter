import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/offer_model.dart';

final savedOffersProvider = FutureProvider<List<Offer>>((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get(Endpoints.savedOffers);

  final data = response.data["data"] as List;
  return data.map((e) => Offer.fromJson(e)).toList();
});
