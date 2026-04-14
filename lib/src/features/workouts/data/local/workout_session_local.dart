import 'package:isar/isar.dart';

part 'workout_session_local.g.dart';

@collection
class WorkoutSessionLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String workoutId;
  late DateTime startTime;
  DateTime? endTime;

  late List<LoggedSetLocal> sets;
}

@embedded
class LoggedSetLocal {
  late String exerciseId;
  late int setNumber;
  late double weight;
  late int reps;
  late DateTime timestamp;
}
