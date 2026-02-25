import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import 'saved_provider.dart';

/// Provider that manages the Set of saved offer IDs for instant UI updates
final savedOffersIdsProvider = NotifierProvider<SavedOffersIdsNotifier, Set<String>>(
  SavedOffersIdsNotifier.new,
);

class SavedOffersIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // Load saved IDs on initialization
    _loadSavedIds();
    return {};
  }

  Future<void> _loadSavedIds() async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get('/offers/saved');
      final data = response.data["data"] as List;
      final ids = data.map((offer) => offer['id'] as String).toSet();
      state = ids;
    } catch (e) {
      // If fetching fails, keep empty set
      state = {};
    }
  }

  bool isSaved(String offerId) {
    return state.contains(offerId);
  }

  Future<void> toggleSave(String offerId) async {
    final api = ref.read(apiClientProvider);
    
    if (state.contains(offerId)) {
      // Remove from saved
      await api.delete('/offers/$offerId/save');
      state = Set.from(state)..remove(offerId);
    } else {
      // Add to saved
      await api.post('/offers/$offerId/save');
      state = Set.from(state)..add(offerId);
    }

    // Invalidate the saved offers list to refresh the Saved tab
    ref.invalidate(savedOffersProvider);
  }

  Future<void> refresh() async {
    await _loadSavedIds();
  }
}
