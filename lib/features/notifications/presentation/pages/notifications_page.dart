import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/app_notification.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ref
                  .read(notificationsControllerProvider.notifier)
                  .markAllAsRead();
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: notificationsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load notifications'),
              TextButton(
                onPressed: () {
                  ref
                      .read(notificationsControllerProvider.notifier)
                      .loadNotifications();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (notifications) {
          // Add demo notifications if empty
          final displayNotifications = notifications.isEmpty
              ? _getDemoNotifications()
              : notifications;

          if (displayNotifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(notificationsControllerProvider.notifier)
                  .loadNotifications();
            },
            child: ListView.builder(
              padding: AppSpacing.pagePadding,
              itemCount: displayNotifications.length,
              itemBuilder: (context, index) {
                return _NotificationCard(
                  notification: displayNotifications[index],
                  onDismiss: () {
                    ref
                        .read(notificationsControllerProvider.notifier)
                        .dismiss(displayNotifications[index].id);
                  },
                  onTap: () {
                    ref
                        .read(notificationsControllerProvider.notifier)
                        .markAsRead(displayNotifications[index].id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Health tips and alerts will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  List<AppNotification> _getDemoNotifications() {
    return [
      AppNotification(
        id: '1',
        type: NotificationType.tip,
        title: 'Stay Hydrated',
        message: 'Aim for 8 glasses of water today for optimal health.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      AppNotification(
        id: '2',
        type: NotificationType.suggestion,
        title: 'Magnesium Recommendation',
        message:
            'Based on your recent sleep patterns, consider adding magnesium-rich foods to your diet.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: '3',
        type: NotificationType.alert,
        title: 'Supplement Reminder',
        message: 'Time to take your daily vitamin D supplement.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      AppNotification(
        id: '4',
        type: NotificationType.reminder,
        title: 'Journal Entry Reminder',
        message:
            'You haven\'t logged your meals today. Record a voice note to track your nutrition.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    this.onDismiss,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.tip:
        return AppColors.info;
      case NotificationType.suggestion:
        return AppColors.primary;
      case NotificationType.alert:
        return AppColors.warning;
      case NotificationType.reminder:
        return AppColors.secondary;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.tip:
        return Icons.lightbulb_outline;
      case NotificationType.suggestion:
        return Icons.recommend;
      case NotificationType.alert:
        return Icons.warning_amber;
      case NotificationType.reminder:
        return Icons.schedule;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              border: notification.isRead
                  ? null
                  : Border(
                      left: BorderSide(color: typeColor, width: 4),
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                            ),
                          ),
                          Text(
                            _formatTime(notification.createdAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
