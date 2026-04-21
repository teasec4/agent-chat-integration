import 'package:gemma4/data/models/role.dart';
import 'package:isar_community/isar.dart';

part 'db_entries.g.dart';

@collection
class ChatEntry {
  Id id = Isar.autoIncrement;

  @Backlink(to: 'chat')
  final messages = IsarLinks<Message>();
}

@collection
class Message {
  Id id = Isar.autoIncrement;

  late Role role;

  late String content;

  late DateTime createdAt;
}
