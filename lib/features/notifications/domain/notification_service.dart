import 'dart:async';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationService {
  NotificationService({required this.repository});

  final NotificationRepository repository;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _healthTipTimer;
  Timer? _suggestionTimer;
  final _random = Random();

  static const List<String> _tipMessages = [
    'Stay hydrated! Aim for 8 glasses of water today.',
    'Take a 5-minute break to stretch and move around.',
    'Deep breathing can help reduce stress - try 4-7-8 technique.',
    'Consider adding more leafy greens to your next meal.',
    'Getting morning sunlight helps regulate your circadian rhythm.',
    'Stretching for a few minutes can help relieve muscle tension.',
  ];

  static const List<String> _suggestionMessages = [
    'Based on your recent entries, consider adding magnesium-rich foods.',
    'Your sleep patterns suggest you might benefit from earlier bedtime.',
    'Try incorporating more omega-3 rich foods for brain health.',
    'Consider taking vitamin D, especially during winter months.',
    'Regular movement throughout the day improves energy levels.',
  ];

  static const List<String> _alertMessages = [
    'Time to take your daily supplements.',
    'Remember to log your meals for better tracking.',
    'Hydration check: Have you had water recently?',
  ];

  Future<void> initialize() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    AppLogger.info('NotificationService initialized', 'NotificationService');
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info(
      'Notification tapped: ${response.payload}',
      'NotificationService',
    );
    // Handle notification tap - navigate to appropriate screen
  }

  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void startHealthAlertSystem({
    Duration tipInterval = const Duration(minutes: 30),
    Duration suggestionInterval = const Duration(hours: 1),
  }) {
    _healthTipTimer?.cancel();
    _suggestionTimer?.cancel();

    _healthTipTimer = Timer.periodic(tipInterval, (_) {
      _showRandomTip();
    });

    _suggestionTimer = Timer.periodic(suggestionInterval, (_) {
      _showRandomSuggestion();
    });

    AppLogger.info('Health alert system started', 'NotificationService');
  }

  void stopHealthAlertSystem() {
    _healthTipTimer?.cancel();
    _suggestionTimer?.cancel();
    _healthTipTimer = null;
    _suggestionTimer = null;
    AppLogger.info('Health alert system stopped', 'NotificationService');
  }

  Future<void> _showRandomTip() async {
    final message = _tipMessages[_random.nextInt(_tipMessages.length)];
    await _createAndShowNotification(
      type: NotificationType.tip,
      title: 'Health Tip',
      message: message,
    );
  }

  Future<void> _showRandomSuggestion() async {
    final message = _suggestionMessages[_random.nextInt(_suggestionMessages.length)];
    await _createAndShowNotification(
      type: NotificationType.suggestion,
      title: 'Personalized Suggestion',
      message: message,
    );
  }

  Future<void> showAlert(String title, String message) async {
    await _createAndShowNotification(
      type: NotificationType.alert,
      title: title,
      message: message,
    );
  }

  Future<void> showReminder(String title, String message) async {
    await _createAndShowNotification(
      type: NotificationType.reminder,
      title: title,
      message: message,
    );
  }

  Future<void> _createAndShowNotification({
    required NotificationType type,
    required String title,
    required String message,
  }) async {
    // Save to repository
    await repository.createNotification(
      type: type,
      title: title,
      message: message,
    );

    // Show local notification
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: message,
      payload: type.name,
    );
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'syntropy_health_channel',
      'Syntropy Health',
      channelDescription: 'Health tips and recommendations',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Would use zonedSchedule for actual scheduling
    AppLogger.info(
      'Scheduled notification for $scheduledTime',
      'NotificationService',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void dispose() {
    stopHealthAlertSystem();
  }
}
