import 'package:flutter/foundation.dart';
import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/domain/entities/message.dart';
import 'package:gemma4/domain/repositories/chat_repository.dart';
import 'package:gemma4/domain/services/ai_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final AiService _aiService;
  final VoidCallback? onTitleGenerated;

  static const _defaultTitle = 'New Chat';

  ChatViewModel(this._chatRepository, this._aiService, {this.onTitleGenerated});

  Chat? _currentChat;
  final List<Message> _conversationHistory = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _titleGenerated = false;

  int _promptTokens = 0;
  int _completionTokens = 0;
  int _totalTokens = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get promptTokens => _promptTokens;
  int get completionTokens => _completionTokens;
  int get totalTokens => _totalTokens;
  Chat? get currentChat => _currentChat;
  String get model => _chatRepository.model;
  List<Message> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  Future<void> loadChat(int chatId) async {
    _errorMessage = null;
    _titleGenerated = false;
    _currentChat = await _chatRepository.getChatById(chatId);
    debugPrint('[loadChat] chatId=$chatId, found=${_currentChat != null} id=${_currentChat?.id}');
    if (_currentChat != null) {
      final messages = await _chatRepository.getMessagesForChat(_currentChat!.id);
      debugPrint('[loadChat] messages count=${messages.length}');
      _conversationHistory
        ..clear()
        ..addAll(messages);
    } else {
      debugPrint('[loadChat] chat NOT FOUND for id=$chatId');
    }
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      _conversationHistory.add(Message(role: Role.user, content: message));

      // Add placeholder for streaming AI response
      _conversationHistory.add(const Message(role: Role.assistant, content: ''));
      notifyListeners();

      final stream = _chatRepository.sendToAiStream(
        chatId: _currentChat!.id,
        userMessage: message,
      );

      String fullResponse = '';

      await for (final event in stream) {
        if (event.delta.isNotEmpty) {
          fullResponse += event.delta;
          // Update the last message (AI placeholder) with accumulated content
          _conversationHistory[_conversationHistory.length - 1] = Message(
            role: Role.assistant,
            content: fullResponse,
          );
          notifyListeners();
        }

        if (event.isFinished) {
          _promptTokens = event.promptTokens;
          _completionTokens = event.completionTokens;
          _totalTokens = event.totalTokens;
        }
      }

      // Generate title on first AI response if still default
      if (!_titleGenerated && _currentChat?.title == _defaultTitle) {
        await _generateAndSetTitle(message);
      }
    } catch (e) {
      // Remove the optimistically added user message and partial AI message
      _conversationHistory.removeRange(
        _conversationHistory.length - 2,
        _conversationHistory.length,
      );
      _errorMessage = 'Error: ${e.toString().replaceFirst('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _generateAndSetTitle(String firstUserMessage) async {
    try {
      final titleRequest = ChatRequest(
        model: _chatRepository.model,
        messages: [
          ApiMessage(
            role: Role.system,
            content:
                'Generate a very short title (2-3 words) summarizing this chat. '
                'First message: "$firstUserMessage". '
                'Respond ONLY with the title, no quotes, no punctuation.',
          ),
        ],
        temperature: 0.1,
        stream: false,
      );

      final response = await _aiService.getAiResponse(titleRequest);
      final title = response.choices.firstOrNull?.message.content.trim();

      if (title != null && title.isNotEmpty) {
        await _chatRepository.updateChatTitle(_currentChat!.id, title);
        _currentChat = Chat(id: _currentChat!.id, title: title);
        _titleGenerated = true;
        onTitleGenerated?.call();
      }
    } catch (e) {
      // Title generation is non-critical — silently ignore failures
      debugPrint('[titleGen] failed: $e');
    }
  }
}
