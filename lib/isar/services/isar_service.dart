import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  static Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          RestaurantSchema,
          RestaurantConfigSchema,
          RestaurantMenuSchema,
          MenuItemSchema,
          OrderSchema,
          OrderItemSchema,
          BillSchema,
          TableSchema,
          TableTimerSchema,
          ProfileSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}