import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/user_notification_model.dart';

final userNotificationsProvider =
    FutureProvider<List<UserNotification>>((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get(Endpoints.userNotifications);

  final data = response.data["data"] as List;
  return data.map((e) => UserNotification.fromJson(e)).toList();
});
