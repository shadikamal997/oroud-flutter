import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/user_notifications_provider.dart';
import '../providers/unread_notification_count_provider.dart';
import '../models/user_notification_model.dart';
import '../../../core/api/api_provider.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

class UserNotificationsScreen extends ConsumerStatefulWidget {
  const UserNotificationsScreen({super.key});

  @override
  ConsumerState<UserNotificationsScreen> createState() => _UserNotificationsScreenState();
}

class _UserNotificationsScreenState extends ConsumerState<UserNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh badge count when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final _ = ref.refresh(unreadNotificationCountProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFFB86E45),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              try {
                await ref
                    .read(apiClientProvider)
                    .patch('/users/me/notifications/read-all');

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications marked as read'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // ignore: unused_result
                ref.invalidate(userNotificationsProvider);
                // Refresh badge count
                // ignore: unused_result
                ref.refresh(unreadNotificationCountProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to mark notifications as read'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                "Something went wrong",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ref.invalidate(userNotificationsProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text("Retry"),
                ),
              ),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const _EmptyNotificationState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.invalidate(userNotificationsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _NotificationCard(
                  notification: n,
                  onTap: () async {
                    // Mark as read
                    if (!n.isRead) {
                      try {
                        await ref
                            .read(apiClientProvider)
                            .patch('/users/me/notifications/\${n.id}/read');

                        // ignore: unused_result
                        ref.invalidate(userNotificationsProvider);
                      } catch (e) {
                        // Silently fail - not critical
                      }
                    }

                    // Navigate to offer if available
                    if (n.offerId != null && context.mounted) {
                      context.push('/offer/\${n.offerId}');
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final UserNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getIconColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIcon(),
                      size: 20,
                      color: _getIconColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              if (notification.offerId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.touch_app,
                        size: 12,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tap to view offer',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'FOLLOW_SHOP':
        return Icons.store;
      case 'CATEGORY_MATCH':
        return Icons.label;
      case 'EXPIRING_OFFER':
        return Icons.timer;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case 'FOLLOW_SHOP':
        return Colors.blue;
      case 'CATEGORY_MATCH':
        return Colors.purple;
      case 'EXPIRING_OFFER':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '\${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '\${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '\${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No notifications yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "You'll see notifications about new offers, followed shops, and more here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
