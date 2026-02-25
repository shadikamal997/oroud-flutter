import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'widgets/empty_state_widget.dart';
import 'package:oroud_app/core/theme/app_colors.dart';
import '../../../core/api/api_provider.dart';

/// Shop notification model
class ShopNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'review', 'offer_expiring', 'system'
  final DateTime createdAt;
  final bool isRead;

  ShopNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory ShopNotification.fromJson(Map<String, dynamic> json) {
    return ShopNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  ShopNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ShopNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Async notifier for fetching notifications from API
class NotificationsNotifier extends AsyncNotifier<List<ShopNotification>> {
  @override
  Future<List<ShopNotification>> build() async {
    return fetchNotifications();
  }

  Future<List<ShopNotification>> fetchNotifications() async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get('/shops/notifications');
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ShopNotification.fromJson(json)).toList();
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchNotifications());
  }

  Future<void> markAsRead(String id) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.put('/shops/notifications/$id/read');
      
      // Update local state
      state.whenData((notifications) {
        state = AsyncValue.data(
          notifications.map((n) {
            if (n.id == id) return n.copyWith(isRead: true);
            return n;
          }).toList(),
        );
      });
    } catch (e) {
      // Ignore errors for now
    }
  }

  Future<void> markAllAsRead() async {
    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.map((n) => n.copyWith(isRead: true)).toList(),
      );
    });
  }

  Future<void> deleteNotification(String id) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.delete('/shops/notifications/$id');
      
      // Update local state
      state.whenData((notifications) {
        state = AsyncValue.data(
          notifications.where((n) => n.id != id).toList(),
        );
      });
    } catch (e) {
      // Ignore errors for now
    }
  }
}

/// Provider for notifications fetched from API
final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<ShopNotification>>(() {
  return NotificationsNotifier();
});

/// Shop notifications screen
class ShopNotificationsScreen extends ConsumerStatefulWidget {
  const ShopNotificationsScreen({super.key});

  @override
  ConsumerState<ShopNotificationsScreen> createState() => _ShopNotificationsScreenState();
}

class _ShopNotificationsScreenState extends ConsumerState<ShopNotificationsScreen> {
  String _selectedFilter = 'all'; // 'all', 'unread', 'read'

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          notificationsAsync.whenData((notifications) {
            if (notifications.any((n) => !n.isRead)) {
              return TextButton(
                onPressed: _markAllAsRead,
                child: const Text(
                  'Mark all read',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          }).value ?? const SizedBox.shrink(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'unread', child: Text('Unread')),
              const PopupMenuItem(value: 'read', child: Text('Read')),
            ],
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (allNotifications) {
          final filteredNotifications = _filterNotifications(allNotifications);
          
          if (filteredNotifications.isEmpty) {
            return _buildEmptyState();
          }
          
          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            child: ListView.separated(
              itemCount: filteredNotifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                return _buildNotificationTile(notification);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading notifications: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(notificationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ShopNotification> _filterNotifications(List<ShopNotification> notifications) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'read':
        return notifications.where((n) => n.isRead).toList();
      default:
        return notifications;
    }
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: _selectedFilter == 'unread' 
          ? Icons.notifications_off_outlined 
          : Icons.notifications_none,
      title: _selectedFilter == 'unread' 
          ? 'All caught up!'
          : 'No notifications yet',
      subtitle: _selectedFilter == 'unread'
          ? 'You\'ve read all your notifications. Great job staying on top of things!'
          : 'When customers interact with your offers, you\'ll see notifications here.',
      color: AppColors.primary,
    );
  }

  Widget _buildNotificationTile(ShopNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: ListTile(
        leading: _buildNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _markAsRead(notification.id),
        tileColor: notification.isRead 
            ? null 
            : AppColors.primary.withOpacity(0.05),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'review':
        icon = Icons.star;
        color = Colors.amber;
        break;
      case 'offer_expiring':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case 'system':
        icon = Icons.info;
        color = AppColors.primary;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _markAsRead(String id) {
    ref.read(notificationsProvider.notifier).markAsRead(id);
  }

  void _markAllAsRead() {
    ref.read(notificationsProvider.notifier).markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _deleteNotification(String id) {
    ref.read(notificationsProvider.notifier).deleteNotification(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  Future<void> _refreshNotifications() async {
    await ref.read(notificationsProvider.notifier).refresh();
  }
}
