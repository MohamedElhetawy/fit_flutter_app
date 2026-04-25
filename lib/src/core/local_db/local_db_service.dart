import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../sync/sync_event.dart';
import '../../features/workouts/data/local/exercise_local.dart';
import '../../features/workouts/data/local/workout_local.dart';
import '../../features/workouts/data/local/workout_session_local.dart';
import '../../features/dashboard/data/local/daily_stats_local.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();

  factory LocalDbService() {
    return _instance;
  }

  LocalDbService._internal();

  late Isar _isar;

  Isar get isar => _isar;

  bool _isInit = false;

  Future<void> init() async {
    if (_isInit) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        SyncEventSchema,
        ExerciseLocalSchema,
        WorkoutLocalSchema,
        WorkoutSessionLocalSchema,
        DailyStatsLocalSchema,
      ],
      directory: dir.path,
    );
    _isInit = true;
  }

  /// Closes the current Isar instance
  Future<void> close() async {
    if (_isInit) {
      await _isar.close();
      _isInit = false;
    }
  }

  /// Wipe all data (e.g., on logout)
  Future<void> wipeAll() async {
    if (!_isInit) return;
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }
}
