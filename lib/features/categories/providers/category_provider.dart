import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../models/category_model.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get('/categories');

  return (response.data as List)
      .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
      .toList();
});
