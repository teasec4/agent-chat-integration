import 'package:flutter/foundation.dart';
import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/domain/repositories/list_chats_repository.dart';

class ListChatViewModel extends ChangeNotifier {
  final ListChatsRepository _repository;

  ListChatViewModel(this._repository);

  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadChats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _chats = await _repository.getChats();
    } catch (e) {
      _errorMessage = 'Failed to load chats: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Chat?> createChat({String title = 'New Chat'}) async {
    try {
      final chat = await _repository.createChat(title: title);
      await loadChats(); // reload list
      return chat;
    } catch (e) {
      _errorMessage = 'Failed to create chat: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteChat(int chatId) async {
    try {
      await _repository.deleteChat(chatId);
      _chats.removeWhere((c) => c.id == chatId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete chat: $e';
      notifyListeners();
      return false;
    }
  }
}
