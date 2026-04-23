import 'package:flutter/foundation.dart';
import 'package:gemma4/data/db_models/db_entries.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDbProvider extends ChangeNotifier {
  late Isar isar;

  IsarDbProvider(this.isar) : super();

  Future<void> open(List<CollectionSchema> schemas) async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(schemas, directory: dir.path);
    this.isar = isar;
    notifyListeners();
  }
}


const List<CollectionSchema> schemas = [
  ChatSessionSchema,
  ChatEntrySchema,
  MessageSchema
];
