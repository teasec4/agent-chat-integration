import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/data/models/chat_response.dart';

abstract class AiService {
  String get model;
  Future<ChatResponse> getAiResponse(ChatRequest request);
}
