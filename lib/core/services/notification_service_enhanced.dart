import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  /// Get notification history (paginated)
  Future<Map<String, dynamic>> getNotificationHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      Endpoints.notificationHistory,
      query: {
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }

  /// Mark single or multiple notifications as read
  Future<void> markAsRead({
    String? notificationId,
    List<String>? notificationIds,
  }) async {
    await _apiClient.patch(
      Endpoints.markNotificationsRead,
      data: {
        if (notificationId != null) 'notificationId': notificationId,
        if (notificationIds != null) 'notificationIds': notificationIds,
      },
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _apiClient.patch(Endpoints.markAllNotificationsRead);
  }

  /// Register FCM device token
  Future<void> registerDevice(String token, {String? cityId}) async {
    await _apiClient.post(
      Endpoints.registerDevice,
      data: {
        'token': token,
        if (cityId != null) 'cityId': cityId,
      },
    );
  }
}
