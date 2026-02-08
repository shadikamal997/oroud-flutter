import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CityNotifier extends Notifier<String?> {
  @override
  String? build() {
    _loadCity();
    return null;
  }

  Future<void> _loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString("cityId");
  }

  Future<void> setCity(String cityId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cityId", cityId);
    state = cityId;
  }
}

final cityProvider = NotifierProvider<CityNotifier, String?>(
  () => CityNotifier(),
);
