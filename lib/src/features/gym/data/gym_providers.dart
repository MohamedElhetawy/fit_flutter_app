import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'gym_repository.dart';
import 'gym_models.dart';

final gymRepositoryProvider =
    Provider((ref) => GymRepository(ref.watch(firestoreProvider)));

final gymOverviewProvider =
    StreamProvider.family<GymOverview, String>((ref, gymId) {
  return ref.watch(gymRepositoryProvider).watchGymOverview(gymId);
});

final gymTrainersProvider =
    StreamProvider.family<List<Trainer>, String>((ref, gymId) {
  return ref.watch(gymRepositoryProvider).watchGymTrainers(gymId);
});

final gymTraineesProvider =
    StreamProvider.family<List<Trainee>, String>((ref, gymId) {
  return ref.watch(gymRepositoryProvider).watchGymTrainees(gymId);
});

final gymActivitiesProvider =
    StreamProvider.family<List<GymActivity>, String>((ref, gymId) {
  return ref.watch(gymRepositoryProvider).watchGymActivities(gymId);
});
