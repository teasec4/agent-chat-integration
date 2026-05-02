import 'package:flutter/foundation.dart';
import 'package:gemma4/data/db_models/db_entries.dart';
import 'package:gemma4/domain/repositories/settings_repository.dart';

/// ViewModel for app settings.
/// Loads settings on init, exposes them for read, saves on write.
/// No business logic — pure data persistence.
class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;

  SettingsViewModel(this._repository);

  /// Ensure settings are loaded (call in DI after creating VM).
  Future<void> ensureLoaded() async {
    await _load();
  }

  AppSettings _settings = AppSettings();
  List<CustomModelPreset> _presets = [];
  bool _loaded = false;

  AppSettings get settings => _settings;
  List<CustomModelPreset> get presets => List.unmodifiable(_presets);
  bool get loaded => _loaded;

  Future<void> _load() async {
    try {
      _settings = await _repository.getSettings();
      _presets = await _repository.getPresets();
      _loaded = true;
    } catch (e) {
      debugPrint('[SettingsVM] load failed: $e');
    }
    notifyListeners();
  }

  Future<void> reload() async {
    await _load();
  }

  Future<void> saveSettings(AppSettings updated) async {
    _settings = updated;
    await _repository.saveSettings(updated);
    notifyListeners();
  }

  Future<void> savePreset(CustomModelPreset preset) async {
    await _repository.savePreset(preset);
    _presets = await _repository.getPresets();
    notifyListeners();
  }

  Future<void> deletePreset(int id) async {
    await _repository.deletePreset(id);
    _presets = await _repository.getPresets();
    notifyListeners();
  }
}
