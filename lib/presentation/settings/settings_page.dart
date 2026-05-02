import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final String category;

  const SettingsPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case 'general':
        return _buildGeneralSettings(context);
      case 'model':
        return _buildModelSettings(context);
      case 'about':
        return _buildAboutPage(context);
      default:
        return _buildEmpty(context);
    }
  }

  Widget _buildGeneralSettings(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (_) {},
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Language'),
                  subtitle: const Text('System default'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chat defaults',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-generate titles'),
                  subtitle: const Text('Create chat title from first message'),
                  value: true,
                  onChanged: (_) {},
                  secondary: const Icon(Icons.auto_awesome_outlined),
                ),
                const Divider(height: 1, indent: 72),
                SwitchListTile(
                  title: const Text('Stream responses'),
                  subtitle: const Text('Show text as it arrives'),
                  value: true,
                  onChanged: (_) {},
                  secondary: const Icon(Icons.stream_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'More settings coming soon',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSettings(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Endpoint',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.link_outlined),
                  title: const Text('API URL'),
                  subtitle: const Text('http://localhost:1234/v1'),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Model',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.smart_toy_outlined),
                  title: const Text('Model'),
                  subtitle: const Text('google/gemma-4-e4b'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.thermostat_outlined),
                  title: const Text('Temperature'),
                  subtitle: const Text('0.7'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.format_list_numbered_outlined),
                  title: const Text('Max tokens'),
                  subtitle: const Text('4096'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Test Connection'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutPage(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.smart_toy_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Mini AI Chat',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'A local AI chat app powered by\nLM Studio & Flutter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.code_outlined, size: 18),
                label: const Text('Open Source Licenses'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Unknown category',
            style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
