import 'package:flutter/foundation.dart';
import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/domain/entities/token_count.dart';
import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/domain/entities/message.dart';
import 'package:gemma4/domain/repositories/chat_repository.dart';
import 'package:gemma4/domain/services/ai_service.dart';
import 'package:gemma4/presentation/view_models/settings_view_model.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final AiService _aiService;
  final SettingsViewModel _settingsViewModel;
  final VoidCallback? onTitleGenerated;

  static const _defaultTitle = 'New Chat';

  ChatViewModel(
    this._chatRepository,
    this._aiService,
    this._settingsViewModel, {
    this.onTitleGenerated,
  });

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
  TokenCount get tokenCount =>
      TokenCount(prompt: _promptTokens, completion: _completionTokens, total: _totalTokens);
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

    if (_currentChat == null) {
      _errorMessage = 'Select or create a chat first.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _conversationHistory.add(Message(role: Role.user, content: message));

      final temperature = _settingsViewModel.settings.temperature;
      final streamResponses = _settingsViewModel.settings.streamResponses;

      if (streamResponses) {
        // Streaming path
        _conversationHistory.add(const Message(role: Role.assistant, content: ''));
        notifyListeners();

        String fullResponse = '';

        final stream = _chatRepository.sendToAiStream(
          chatId: _currentChat!.id,
          userMessage: message,
          temperature: temperature,
        );

        await for (final event in stream) {
          if (event.delta.isNotEmpty) {
            fullResponse += event.delta;
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
      } else {
        // Non-streaming path
        _conversationHistory.add(const Message(role: Role.assistant, content: ''));
        notifyListeners();

        final (content, pTokens, cTokens, tTokens) = await _chatRepository.sendToAi(
          chatId: _currentChat!.id,
          userMessage: message,
          temperature: temperature,
        );

        _conversationHistory[_conversationHistory.length - 1] = Message(
          role: Role.assistant,
          content: content,
        );
        _promptTokens = pTokens;
        _completionTokens = cTokens;
        _totalTokens = tTokens;
        notifyListeners();
      }

      // Generate title on first AI response if enabled
      if (_settingsViewModel.settings.autoTitle &&
          !_titleGenerated &&
          _currentChat?.title == _defaultTitle) {
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
