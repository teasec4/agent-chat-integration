import 'package:flutter/material.dart';
import 'package:gemma4/presentation/settings/widgets/preset_card.dart';
import 'package:gemma4/presentation/settings/widgets/preset_dialogs.dart';
import 'package:gemma4/presentation/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';

class ModelSection extends StatefulWidget {
  const ModelSection({super.key});

  @override
  State<ModelSection> createState() => _ModelSectionState();
}

class _ModelSectionState extends State<ModelSection> {
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _modelNameCtrl;

  @override
  void initState() {
    super.initState();
    _initCtrls();
  }

  void _initCtrls() {
    final vm = context.read<SettingsViewModel>();
    _baseUrlCtrl = TextEditingController(text: vm.settings.baseUrl);
    _modelNameCtrl = TextEditingController(text: vm.settings.modelName);
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _modelNameCtrl.dispose();
    super.dispose();
  }

  void _onPresetApplied() {
    final vm = context.read<SettingsViewModel>();
    _baseUrlCtrl.text = vm.settings.baseUrl;
    _modelNameCtrl.text = vm.settings.modelName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsVm = context.watch<SettingsViewModel>();
    final s = settingsVm.settings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(theme, 'Endpoint'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _baseUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://localhost:1234',
                prefixIcon: Icon(Icons.link_outlined, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
                helperText: 'OpenAI-compatible API endpoint (without /v1)',
              ),
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
              onChanged: (v) => settingsVm.saveSettings(s.copyWith(baseUrl: v.trim())),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _header(theme, 'Model'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _modelNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Model Name',
                hintText: 'google/gemma-4-e4b',
                prefixIcon: Icon(Icons.smart_toy_outlined, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
                helperText: 'Model ID from the API',
              ),
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
              onChanged: (v) => settingsVm.saveSettings(s.copyWith(modelName: v.trim())),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _header(theme, 'Parameters'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thermostat_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text('Temperature',
                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
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
                  onChanged: (v) => settingsVm.saveSettings(s.copyWith(temperature: v)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.format_list_numbered_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text('Max Tokens',
                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            settingsVm.saveSettings(s.copyWith(maxTokens: parsed));
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
        _header(theme, 'Saved Models'),
        const SizedBox(height: 4),
        Text(
          'Add custom model configurations to quickly switch between endpoints.',
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        ...settingsVm.presets.map((preset) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: PresetCard(
                preset: preset,
                settingsVm: settingsVm,
                onApplied: _onPresetApplied,
              ),
            )),
        OutlinedButton.icon(
          onPressed: () => PresetDialogs.showAdd(context, settingsVm),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Model'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        ),
        const SizedBox(height: 32),
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
