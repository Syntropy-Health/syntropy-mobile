import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.notificationsEnabled = true,
    this.autoSyncEnabled = true,
    this.darkModeEnabled = false,
    this.userId = 'demo_user',
  });

  final bool notificationsEnabled;
  final bool autoSyncEnabled;
  final bool darkModeEnabled;
  final String userId;

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? autoSyncEnabled,
    bool? darkModeEnabled,
    String? userId,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      userId: userId ?? this.userId,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  static const _keyNotifications = 'notifications_enabled';
  static const _keyAutoSync = 'auto_sync_enabled';
  static const _keyDarkMode = 'dark_mode_enabled';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      autoSyncEnabled: prefs.getBool(_keyAutoSync) ?? true,
      darkModeEnabled: prefs.getBool(_keyDarkMode) ?? false,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setAutoSyncEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoSync, value);
    state = state.copyWith(autoSyncEnabled: value);
  }

  Future<void> setDarkModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
    state = state.copyWith(darkModeEnabled: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
