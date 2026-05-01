import 'package:gemma4/domain/entities/chat.dart';

abstract class ListChatsRepository {
  Future<Chat> createChat({String title = 'New Chat'});
  Future<List<Chat>> getChats();
  Future<void> deleteChat(int chatId);
  Future<void> updateChatTitle(int chatId, String title);
}
