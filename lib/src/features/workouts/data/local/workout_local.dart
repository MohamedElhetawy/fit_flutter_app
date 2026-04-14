import 'package:isar/isar.dart';

part 'workout_local.g.dart';

@collection
class WorkoutLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String title;
  late String coach;
  late String image;
  late double price;
  int? discountPercent;
}
