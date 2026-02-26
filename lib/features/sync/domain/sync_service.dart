import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/utils/logger.dart';
import '../../../data/repositories/sync_repository.dart';

class SyncService {
  SyncService({required this.syncRepository});

  final SyncRepository syncRepository;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _periodicSyncTimer;

  static const String syncTaskName = 'syntropy_health_sync';
  static const Duration syncInterval = Duration(minutes: 15);

  Future<void> initialize() async {
    // Initialize workmanager for background sync
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);

    AppLogger.info('SyncService initialized', 'SyncService');
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      AppLogger.info('Connection restored, triggering sync', 'SyncService');
      syncNow();
    }
  }

  Future<void> startPeriodicSync() async {
    // Cancel any existing timer
    _periodicSyncTimer?.cancel();

    // Start periodic sync
    _periodicSyncTimer = Timer.periodic(syncInterval, (_) {
      syncNow();
    });

    // Register background task
    await Workmanager().registerPeriodicTask(
      syncTaskName,
      syncTaskName,
      frequency: syncInterval,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    AppLogger.info('Periodic sync started', 'SyncService');
  }

  Future<void> stopPeriodicSync() async {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;

    await Workmanager().cancelByUniqueName(syncTaskName);
    AppLogger.info('Periodic sync stopped', 'SyncService');
  }

  Future<SyncResult> syncNow() async {
    AppLogger.info('Starting sync...', 'SyncService');

    try {
      final result = await syncRepository.processSyncQueue();

      return result.fold(
        (failure) {
          AppLogger.error('Sync failed: ${failure.message}', 'SyncService');
          return SyncResult(
            success: false,
            message: failure.message ?? 'Sync failed',
            itemsSynced: 0,
          );
        },
        (count) {
          AppLogger.info('Sync completed: $count items', 'SyncService');
          return SyncResult(
            success: true,
            message: 'Synced $count items',
            itemsSynced: count,
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Sync error', 'SyncService', e, stackTrace);
      return SyncResult(
        success: false,
        message: 'Sync error: $e',
        itemsSynced: 0,
      );
    }
  }

  Future<int> getPendingCount() async {
    final result = await syncRepository.getPendingSyncCount();
    return result.fold(
      (failure) => 0,
      (count) => count,
    );
  }

  Future<void> dispose() async {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
  }
}

class SyncResult {
  const SyncResult({
    required this.success,
    required this.message,
    required this.itemsSynced,
  });

  final bool success;
  final String message;
  final int itemsSynced;
}

// Background task callback
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == SyncService.syncTaskName) {
      AppLogger.info('Background sync triggered', 'SyncService');
      // In a real app, would initialize services and call sync
      return true;
    }
    return false;
  });
}
