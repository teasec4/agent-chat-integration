import 'package:gemma4/data/db_models/db_entries.dart';
import 'package:gemma4/domain/repositories/settings_repository.dart';
import 'package:isar_community/isar.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;

  SettingsRepositoryImpl(this._isar);

  @override
  Future<AppSettings> getSettings() async {
    return _isar.writeTxn(() async {
      final existing = await _isar.appSettings.get(1);
      if (existing != null) return existing;

      // Create default settings singleton
      final defaults = AppSettings();
      await _isar.appSettings.put(defaults);
      return defaults;
    });
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }

  @override
  Future<List<CustomModelPreset>> getPresets() async {
    return _isar.writeTxn(() async {
      return _isar.customModelPresets.where().findAll();
    });
  }

  @override
  Future<int> savePreset(CustomModelPreset preset) async {
    return _isar.writeTxn(() async {
      return _isar.customModelPresets.put(preset);
    });
  }

  @override
  Future<void> deletePreset(int id) async {
    await _isar.writeTxn(() async {
      await _isar.customModelPresets.delete(id);
    });
  }
}
