// Core exports
export 'core/app.dart';
export 'core/config/app_config.dart';
export 'core/config/env_config.dart';
export 'core/di/providers.dart';
export 'core/di/service_locator.dart';
export 'core/router/app_router.dart';
export 'core/router/routes.dart';
export 'core/theme/app_colors.dart';
export 'core/theme/app_spacing.dart';
export 'core/theme/app_theme.dart';
export 'core/theme/app_typography.dart';
export 'core/utils/failure.dart';
export 'core/utils/logger.dart';
export 'core/utils/result.dart';
export 'core/widgets/main_scaffold.dart';

// Data exports
export 'data/models/app_notification.dart';
export 'data/models/health_journal_entry.dart';
export 'data/models/health_recommendation.dart';
export 'data/models/product.dart';
export 'data/models/voice_note.dart';
export 'data/repositories/health_journal_repository.dart';
export 'data/repositories/notification_repository.dart';
export 'data/repositories/product_repository.dart';
export 'data/repositories/sync_repository.dart';
export 'data/repositories/voice_note_repository.dart';

// Feature exports - Voice Notes
export 'features/voice_notes/domain/audio_recorder_service.dart';
export 'features/voice_notes/presentation/pages/voice_notes_page.dart';
export 'features/voice_notes/presentation/providers/voice_notes_provider.dart';

// Feature exports - Health Analysis
export 'features/health_analysis/presentation/pages/health_analysis_page.dart';
export 'features/health_analysis/presentation/providers/health_analysis_provider.dart';

// Feature exports - Notifications
export 'features/notifications/domain/notification_service.dart';
export 'features/notifications/presentation/pages/notifications_page.dart';
export 'features/notifications/presentation/providers/notifications_provider.dart';

// Feature exports - Catalog
export 'features/catalog/presentation/pages/catalog_page.dart';
export 'features/catalog/presentation/providers/catalog_provider.dart';

// Feature exports - Home
export 'features/home/presentation/pages/home_page.dart';

// Feature exports - Settings
export 'features/settings/presentation/pages/settings_page.dart';
export 'features/settings/presentation/providers/settings_provider.dart';

// Feature exports - Sync
export 'features/sync/domain/sync_service.dart';
