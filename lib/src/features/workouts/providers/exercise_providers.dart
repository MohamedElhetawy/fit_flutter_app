import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercise.dart';

/// Provider for all exercises (loaded once from JSON)
final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  return await WorkoutDatabase.loadExercises();
});

/// Selected muscle group for filtering (Level 2 category)
final selectedMuscleGroupProvider = StateProvider<String?>((ref) => null);

/// Selected muscle angle for filtering (Level 3 category)
final selectedMuscleAngleProvider = StateProvider<String?>((ref) => null);

/// Filtered exercises based on selected muscle group
final filteredExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final allExercises = await ref.watch(allExercisesProvider.future);
  final selectedMuscleGroup = ref.watch(selectedMuscleGroupProvider);

  if (selectedMuscleGroup == null) {
    return allExercises;
  }

  return WorkoutDatabase.filterByMuscleGroup(allExercises, selectedMuscleGroup);
});

/// Provider for available muscle groups (string list)
final muscleGroupsProvider = FutureProvider<List<String>>((ref) async {
  final exercises = await ref.watch(allExercisesProvider.future);
  return WorkoutDatabase.getMuscleGroups(exercises);
});

/// Provider for muscle groups with images and metadata
final muscleGroupsWithImagesProvider = FutureProvider<List<MuscleGroup>>((ref) async {
  final exercises = await ref.watch(allExercisesProvider.future);
  return MuscleGroup.getDefaultGroups(exercises);
});

/// Provider for muscle angles of a specific group
final muscleAnglesForGroupProvider = FutureProvider.family<List<MuscleAngle>, String>((ref, muscleGroup) async {
  final exercises = await ref.watch(allExercisesProvider.future);
  return MuscleAngle.getAnglesForGroup(exercises, muscleGroup);
});

/// Provider for exercises by muscle group and angle
final exercisesByGroupAndAngleProvider = FutureProvider.family<List<Exercise>, ({String muscleGroup, String muscleAngle})>((ref, params) async {
  final exercises = await ref.watch(allExercisesProvider.future);
  return WorkoutDatabase.getExercisesByGroupAndAngle(
    exercises,
    params.muscleGroup,
    params.muscleAngle,
  );
});
