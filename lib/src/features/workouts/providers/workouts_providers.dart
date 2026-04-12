import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../data/workout.dart';
import '../data/workouts_repository.dart';

final workoutsRepositoryProvider = Provider<WorkoutsRepository>((ref) {
  return WorkoutsRepository(ref.watch(firestoreProvider));
});

final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  return ref.watch(workoutsRepositoryProvider).watchWorkouts();
});
