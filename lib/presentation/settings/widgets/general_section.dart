import 'package:flutter/material.dart';
import 'package:gemma4/presentation/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';

class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsVm = context.watch<SettingsViewModel>();
    final s = settingsVm.settings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(theme, 'Chat Defaults'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Auto-generate titles'),
                subtitle: const Text('Create chat title from first message'),
                value: s.autoTitle,
                onChanged: (v) => settingsVm.saveSettings(s.copyWith(autoTitle: v)),
                secondary: const Icon(Icons.auto_awesome_outlined),
              ),
              const Divider(height: 1, indent: 72),
              SwitchListTile(
                title: const Text('Stream responses'),
                subtitle: const Text('Show text as it arrives'),
                value: s.streamResponses,
                onChanged: (v) => settingsVm.saveSettings(s.copyWith(streamResponses: v)),
                secondary: const Icon(Icons.stream_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _header(theme, 'About'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy_outlined, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text('Mini AI Chat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('Version 1.0.0',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                Text('A local AI chat app powered by\nLM Studio & Flutter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.code_outlined, size: 18),
                  label: const Text('Open Source Licenses'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bug_report_outlined, size: 16),
                  label: const Text('Report an Issue'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
