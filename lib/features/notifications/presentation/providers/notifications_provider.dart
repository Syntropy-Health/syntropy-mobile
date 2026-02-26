import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/models/app_notification.dart';

// Notifications List Provider
final notificationsListProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  if (repository == null) return []; // Not available on web
  final result = await repository.getNotifications(
    includeRead: true,
    includeDismissed: false,
  );
  return result.fold(
    (failure) => [],
    (notifications) => notifications,
  );
});

// Unread Count Provider
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  if (repository == null) return 0; // Not available on web
  final result = await repository.getUnreadCount();
  return result.fold(
    (failure) => 0,
    (count) => count,
  );
});

// Notifications Controller
class NotificationsController
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsController({required this.ref})
      : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  final Ref ref;

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    final repository = ref.read(notificationRepositoryProvider);
    if (repository == null) {
      state = const AsyncValue.data([]);
      return;
    }
    final result = await repository.getNotifications(
      includeRead: true,
      includeDismissed: false,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message ?? 'Failed to load', StackTrace.current),
      (notifications) => AsyncValue.data(notifications),
    );
  }

  Future<void> markAsRead(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository == null) return;
    await repository.markAsRead(id);

    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList(),
      );
    });
  }

  Future<void> dismiss(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository == null) return;
    await repository.dismiss(id);

    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.where((n) => n.id != id).toList(),
      );
    });
  }

  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository == null) return;
    await repository.markAllAsRead();

    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.map((n) => n.copyWith(isRead: true)).toList(),
      );
    });
  }

  Future<void> createHealthTip(String title, String message) async {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository == null) return;
    await repository.createNotification(
      type: NotificationType.tip,
      title: title,
      message: message,
    );
    await loadNotifications();
  }

  Future<void> createHealthAlert(String title, String message) async {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository == null) return;
    await repository.createNotification(
      type: NotificationType.alert,
      title: title,
      message: message,
    );
    await loadNotifications();
  }
}

final notificationsControllerProvider = StateNotifierProvider.autoDispose<
    NotificationsController, AsyncValue<List<AppNotification>>>(
  (ref) => NotificationsController(ref: ref),
);

// Health Tips Messages
const List<String> healthTipMessages = [
  'Stay hydrated! Aim for 8 glasses of water today.',
  'Take a 5-minute break to stretch and move around.',
  'Deep breathing can help reduce stress - try 4-7-8 technique.',
  'Consider adding more leafy greens to your next meal.',
  'Getting morning sunlight helps regulate your circadian rhythm.',
];

// Health Suggestion Messages
const List<String> healthSuggestionMessages = [
  'Based on your recent entries, consider adding magnesium-rich foods.',
  'Your sleep patterns suggest you might benefit from earlier bedtime.',
  'Try incorporating more omega-3 rich foods for brain health.',
  'Consider taking vitamin D, especially during winter months.',
  'Regular movement throughout the day improves energy levels.',
];
