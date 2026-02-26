import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/remote/supabase_client.dart';
import '../../data/repositories/health_journal_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/sync_repository.dart';
import 'service_locator.dart';

// Database Provider (nullable on web)
final databaseHelperProvider = Provider<DatabaseHelper?>((ref) {
  return ServiceLocator.instance.databaseHelper;
});

// Supabase Provider
final supabaseClientProvider = Provider<SupabaseClientWrapper>((ref) {
  return ServiceLocator.instance.supabaseClient;
});

// Repository Providers
final healthJournalRepositoryProvider =
    Provider<HealthJournalRepository?>((ref) {
  final db = ref.watch(databaseHelperProvider);
  if (db == null) return null; // Not available on web
  return HealthJournalRepository(
    databaseHelper: db,
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final syncRepositoryProvider = Provider<SyncRepository?>((ref) {
  final db = ref.watch(databaseHelperProvider);
  if (db == null) return null; // Not available on web
  return SyncRepository(
    databaseHelper: db,
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository?>((ref) {
  final db = ref.watch(databaseHelperProvider);
  if (db == null) return null; // Not available on web
  return NotificationRepository(
    databaseHelper: db,
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});
