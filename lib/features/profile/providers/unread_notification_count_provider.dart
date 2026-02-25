import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  try {
    final api = ref.read(apiClientProvider);
    final response = await api.get("/users/me/notifications/unread-count");

    return response.data["count"] as int;
  } catch (e) {
    // Return 0 if error (user not logged in, network issue, etc.)
    return 0;
  }
});
