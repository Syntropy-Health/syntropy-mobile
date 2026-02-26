import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load configuration first (needed by ServiceLocator)
  await AppConfig.initialize();

  // Initialize services
  await ServiceLocator.initialize();

  runApp(
    const ProviderScope(
      child: SyntropyApp(),
    ),
  );
}
