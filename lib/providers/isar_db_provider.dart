
import 'package:gemma4/data/db_models/db_entries.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDbProvider{

  Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(IsarDbProvider.schemas, directory: dir.path);
    return isar;
  }
  
  static const List<CollectionSchema> schemas = [
    ChatEntrySchema,
    MessageSchema,
    AppSettingsSchema,
    CustomModelPresetSchema,
  ];
}
