import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

enum NotificationType { tip, suggestion, alert, reminder }

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String message,
    DateTime? createdAt,
    DateTime? scheduledAt,
    @Default(false) bool isRead,
    @Default(false) bool isDismissed,
    String? actionRoute,
    Map<String, dynamic>? data,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

extension AppNotificationExtension on AppNotification {
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'created_at': createdAt?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'is_dismissed': isDismissed ? 1 : 0,
      'action_route': actionRoute,
    };
  }

  static AppNotification fromDbMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      type: NotificationType.values.byName(map['type'] as String),
      title: map['title'] as String,
      message: map['message'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      scheduledAt: map['scheduled_at'] != null
          ? DateTime.parse(map['scheduled_at'] as String)
          : null,
      isRead: (map['is_read'] as int?) == 1,
      isDismissed: (map['is_dismissed'] as int?) == 1,
      actionRoute: map['action_route'] as String?,
    );
  }
}
