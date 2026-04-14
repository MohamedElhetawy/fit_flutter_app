import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local_db/local_db_service.dart';
import '../data/workout.dart';
import '../data/workouts_repository.dart';
import '../data/workouts_local_data_source.dart';

final workoutsLocalDataSourceProvider = Provider<WorkoutsLocalDataSource>((ref) {
  return WorkoutsLocalDataSource(LocalDbService().isar);
});

final workoutsRepositoryProvider = Provider<WorkoutsRepository>((ref) {
  return WorkoutsRepository(ref.watch(workoutsLocalDataSourceProvider));
});

final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  return ref.watch(workoutsRepositoryProvider).watchWorkouts();
});
