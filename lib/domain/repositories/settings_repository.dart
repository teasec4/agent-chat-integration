import 'package:gemma4/domain/entities/settings.dart';

/// Repository for app settings and custom model presets.
abstract class SettingsRepository {
  /// Load current app settings (creates default singleton if none exist).
  Future<AppSettings> getSettings();

  /// Save app settings.
  Future<void> saveSettings(AppSettings settings);

  /// Get all custom model presets.
  Future<List<CustomModelPreset>> getPresets();

  /// Save a custom model preset. Returns its new ID.
  Future<int> savePreset(CustomModelPreset preset);

  /// Delete a custom model preset by ID.
  Future<void> deletePreset(int id);
}
