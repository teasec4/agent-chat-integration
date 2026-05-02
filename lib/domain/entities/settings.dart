/// Pure domain entity for app settings.
/// No Isar annotations — data layer maps to this.
class AppSettings {
  final bool autoTitle;
  final bool streamResponses;
  final String baseUrl;
  final String modelName;
  final double temperature;
  final int maxTokens;

  const AppSettings({
    this.autoTitle = true,
    this.streamResponses = true,
    this.baseUrl = 'http://localhost:1234',
    this.modelName = 'google/gemma-4-e4b',
    this.temperature = 0.7,
    this.maxTokens = 4096,
  });

  AppSettings copyWith({
    bool? autoTitle,
    bool? streamResponses,
    String? baseUrl,
    String? modelName,
    double? temperature,
    int? maxTokens,
  }) {
    return AppSettings(
      autoTitle: autoTitle ?? this.autoTitle,
      streamResponses: streamResponses ?? this.streamResponses,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}

/// Pure domain entity for a saved model preset.
/// No Isar annotations — data layer maps to this.
class CustomModelPreset {
  final int id;
  final String name;
  final String baseUrl;
  final String modelName;
  final int maxTokens;
  final double temperature;

  const CustomModelPreset({
    this.id = 0,
    this.name = '',
    this.baseUrl = 'http://localhost:1234',
    this.modelName = 'google/gemma-4-e4b',
    this.maxTokens = 4096,
    this.temperature = 0.7,
  });

  CustomModelPreset copyWith({
    int? id,
    String? name,
    String? baseUrl,
    String? modelName,
    int? maxTokens,
    double? temperature,
  }) {
    return CustomModelPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
    );
  }
}
