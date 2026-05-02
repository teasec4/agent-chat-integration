import 'package:flutter/material.dart';
import 'package:gemma4/data/db_models/db_entries.dart';
import 'package:gemma4/presentation/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  final String category;

  const SettingsPage({super.key, required this.category});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _baseUrlController;
  late TextEditingController _modelNameController;
  late TextEditingController _newNameController;
  late TextEditingController _newUrlController;
  late TextEditingController _newModelNameController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final vm = context.read<SettingsViewModel>();
    _baseUrlController = TextEditingController(text: vm.settings.baseUrl);
    _modelNameController = TextEditingController(text: vm.settings.modelName);
    _newNameController = TextEditingController();
    _newUrlController = TextEditingController(text: vm.settings.baseUrl);
    _newModelNameController = TextEditingController();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelNameController.dispose();
    _newNameController.dispose();
    _newUrlController.dispose();
    _newModelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.category) {
      case 'general':
        return _buildGeneralSettings();
      case 'model':
        return _buildModelSettings();
      default:
        return _buildEmpty();
    }
  }

  // ===================================================================
  // GENERAL SETTINGS
  // ===================================================================
  Widget _buildGeneralSettings() {
    final theme = Theme.of(context);
    final settingsVm = context.watch<SettingsViewModel>();
    final s = settingsVm.settings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(theme, 'Chat Defaults'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Auto-generate titles'),
                subtitle: const Text('Create chat title from first message'),
                value: s.autoTitle,
                onChanged: (v) {
                  final updated = s..autoTitle = v;
                  settingsVm.saveSettings(updated);
                },
                secondary: const Icon(Icons.auto_awesome_outlined),
              ),
              const Divider(height: 1, indent: 72),
              SwitchListTile(
                title: const Text('Stream responses'),
                subtitle: const Text('Show text as it arrives'),
                value: s.streamResponses,
                onChanged: (v) {
                  final updated = s..streamResponses = v;
                  settingsVm.saveSettings(updated);
                },
                secondary: const Icon(Icons.stream_outlined),
              ),
            ],
          ),
        ),

        // --- About ---
        const SizedBox(height: 32),
        _buildSectionHeader(theme, 'About'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Mini AI Chat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A local AI chat app powered by\nLM Studio & Flutter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
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

  // ===================================================================
  // MODEL SETTINGS
  // ===================================================================
  Widget _buildModelSettings() {
    final theme = Theme.of(context);
    final settingsVm = context.watch<SettingsViewModel>();
    final s = settingsVm.settings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Active Endpoint ---
        _buildSectionHeader(theme, 'Endpoint'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://localhost:1234',
                prefixIcon: Icon(Icons.link_outlined, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
                helperText: 'OpenAI-compatible API endpoint (without /v1)',
              ),
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
              onChanged: (v) {
                final updated = s..baseUrl = v.trim();
                settingsVm.saveSettings(updated);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // --- Active Model ---
        _buildSectionHeader(theme, 'Model'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _modelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Model Name',
                    hintText: 'google/gemma-4-e4b',
                    prefixIcon: Icon(Icons.smart_toy_outlined, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                    helperText: 'Model ID from the API',
                  ),
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  onChanged: (v) {
                    final updated = s..modelName = v.trim();
                    settingsVm.saveSettings(updated);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // --- Parameters ---
        _buildSectionHeader(theme, 'Parameters'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temperature slider
                Row(
                  children: [
                    const Icon(Icons.thermostat_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text('Temperature', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s.temperature.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: s.temperature,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  label: s.temperature.toStringAsFixed(1),
                  onChanged: (v) {
                    final updated = s..temperature = v;
                    settingsVm.saveSettings(updated);
                  },
                ),
                const SizedBox(height: 8),

                // Max tokens
                Row(
                  children: [
                    const Icon(Icons.format_list_numbered_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text('Max Tokens', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                    const Spacer(),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: TextEditingController(text: s.maxTokens.toString()),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            final updated = s..maxTokens = parsed;
                            settingsVm.saveSettings(updated);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // --- Saved Models ---
        _buildSectionHeader(theme, 'Saved Models'),
        const SizedBox(height: 4),
        Text(
          'Add custom model configurations to quickly switch between endpoints.',
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),

        // List of saved presets
        ...settingsVm.presets.map((preset) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildPresetCard(preset, settingsVm),
            )),

        // Add new model button
        OutlinedButton.icon(
          onPressed: () => _showAddPresetDialog(settingsVm),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Model'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
          ),
        ),

        const SizedBox(height: 32),

        // Test connection button
        Center(
          child: FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Test Connection'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPresetCard(CustomModelPreset preset, SettingsViewModel settingsVm) {
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
          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, fontFamily: 'monospace'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow_rounded, size: 20, color: theme.colorScheme.primary),
              tooltip: 'Use this model',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                final s = settingsVm.settings;
                final updated = s
                  ..baseUrl = preset.baseUrl
                  ..modelName = preset.modelName
                  ..temperature = preset.temperature
                  ..maxTokens = preset.maxTokens;
                _baseUrlController.text = preset.baseUrl;
                _modelNameController.text = preset.modelName;
                settingsVm.saveSettings(updated);
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
        onTap: () => _showEditPresetDialog(preset, settingsVm),
      ),
    );
  }

  void _showAddPresetDialog(SettingsViewModel settingsVm) {
    _newNameController.clear();
    _newUrlController.text = settingsVm.settings.baseUrl;
    _newModelNameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Model'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'e.g. Local LLM',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'http://localhost:1234',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.link_outlined, size: 20),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newModelNameController,
                decoration: const InputDecoration(
                  labelText: 'Model Name',
                  hintText: 'google/gemma-4-e4b',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.smart_toy_outlined, size: 20),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = _newNameController.text.trim();
              final url = _newUrlController.text.trim();
              final modelName = _newModelNameController.text.trim();
              if (url.isNotEmpty && modelName.isNotEmpty) {
                final preset = CustomModelPreset()
                  ..name = name
                  ..baseUrl = url
                  ..modelName = modelName;
                settingsVm.savePreset(preset);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditPresetDialog(CustomModelPreset preset, SettingsViewModel settingsVm) {
    final nameCtrl = TextEditingController(text: preset.name);
    final urlCtrl = TextEditingController(text: preset.baseUrl);
    final modelCtrl = TextEditingController(text: preset.modelName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Model'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.link_outlined, size: 20),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Model Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.smart_toy_outlined, size: 20),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              preset.name = nameCtrl.text.trim();
              preset.baseUrl = urlCtrl.text.trim();
              preset.modelName = modelCtrl.text.trim();
              settingsVm.savePreset(preset);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // HELPERS
  // ===================================================================
  Widget _buildSectionHeader(ThemeData theme, String title) {
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

  Widget _buildEmpty() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.settings_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
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
