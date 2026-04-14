import 'package:isar/isar.dart';

part 'exercise_local.g.dart';

@collection
class ExerciseLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String nameAr;
  late String nameEn;
  late String mainCategory;
  late String bodyPart;
  late String muscleGroup;
  late String muscleAngle;
  late String equipment;
  late String difficulty;
  late String gifUrl;

  /// Used to map from json easily
  void fromJson(Map<String, dynamic> json) {
    originalId = json['id'] as String;
    nameAr = json['name_ar'] as String;
    nameEn = json['name_en'] as String;
    mainCategory = json['main_category'] as String;
    bodyPart = json['body_part'] as String;
    muscleGroup = json['muscle_group'] as String;
    muscleAngle = json['muscle_angle'] as String;
    equipment = json['equipment'] as String;
    difficulty = json['difficulty'] as String;
    gifUrl = json['gif_url'] as String;
  }
}
