import 'package:gemma4/domain/entities/chat.dart';

abstract class ListChatsRepository {
  Future<Chat> createChat({String title = 'Новый чат'});
  Future<List<Chat>> getChats();
  Future<void> deleteChat(int chatId);
}
