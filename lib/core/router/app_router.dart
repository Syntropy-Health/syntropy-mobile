import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/health_analysis/presentation/pages/health_analysis_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/voice_notes/presentation/pages/voice_notes_page.dart';
import '../widgets/main_scaffold.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: Routes.homeName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: Routes.voiceNotes,
            name: Routes.voiceNotesName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VoiceNotesPage(),
            ),
          ),
          GoRoute(
            path: Routes.healthAnalysis,
            name: Routes.healthAnalysisName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HealthAnalysisPage(),
            ),
          ),
          GoRoute(
            path: Routes.catalog,
            name: Routes.catalogName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CatalogPage(),
            ),
          ),
          GoRoute(
            path: Routes.notifications,
            name: Routes.notificationsName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationsPage(),
            ),
          ),
          GoRoute(
            path: Routes.settings,
            name: Routes.settingsName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
