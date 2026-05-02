import 'package:flutter/material.dart';
import 'package:gemma4/domain/entities/settings.dart';
import 'package:gemma4/presentation/settings/widgets/preset_dialogs.dart';
import 'package:gemma4/presentation/view_models/settings_view_model.dart';

class PresetCard extends StatelessWidget {
  final CustomModelPreset preset;
  final SettingsViewModel settingsVm;
  final VoidCallback onApplied;

  const PresetCard({
    super.key,
    required this.preset,
    required this.settingsVm,
    required this.onApplied,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = preset.baseUrl == settingsVm.settings.baseUrl &&
        preset.modelName == settingsVm.settings.modelName;

    return Card(
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.smart_toy_outlined,
            size: 16,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          preset.name.isNotEmpty ? preset.name : preset.modelName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          preset.modelName,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow_rounded, size: 20, color: theme.colorScheme.primary),
              tooltip: 'Use this model',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                final updated = settingsVm.settings.copyWith(
                  baseUrl: preset.baseUrl,
                  modelName: preset.modelName,
                  temperature: preset.temperature,
                  maxTokens: preset.maxTokens,
                );
                settingsVm.saveSettings(updated);
                onApplied();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
              tooltip: 'Remove',
              visualDensity: VisualDensity.compact,
              onPressed: () => settingsVm.deletePreset(preset.id),
            ),
          ],
        ),
        onTap: () => PresetDialogs.showEdit(context, preset, settingsVm),
      ),
    );
  }
}
