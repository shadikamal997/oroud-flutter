import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service_enhanced.dart';
import '../../../core/api/api_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(apiClientProvider));
});

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends ConsumerState<NotificationHistoryScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _unreadCount = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool loadMore = false}) async {
    if (loadMore && _currentPage >= _totalPages) return;

    setState(() {
      if (!loadMore) _isLoading = true;
      _errorMessage = '';
    });

    try {
      final notificationService = ref.read(notificationServiceProvider);
      final result = await notificationService.getNotificationHistory(
        page: loadMore ? _currentPage + 1 : 1,
      );

      setState(() {
        if (loadMore) {
          _notifications.addAll(result['notifications'] ?? []);
          _currentPage++;
        } else {
          _notifications = result['notifications'] ?? [];
          _currentPage = result['pagination']['page'] ?? 1;
          _totalPages = result['pagination']['pages'] ?? 1;
        }
        _unreadCount = result['unreadCount'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notifications: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId, int index) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markAsRead(notificationId: notificationId);

      setState(() {
        _notifications[index]['isRead'] = true;
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as read: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markAllAsRead();

      setState(() {
        for (var notification in _notifications) {
          notification['isRead'] = true;
        }
        _unreadCount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark all as read: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFB86E45)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF2A2A2A),
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                fontSize: 20,
              ),
            ),
            if (_unreadCount > 0) ...[ 
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, color: Color(0xFFB86E45), size: 18),
              label: const Text(
                'Mark All',
                style: TextStyle(color: Color(0xFFB86E45), fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadNotifications(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(),
      child: ListView.builder(
        itemCount: _notifications.length + 1,
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            if (_currentPage < _totalPages) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => _loadNotifications(loadMore: true),
                    child: const Text('Load More'),
                  ),
                ),
              );
            }
            return const SizedBox(height: 16);
          }

          final notification = _notifications[index];
          final isUnread = !(notification['isRead'] ?? false);

          return Dismissible(
            key: Key(notification['id']),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.done, color: Colors.white),
            ),
            onDismissed: (_) => _markAsRead(notification['id'], index),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isUnread
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                child: Icon(
                  _getNotificationIcon(notification['type']),
                  color: isUnread ? Colors.white : Colors.grey[600],
                ),
              ),
              title: Text(
                notification['title'] ?? 'Notification',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['body'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(notification['sentAt']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: isUnread
                  ? IconButton(
                      icon: const Icon(Icons.circle, size: 12),
                      color: Theme.of(context).primaryColor,
                      onPressed: () => _markAsRead(notification['id'], index),
                    )
                  : null,
              isThreeLine: true,
              onTap: isUnread
                  ? () => _markAsRead(notification['id'], index)
                  : null,
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'FOLLOW_SHOP':
        return Icons.store;
      case 'NEW_OFFER':
        return Icons.local_offer;
      case 'EXPIRING_OFFER':
        return Icons.access_time;
      case 'NEW_REVIEW':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
