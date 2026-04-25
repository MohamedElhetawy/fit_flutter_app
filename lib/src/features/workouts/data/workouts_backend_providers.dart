import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'workouts_backend_repository.dart';
import 'workout.dart';

final workoutsBackendRepositoryProvider =
    Provider((ref) => WorkoutsBackendRepository(ref.watch(firestoreProvider)));

final workoutsBackendStreamProvider = StreamProvider<List<Workout>>((ref) {
  return ref.watch(workoutsBackendRepositoryProvider).watchWorkouts();
});
