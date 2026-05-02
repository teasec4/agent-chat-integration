import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/data/models/chat_response.dart';
import 'package:gemma4/domain/entities/stream_event.dart';

abstract class AiService {
  String get model;
  Future<ChatResponse> getAiResponse(ChatRequest request);
  Stream<StreamEvent> streamChat(ChatRequest request);
}
