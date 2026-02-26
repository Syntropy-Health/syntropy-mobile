import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/remote/supabase_client.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;

  DatabaseHelper? _databaseHelper;
  late final SupabaseClientWrapper _supabaseClient;

  DatabaseHelper? get databaseHelper => _databaseHelper;
  SupabaseClientWrapper get supabaseClient => _supabaseClient;

  bool get isWebPlatform => kIsWeb;

  static Future<void> initialize() async {
    await _instance._initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize local database (skip on web - SQLite not supported)
    if (!kIsWeb) {
      _databaseHelper = DatabaseHelper();
      await _databaseHelper!.initialize();
    } else {
      AppLogger.info('Running on web - SQLite skipped, using in-memory/Supabase only', 'ServiceLocator');
    }

    // Initialize Supabase (if configured)
    final config = AppConfig.instance;
    if (config.supabaseUrl.isNotEmpty && config.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
      );
    }
    _supabaseClient = SupabaseClientWrapper();
  }

  Future<void> dispose() async {
    await _databaseHelper?.close();
  }
}
