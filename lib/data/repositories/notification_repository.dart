import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../datasources/local/database_helper.dart';
import '../models/app_notification.dart';

class NotificationRepository {
  NotificationRepository({required this.databaseHelper});

  final DatabaseHelper databaseHelper;
  final _uuid = const Uuid();

  Future<Result<AppNotification>> createNotification({
    required NotificationType type,
    required String title,
    required String message,
    DateTime? scheduledAt,
    String? actionRoute,
  }) async {
    try {
      final notification = AppNotification(
        id: _uuid.v4(),
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        scheduledAt: scheduledAt,
        actionRoute: actionRoute,
      );

      await databaseHelper.insert('notifications', notification.toDbMap());

      AppLogger.info('Created notification: ${notification.id}', 'NotificationRepo');
      return Right(notification);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create notification', 'NotificationRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to create notification: $e'));
    }
  }

  Future<Result<List<AppNotification>>> getNotifications({
    int? limit,
    bool includeRead = true,
    bool includeDismissed = false,
  }) async {
    try {
      String? where;
      List<Object?>? whereArgs;

      if (!includeRead && !includeDismissed) {
        where = 'is_read = ? AND is_dismissed = ?';
        whereArgs = [0, 0];
      } else if (!includeRead) {
        where = 'is_read = ?';
        whereArgs = [0];
      } else if (!includeDismissed) {
        where = 'is_dismissed = ?';
        whereArgs = [0];
      }

      final results = await databaseHelper.query(
        'notifications',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );

      final notifications = results
          .map((map) => AppNotificationExtension.fromDbMap(map))
          .toList();

      return Right(notifications);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get notifications', 'NotificationRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to get notifications: $e'));
    }
  }

  Future<Result<void>> markAsRead(String id) async {
    try {
      await databaseHelper.update(
        'notifications',
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to mark as read', 'NotificationRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to mark as read: $e'));
    }
  }

  Future<Result<void>> dismiss(String id) async {
    try {
      await databaseHelper.update(
        'notifications',
        {'is_dismissed': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to dismiss', 'NotificationRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to dismiss: $e'));
    }
  }

  Future<Result<void>> markAllAsRead() async {
    try {
      await databaseHelper.update(
        'notifications',
        {'is_read': 1},
        where: 'is_read = ?',
        whereArgs: [0],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to mark all as read', 'NotificationRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to mark all as read: $e'));
    }
  }

  Future<Result<int>> getUnreadCount() async {
    try {
      final results = await databaseHelper.query(
        'notifications',
        where: 'is_read = ? AND is_dismissed = ?',
        whereArgs: [0, 0],
      );
      return Right(results.length);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get unread count', 'NotificationRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to get unread count: $e'));
    }
  }

  Future<Result<void>> deleteOldNotifications({int daysOld = 30}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: daysOld));
      await databaseHelper.delete(
        'notifications',
        where: 'created_at < ? AND is_dismissed = ?',
        whereArgs: [cutoff.toIso8601String(), 1],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete old', 'NotificationRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to delete old: $e'));
    }
  }
}
