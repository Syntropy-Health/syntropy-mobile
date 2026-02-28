import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';
import '../theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.checkIn)) return 1;
    if (location.startsWith(Routes.healthAnalysis)) return 2;
    if (location.startsWith(Routes.catalog)) return 3;
    if (location.startsWith(Routes.settings)) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.checkIn);
        break;
      case 2:
        context.go(Routes.healthAnalysis);
        break;
      case 3:
        context.go(Routes.catalog);
        break;
      case 4:
        context.go(Routes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: AppColors.primary),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights, color: AppColors.primary),
            label: 'Analysis',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
