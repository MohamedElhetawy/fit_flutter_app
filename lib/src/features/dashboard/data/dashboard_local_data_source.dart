import 'package:isar/isar.dart';
import 'local/daily_stats_local.dart';

class DashboardLocalDataSource {
  DashboardLocalDataSource(this._isar);

  final Isar _isar;

  /// Fast update for sensor fusion steps/calories.
  /// Using putSync to immediately upsert the exact day without async overhead
  /// to prevent locking during high frequency callbacks (like accelerometer).
  void updateStepsAndCaloriesSync(String dateStr, int steps, int activeCalories) {
    _isar.writeTxnSync(() {
      final existing = _isar.dailyStatsLocals.filter().dateEqualTo(dateStr).findFirstSync() ?? DailyStatsLocal()..date = dateStr;
      
      // Prevent regression if an asynchronous provider pushes older data
      if (steps > existing.steps) existing.steps = steps;
      if (activeCalories > existing.activeCalories) existing.activeCalories = activeCalories;
      
      _isar.dailyStatsLocals.putSync(existing);
    });
  }

  /// Add hydration (increments current value)
  Future<int> addHydration(String dateStr, int hydrationMl) async {
    int total = 0;
    await _isar.writeTxn(() async {
      final existing = await _isar.dailyStatsLocals.filter().dateEqualTo(dateStr).findFirst() ?? DailyStatsLocal()..date = dateStr;
      existing.hydrationMl += hydrationMl;
      await _isar.dailyStatsLocals.put(existing);
      total = existing.hydrationMl;
    });
    return total;
  }

  // Pre-sorted chart-ready streams
  
  Stream<List<DailyStatsLocal>> watchHistoricalStats(int daysPrevious) {
    if (daysPrevious <= 0) return Stream.value([]);
    
    final thresholdDate = DateTime.now().subtract(Duration(days: daysPrevious));
    final thresholdStr = "${thresholdDate.year}-${thresholdDate.month.toString().padLeft(2, '0')}-${thresholdDate.day.toString().padLeft(2, '0')}";

    return _isar.dailyStatsLocals
        .filter()
        .dateGreaterThan(thresholdStr)
        .sortByDate()
        .watch(fireImmediately: true);
  }

  Stream<DailyStatsLocal?> watchTodayStats(String todayDateStr) {
    // Watch specifically today's object updates
    return _isar.dailyStatsLocals.filter().dateEqualTo(todayDateStr).watch(fireImmediately: true).map((list) {
      if (list.isNotEmpty) return list.first;
      return null;
    });
  }
}
