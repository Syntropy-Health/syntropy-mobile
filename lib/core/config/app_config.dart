import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static late final AppConfig _instance;
  static AppConfig get instance => _instance;

  // Environment
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Supabase Configuration
  late final String supabaseUrl;
  late final String supabaseAnonKey;

  // OpenAI Configuration
  late final String openAiApiKey;

  // Amazon Affiliate Configuration
  late final String amazonAssociateTag;

  // API Endpoints
  late final String dietInsightApiUrl;

  static Future<void> initialize() async {
    _instance = AppConfig._();
    await _instance._loadConfig();
  }

  Future<void> _loadConfig() async {
    // In production, these would come from secure storage or environment
    supabaseUrl = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://mmxvpogrdnblzgdeuhne.supabase.co',
    );
    supabaseAnonKey = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    openAiApiKey = const String.fromEnvironment(
      'OPENAI_API_KEY',
      defaultValue: '',
    );
    amazonAssociateTag = const String.fromEnvironment(
      'AMAZON_ASSOCIATE_TAG',
      defaultValue: '',
    );
    dietInsightApiUrl = const String.fromEnvironment(
      'DIET_INSIGHT_API_URL',
      defaultValue: 'http://localhost:8000',
    );

    if (kDebugMode) {
      print('AppConfig initialized for environment: $environment');
    }
  }
}
