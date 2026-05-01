import 'package:gemma4/data/db_models/db_entries.dart' as db;
import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/domain/repositories/list_chats_repository.dart';
import 'package:isar_community/isar.dart';

class ListChatRepositoryImpl implements ListChatsRepository {
  final Isar _isar;

  ListChatRepositoryImpl(this._isar);

  // --- mapper ---

  Chat _toDomain(db.ChatEntry entry) => Chat(
    id: entry.id,
    title: entry.title,
  );

  // --- interface implementation ---

  @override
  Future<Chat> createChat({String title = 'New Chat'}) async {
    final chat = db.ChatEntry()..title = title;
    await _isar.writeTxn(() async {
      final id = await _isar.chatEntrys.put(chat);
      chat.id = id;
    });
    return _toDomain(chat);
  }

  @override
  Future<List<Chat>> getChats() async {
    final entries = await _isar.chatEntrys.where().findAll();
    return entries.map(_toDomain).toList();
  }

  @override
  Future<void> deleteChat(int chatId) async {
    await _isar.writeTxn(() async {
      await _isar.messages
          .filter()
          .chatIdEqualTo(chatId)
          .deleteAll();
      await _isar.chatEntrys.delete(chatId);
    });
  }
}
