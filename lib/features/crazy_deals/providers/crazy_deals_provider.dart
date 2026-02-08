import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../../offers/models/offer_model.dart';

final crazyDealsProvider =
    FutureProvider<List<Offer>>((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get(Endpoints.crazyDeals);

  final data = response.data["deals"] as List;
  return data.map((e) => Offer.fromJson(e)).toList();
});
