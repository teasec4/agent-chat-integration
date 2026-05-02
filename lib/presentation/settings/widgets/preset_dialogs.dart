import 'package:flutter/material.dart';
import 'package:gemma4/domain/entities/settings.dart';
import 'package:gemma4/presentation/view_models/settings_view_model.dart';

class PresetDialogs {
  static Future<void> showAdd(BuildContext context, SettingsViewModel settingsVm) {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: settingsVm.settings.baseUrl);
    final modelCtrl = TextEditingController();
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Model'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'e.g. Local LLM',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
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
                controller: modelCtrl,
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
              final name = nameCtrl.text.trim();
              final url = urlCtrl.text.trim();
              final modelName = modelCtrl.text.trim();
              if (url.isNotEmpty && modelName.isNotEmpty) {
                settingsVm.savePreset(CustomModelPreset(
                  name: name,
                  baseUrl: url,
                  modelName: modelName,
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future<void> showEdit(
      BuildContext context, CustomModelPreset preset, SettingsViewModel settingsVm) {
    final nameCtrl = TextEditingController(text: preset.name);
    final urlCtrl = TextEditingController(text: preset.baseUrl);
    final modelCtrl = TextEditingController(text: preset.modelName);
    return showDialog(
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
              final updated = preset.copyWith(
                name: nameCtrl.text.trim(),
                baseUrl: urlCtrl.text.trim(),
                modelName: modelCtrl.text.trim(),
              );
              settingsVm.savePreset(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
