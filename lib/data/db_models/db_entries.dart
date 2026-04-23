import 'package:gemma4/data/models/role.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

part 'db_entries.g.dart';

@collection
class ChatSession{
  Id id = Isar.autoIncrement;
  String sessionId = const Uuid().v4();
  
  @Backlink(to: 'sessionId')
  final entries = IsarLinks<ChatEntry>();
}

@collection
class ChatEntry {
  Id id = Isar.autoIncrement;
  
  final sessionId = IsarLink<ChatSession>();

  @Backlink(to: 'chat')
  final messages = IsarLinks<Message>();
}

@collection
class Message {
  Id id = Isar.autoIncrement;

  @enumerated
  late Role role;

  late String content;

  late DateTime createdAt;
  
  final chat = IsarLink<ChatEntry>();
}
