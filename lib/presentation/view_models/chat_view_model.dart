import 'package:flutter/foundation.dart';
import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/domain/entities/message.dart';
import 'package:gemma4/domain/repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatViewModel(this._chatRepository);

  Chat? _currentChat;
  final List<Message> _conversationHistory = [];

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
  Chat? get currentChat => _currentChat;
  String get model => _chatRepository.model;
  List<Message> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  Future<void> loadChat(int chatId) async {
    _errorMessage = null;
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

      final (
        aiContent,
        promptTokens,
        completionTokens,
        totalTokens,
      ) = await _chatRepository.sendToAi(
        chatId: _currentChat!.id,
        userMessage: message,
      );

      _promptTokens = promptTokens;
      _completionTokens = completionTokens;
      _totalTokens = totalTokens;

      _conversationHistory.add(Message(role: Role.assistant, content: aiContent));
    } catch (e) {
      // Remove the optimistically added user message
      _conversationHistory.removeLast();
      _errorMessage = 'Ошибка: ${e.toString().replaceFirst('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
