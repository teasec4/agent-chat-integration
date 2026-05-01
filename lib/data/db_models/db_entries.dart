import 'package:gemma4/domain/entities/message.dart';
import 'package:isar_community/isar.dart';

part 'db_entries.g.dart';


@collection
class ChatEntry {
  Id id = Isar.autoIncrement;

  String title = '';
}

@collection
class Message {
  Id id = Isar.autoIncrement;

  @enumerated
  late Role role;

  late String content;

  late DateTime createdAt;

  late int chatId;
}
