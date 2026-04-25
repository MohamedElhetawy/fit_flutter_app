import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitx/src/core/providers/local_db_provider.dart';
import '../data/workout.dart';
import '../data/workouts_repository.dart';
import '../data/workouts_local_data_source.dart';

final workoutsLocalDataSourceProvider = FutureProvider<WorkoutsLocalDataSource>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return WorkoutsLocalDataSource(isar);
});

final workoutsRepositoryProvider = FutureProvider<WorkoutsRepository>((ref) async {
  final local = await ref.watch(workoutsLocalDataSourceProvider.future);
  return WorkoutsRepository(local);
});

final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  return ref.watch(workoutsRepositoryProvider.future).then((repo) => repo.watchWorkouts()).asStream().asyncExpand((s) => s);
});
