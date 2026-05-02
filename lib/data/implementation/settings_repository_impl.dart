import 'package:gemma4/data/db_models/db_entries.dart' as db;
import 'package:gemma4/domain/entities/settings.dart';
import 'package:gemma4/domain/repositories/settings_repository.dart';
import 'package:isar_community/isar.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;

  SettingsRepositoryImpl(this._isar);

  @override
  Future<AppSettings> getSettings() async {
    return _isar.writeTxn(() async {
      final existing = await _isar.appSettings.get(1);
      if (existing != null) return _toDomainSettings(existing);

      // Create default settings singleton
      final defaults = _toDataSettings(const AppSettings());
      await _isar.appSettings.put(defaults);
      return const AppSettings();
    });
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(_toDataSettings(settings));
    });
  }

  @override
  Future<List<CustomModelPreset>> getPresets() async {
    return _isar.writeTxn(() async {
      final data = await _isar.customModelPresets.where().findAll();
      return data.map(_toDomainPreset).toList();
    });
  }

  @override
  Future<int> savePreset(CustomModelPreset preset) async {
    return _isar.writeTxn(() async {
      return _isar.customModelPresets.put(_toDataPreset(preset));
    });
  }

  @override
  Future<void> deletePreset(int id) async {
    await _isar.writeTxn(() async {
      await _isar.customModelPresets.delete(id);
    });
  }

  // ── Mapping helpers ────────────────────────────────────────────

  static AppSettings _toDomainSettings(db.AppSettings d) {
    return AppSettings(
      autoTitle: d.autoTitle,
      streamResponses: d.streamResponses,
      baseUrl: d.baseUrl,
      modelName: d.modelName,
      temperature: d.temperature,
      maxTokens: d.maxTokens,
    );
  }

  static db.AppSettings _toDataSettings(AppSettings d) {
    final entry = db.AppSettings();
    entry.id = 1;
    entry.autoTitle = d.autoTitle;
    entry.streamResponses = d.streamResponses;
    entry.baseUrl = d.baseUrl;
    entry.modelName = d.modelName;
    entry.temperature = d.temperature;
    entry.maxTokens = d.maxTokens;
    return entry;
  }

  static CustomModelPreset _toDomainPreset(db.CustomModelPreset d) {
    return CustomModelPreset(
      id: d.id,
      name: d.name,
      baseUrl: d.baseUrl,
      modelName: d.modelName,
      maxTokens: d.maxTokens,
      temperature: d.temperature,
    );
  }

  static db.CustomModelPreset _toDataPreset(CustomModelPreset d) {
    final entry = db.CustomModelPreset();
    if (d.id != 0) entry.id = d.id;
    entry.name = d.name;
    entry.baseUrl = d.baseUrl;
    entry.modelName = d.modelName;
    entry.maxTokens = d.maxTokens;
    entry.temperature = d.temperature;
    return entry;
  }
}
