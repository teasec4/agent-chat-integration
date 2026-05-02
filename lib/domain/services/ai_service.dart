import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/data/models/chat_response.dart';
import 'package:gemma4/domain/entities/stream_event.dart';

abstract class AiService {
  String get model;
  Future<ChatResponse> getAiResponse(ChatRequest request);
  Stream<StreamEvent> streamChat(ChatRequest request);

  /// Get the model's maximum context window (in tokens).
  /// Falls back to 131072 if the API doesn't provide this info.
  Future<int> getModelContext();
}
