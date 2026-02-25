import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../api/api_provider.dart';

/// Provider to fetch all categories with subcategories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiService = ref.read(apiClientProvider);
  
  try {
    final response = await apiService.get('/categories');
    
    if (response.data is List) {
      return (response.data as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  } catch (e) {
    throw Exception('Failed to load categories: $e');
  }
});

/// Provider to fetch subcategories for a specific category
final subcategoriesProvider = FutureProvider.family<List<Subcategory>, String>(
  (ref, categoryId) async {
    final apiService = ref.read(apiClientProvider);
    
    try {
      final response = await apiService.get(
        '/categories/$categoryId/subcategories',
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Subcategory.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load subcategories: $e');
    }
  },
);

/// State notifier for selected category and subcategory
class CategorySelectionNotifier extends Notifier<CategorySelection> {
  @override
  CategorySelection build() => const CategorySelection();

  void selectCategory(Category? category) {
    state = CategorySelection(
      selectedCategory: category,
      selectedSubcategory: null, // Reset subcategory when category changes
    );
  }

  void selectSubcategory(Subcategory? subcategory) {
    state = state.copyWith(selectedSubcategory: subcategory);
  }

  void clear() {
    state = const CategorySelection();
  }
}

class CategorySelection {
  final Category? selectedCategory;
  final Subcategory? selectedSubcategory;

  const CategorySelection({
    this.selectedCategory,
    this.selectedSubcategory,
  });

  CategorySelection copyWith({
    Category? selectedCategory,
    Subcategory? selectedSubcategory,
  }) {
    return CategorySelection(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubcategory: selectedSubcategory ?? this.selectedSubcategory,
    );
  }
}

final categorySelectionProvider =
    NotifierProvider<CategorySelectionNotifier, CategorySelection>(
  () => CategorySelectionNotifier(),
);
