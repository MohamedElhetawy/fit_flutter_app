import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';

/// Single set data for a workout
class WorkoutSet {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final int setNumber;
  final DateTime timestamp;
  final double volume;
  final double oneRepMax;

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.setNumber,
    required this.timestamp,
  })  : volume = weight * reps,
        oneRepMax = _calculateOneRepMax(weight, reps);

  static double _calculateOneRepMax(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'weight': weight,
    'reps': reps,
    'setNumber': setNumber,
    'timestamp': timestamp.toIso8601String(),
    'volume': volume,
    'oneRepMax': oneRepMax,
  };
}

/// Workout session state
class WorkoutSession {
  final String? id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<WorkoutSet> sets;
  final String? muscleGroup;
  final bool isActive;

  WorkoutSession({
    this.id,
    required this.startTime,
    this.endTime,
    this.sets = const [],
    this.muscleGroup,
    this.isActive = false,
  });

  WorkoutSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<WorkoutSet>? sets,
    String? muscleGroup,
    bool? isActive,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sets: sets ?? this.sets,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      isActive: isActive ?? this.isActive,
    );
  }

  // Stats getters
  int get totalSets => sets.length;
  int get totalExercises => sets.map((s) => s.exerciseId).toSet().length;
  double get totalVolume => sets.fold(0, (sum, s) => sum + s.volume);
  Duration? get duration => endTime != null 
      ? endTime!.difference(startTime) 
      : DateTime.now().difference(startTime);
  double get averageWeight => sets.isEmpty 
      ? 0 
      : sets.fold(0.0, (sum, s) => sum + s.weight) / sets.length;
  double get bestOneRepMax => sets.isEmpty 
      ? 0 
      : sets.map((s) => s.oneRepMax).reduce((a, b) => a > b ? a : b);

  // Group sets by exercise
  Map<String, List<WorkoutSet>> get setsByExercise {
    final map = <String, List<WorkoutSet>>{};
    for (final set in sets) {
      map.putIfAbsent(set.exerciseId, () => []).add(set);
    }
    return map;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'sets': sets.map((s) => s.toJson()).toList(),
    'muscleGroup': muscleGroup,
    'totalSets': totalSets,
    'totalVolume': totalVolume,
    'duration': duration?.inMinutes,
  };
}

/// Workout Session Notifier
class WorkoutSessionNotifier extends StateNotifier<WorkoutSession?> {
  final Ref ref;
  WorkoutSessionNotifier(this.ref) : super(null);

  void startWorkout({String? muscleGroup}) {
    state = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      muscleGroup: muscleGroup,
      isActive: true,
    );
  }

  void addSet({
    required String exerciseId,
    required String exerciseName,
    required double weight,
    required int reps,
  }) {
    if (state == null) return;

    final setsForExercise = state!.sets
        .where((s) => s.exerciseId == exerciseId)
        .length;

    final newSet = WorkoutSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      weight: weight,
      reps: reps,
      setNumber: setsForExercise + 1,
      timestamp: DateTime.now(),
    );

    state = state!.copyWith(
      sets: [...state!.sets, newSet],
    );
  }

  void removeSet(String setId) {
    if (state == null) return;

    state = state!.copyWith(
      sets: state!.sets.where((s) => s.id != setId).toList(),
    );
  }

  Future<void> endWorkout() async {
    if (state == null) return;

    final finalSession = state!.copyWith(
      endTime: DateTime.now(),
      isActive: false,
    );

    // 1. Sync to activities for Recent Activity on Home
    await _syncToFirebase(finalSession);

    state = finalSession;
  }

  Future<void> _syncToFirebase(WorkoutSession session) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final firestore = ref.read(firestoreProvider);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final batch = firestore.batch();

    // A. Add to Activities
    final activityRef = firestore
        .collection('users')
        .doc(user.uid)
        .collection('activities')
        .doc(session.id);
    
    batch.set(activityRef, {
      'name': '${session.muscleGroup ?? 'General'} Workout',
      'durationMinutes': session.duration?.inMinutes ?? 0,
      'type': 'workout',
      'timestamp': Timestamp.fromDate(now),
      'volume': session.totalVolume,
    });

    // B. Update Daily Stats for Interconnected Dashboard
    final statsDoc = firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_stats')
        .doc(startOfDay.millisecondsSinceEpoch.toString());

    // Note: We use a batch here, but for increments we need to be careful. 
    // In a real app, fieldValue.increment is better.
    batch.set(statsDoc, {
      'caloriesBurned': FieldValue.increment((session.duration?.inMinutes ?? 0) * 8), // Rough estimate
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  void clearSession() {
    state = null;
  }
}

/// Providers
final workoutSessionProvider = StateNotifierProvider<WorkoutSessionNotifier, WorkoutSession?>((ref) {
  return WorkoutSessionNotifier(ref);
});

/// Current workout stats (computed)
final currentWorkoutStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final session = ref.watch(workoutSessionProvider);
  
  if (session == null) {
    return {
      'isActive': false,
      'totalSets': 0,
      'totalVolume': 0.0,
      'totalExercises': 0,
      'duration': Duration.zero,
    };
  }

  return {
    'isActive': session.isActive,
    'totalSets': session.totalSets,
    'totalVolume': session.totalVolume,
    'totalExercises': session.totalExercises,
    'duration': session.duration,
    'averageWeight': session.averageWeight,
    'bestOneRepMax': session.bestOneRepMax,
  };
});

/// Provider to check if there's an active workout
final isWorkoutActiveProvider = Provider<bool>((ref) {
  final session = ref.watch(workoutSessionProvider);
  return session?.isActive ?? false;
});
