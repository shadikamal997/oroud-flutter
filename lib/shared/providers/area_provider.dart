import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier for managing selected area
class AreaNotifier extends Notifier<String?> {
  @override
  String? build() {
    _loadSelectedArea();
    return null;
  }

  static const String _areaIdKey = 'selected_area_id';

  /// Load selected area from persistent storage
  Future<void> _loadSelectedArea() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final areaId = prefs.getString(_areaIdKey);
      state = areaId;
    } catch (e) {
      // If loading fails, keep null state
      state = null;
    }
  }

  /// Set selected area and persist it
  Future<void> setArea(String? areaId) async {
    try {
      state = areaId;
      final prefs = await SharedPreferences.getInstance();
      
      if (areaId != null) {
        await prefs.setString(_areaIdKey, areaId);
      } else {
        await prefs.remove(_areaIdKey);
      }
    } catch (e) {
      // Handle error silently, state is already set
    }
  }

  /// Clear selected area
  Future<void> clearArea() async {
    await setArea(null);
  }
}

/// Provider for selected area ID
final areaProvider = NotifierProvider<AreaNotifier, String?>(
  () => AreaNotifier(),
);
