import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/user_review_model.dart';

final userReviewsProvider = FutureProvider<List<UserReview>>((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get(Endpoints.myReviews);

  final data = response.data as List;
  return data.map((e) => UserReview.fromJson(e)).toList();
});
