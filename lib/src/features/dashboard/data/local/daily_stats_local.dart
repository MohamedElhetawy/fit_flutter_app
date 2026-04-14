import 'package:isar/isar.dart';

part 'daily_stats_local.g.dart';

@collection
class DailyStatsLocal {
  Id id = Isar.autoIncrement;

  /// ISO8601 date string, e.g., "2026-04-14"
  @Index(unique: true, replace: true)
  late String date;

  int steps = 0;
  int activeCalories = 0;
  int hydrationMl = 0;

  // Nutrition
  int caloriesConsumed = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;

  // Future proofing for smart watches / health connect advanced data
  int? heartRateAvg;
  int? spO2Avg;
  int? deepSleepMinutes;

  int totalWorkouts = 0;
}
