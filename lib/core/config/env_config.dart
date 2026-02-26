abstract class EnvConfig {
  String get supabaseUrl;
  String get supabaseAnonKey;
  String get openAiApiKey;
  String get dietInsightApiUrl;
  String get amazonAssociateTag;
  bool get enableAnalytics;
  bool get enableCrashReporting;
}

class DevelopmentConfig implements EnvConfig {
  @override
  String get supabaseUrl => 'https://mmxvpogrdnblzgdeuhne.supabase.co';

  @override
  String get supabaseAnonKey => '';

  @override
  String get openAiApiKey => '';

  @override
  String get dietInsightApiUrl => 'http://localhost:8000';

  @override
  String get amazonAssociateTag => '';

  @override
  bool get enableAnalytics => false;

  @override
  bool get enableCrashReporting => false;
}

class ProductionConfig implements EnvConfig {
  @override
  String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL');

  @override
  String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  @override
  String get openAiApiKey => const String.fromEnvironment('OPENAI_API_KEY');

  @override
  String get dietInsightApiUrl =>
      const String.fromEnvironment('DIET_INSIGHT_API_URL');

  @override
  String get amazonAssociateTag =>
      const String.fromEnvironment('AMAZON_ASSOCIATE_TAG');

  @override
  bool get enableAnalytics => true;

  @override
  bool get enableCrashReporting => true;
}
