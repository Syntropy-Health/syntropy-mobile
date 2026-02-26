import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // Profile Section
          _buildSection(
            context,
            title: 'Profile',
            children: [
              _buildProfileTile(context),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Preferences Section
          _buildSection(
            context,
            title: 'Preferences',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Health tips and reminders'),
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setNotificationsEnabled(value);
                },
              ),
              SwitchListTile(
                title: const Text('Auto-sync'),
                subtitle: const Text('Sync data when connected'),
                value: settings.autoSyncEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setAutoSyncEnabled(value);
                },
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: settings.darkModeEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDarkModeEnabled(value);
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Data & Privacy Section
          _buildSection(
            context,
            title: 'Data & Privacy',
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_sync),
                title: const Text('Sync Status'),
                subtitle: const Text('Last synced: Just now'),
                trailing: TextButton(
                  onPressed: () {
                    // TODO: Trigger sync
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing...')),
                    );
                  },
                  child: const Text('Sync Now'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export Data'),
                subtitle: const Text('Download your health data'),
                onTap: () {
                  // TODO: Export data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export coming soon')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(
                  'Delete All Data',
                  style: TextStyle(color: AppColors.error),
                ),
                subtitle: const Text('Permanently remove all your data'),
                onTap: () => _showDeleteConfirmation(context),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Integrations Section
          _buildSection(
            context,
            title: 'Integrations',
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Connected Services'),
                subtitle: const Text('Manage API connections'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show integrations
                },
              ),
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text('API Keys'),
                subtitle: const Text('Configure OpenAI, Supabase'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show API key settings
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // About Section
          _buildSection(
            context,
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                onTap: () {
                  // TODO: Show terms
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () {
                  // TODO: Show help
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Logout Button
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(
                'Sign Out',
                style: TextStyle(color: AppColors.error),
              ),
              onPressed: () {
                // TODO: Sign out
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign out coming soon')),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.person, color: AppColors.primary),
      ),
      title: const Text('Demo User'),
      subtitle: const Text('demo@syntropyhealth.com'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Edit profile
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This action cannot be undone. All your health journal entries, '
          'voice notes, and recommendations will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete all data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data deletion coming soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
