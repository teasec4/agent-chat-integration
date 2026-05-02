import 'package:gemma4/domain/entities/message.dart';
import 'package:isar_community/isar.dart';

part 'db_entries.g.dart';


@collection
class ChatEntry {
  Id id = Isar.autoIncrement;

  String title = '';
}

@collection
class Message {
  Id id = Isar.autoIncrement;

  @enumerated
  late Role role;

  late String content;

  late DateTime createdAt;

  late int chatId;
}

@collection
class AppSettings {
  Id id = 1;

  /// Whether to auto-generate chat titles
  bool autoTitle = true;

  /// Whether to stream responses
  bool streamResponses = true;

  /// Active endpoint base URL (without /v1 suffix)
  String baseUrl = 'http://localhost:1234';

  /// Active model name
  String modelName = 'google/gemma-4-e4b';

  /// Response temperature 0.0–2.0
  double temperature = 0.7;

  /// Max tokens for responses
  int maxTokens = 4096;
}

@collection
class CustomModelPreset {
  Id id = Isar.autoIncrement;

  /// Display name
  String name = '';

  /// API endpoint base URL
  String baseUrl = 'http://localhost:1234';

  /// Model name/ID
  String modelName = 'google/gemma-4-e4b';

  /// Max tokens
  int maxTokens = 4096;

  /// Temperature
  double temperature = 0.7;
}
