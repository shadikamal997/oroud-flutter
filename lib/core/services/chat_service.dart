import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  /// Get all conversations for the current user/shop
  Future<List<dynamic>> getConversations() async {
    final response = await _apiClient.get('${Endpoints.chat}/conversations');
    return response.data as List<dynamic>;
  }

  /// Send a message (user to shop)
  Future<Map<String, dynamic>> sendMessage({
    required String shopId,
    required String message,
  }) async {
    final response = await _apiClient.post(
      '${Endpoints.chat}/send',
      data: {
        'shopId': shopId,
        'message': message,
      },
    );
    return response.data;
  }

  /// Send a message (shop to user) - for shop dashboard
  Future<Map<String, dynamic>> sendShopMessage({
    required String userId,
    required String message,
  }) async {
    final response = await _apiClient.post(
      '${Endpoints.chat}/shop/send',
      data: {
        'userId': userId,
        'message': message,
      },
    );
    return response.data;
  }

  /// Get messages in a conversation
  Future<Map<String, dynamic>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      '${Endpoints.chat}/$conversationId/messages',
      query: {
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }

  /// Mark messages as read
  Future<void> markAsRead(String messageId) async {
    await _apiClient.patch('${Endpoints.chat}/$messageId/read');
  }

  /// Mark shop messages as read
  Future<void> markShopMessagesAsRead(String conversationId) async {
    await _apiClient.patch('${Endpoints.chat}/shop/$conversationId/read');
  }
}
