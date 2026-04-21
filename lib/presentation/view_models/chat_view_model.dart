import 'package:flutter/foundation.dart';
import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/data/models/role.dart';
import 'package:gemma4/service/api/gemma_api_service.dart';

class ChatViewModel extends ChangeNotifier {
  final GemmaApiService _gemmaApiService = GemmaApiService();

  List<Message> conversationHistory = [];

  bool _isLoading = false;
  String? _errorMessage;

  int _promptTokens = 0;
  int _completionTokens = 0;
  int _totalTokens = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get promptTokens => _promptTokens;
  int get completionTokens => _completionTokens;
  int get totalTokens => _totalTokens;

  Future<void> sendMessage(String message) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final newUserMessage = Message(role: Role.user, content: message);
      conversationHistory.add(newUserMessage);

      final request = ChatRequest(
        model: 'gemma4',
        messages: conversationHistory,
        temperature: 0.7,
        stream: false,
      );

      final response = await _gemmaApiService.getAiResponse(request);

      _promptTokens = response.promptTokens;
      _completionTokens = response.completionTokens;
      _totalTokens = response.totalTokens;

      final aiContent =
          response.choices.first?.message.content ??
          "Ошибка: Ответ не содержит контента.";
      final newAssistantMessage = Message(
        role: Role.assistant,
        content: aiContent,
      );
      conversationHistory.add(newAssistantMessage);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }
}
