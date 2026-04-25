import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import 'local/exercise_local.dart';
import 'local/workout_local.dart';
import 'local/workout_session_local.dart';

class WorkoutsLocalDataSource {
  WorkoutsLocalDataSource(this._isar);

  final Isar _isar;

  /// Loads `mustles.json` and seeds the local database if there are no exercises.
  Future<void> seedExercisesIfEmpty() async {
    final count = await _isar.exerciseLocals.count();
    if (count == 0) {
      final jsonString =
          await rootBundle.loadString('assets/data/mustles.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final exercises = jsonList.map((j) {
        final ex = ExerciseLocal();
        ex.fromJson(j as Map<String, dynamic>);
        return ex;
      }).toList();

      await _isar.writeTxn(() async {
        await _isar.exerciseLocals.putAll(exercises);
      });
    }
  }

  // ==== EXERCISES ====

  Stream<List<ExerciseLocal>> watchAllExercises() {
    return _isar.exerciseLocals.where().watch(fireImmediately: true);
  }

  Future<List<ExerciseLocal>> getExercisesByMuscleGroup(
      String muscleGroup) async {
    return await _isar.exerciseLocals
        .filter()
        .muscleGroupEqualTo(muscleGroup)
        .findAll();
  }

  // ==== WORKOUTS ====

  Stream<List<WorkoutLocal>> watchAllWorkouts() {
    return _isar.workoutLocals.where().watch(fireImmediately: true);
  }

  Future<void> saveWorkout(WorkoutLocal workout) async {
    await _isar.writeTxn(() async {
      await _isar.workoutLocals.put(workout);
    });
  }

  // ==== SESSIONS ====

  Stream<List<WorkoutSessionLocal>> watchWorkoutSessions() {
    return _isar.workoutSessionLocals.where().watch(fireImmediately: true);
  }

  Future<void> saveWorkoutSession(WorkoutSessionLocal session) async {
    await _isar.writeTxn(() async {
      await _isar.workoutSessionLocals.put(session);
    });
  }
}
