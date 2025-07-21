import 'package:isar/isar.dart';

part 'test_model.g.dart';

@collection
class TestModel {
  Id id = Isar.autoIncrement;

  String? name;
}