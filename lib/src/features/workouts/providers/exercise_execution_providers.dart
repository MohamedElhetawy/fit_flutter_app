import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/exercise.dart';

/// State for the rest timer
class RestTimerState {
  final int secondsRemaining;
  final int totalSeconds;
  final bool isRunning;
  final bool isPaused;

  const RestTimerState({
    this.secondsRemaining = 60,
    this.totalSeconds = 60,
    this.isRunning = false,
    this.isPaused = false,
  });

  RestTimerState copyWith({
    int? secondsRemaining,
    int? totalSeconds,
    bool? isRunning,
    bool? isPaused,
  }) {
    return RestTimerState(
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  double get progress => totalSeconds > 0 ? secondsRemaining / totalSeconds : 0;

  String get formattedTime {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// StateNotifier for rest timer
class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;

  RestTimerNotifier() : super(const RestTimerState());

  void start({int seconds = 60}) {
    _timer?.cancel();
    state = RestTimerState(
      secondsRemaining: seconds,
      totalSeconds: seconds,
      isRunning: true,
      isPaused: false,
    );
    _startTicking();
  }

  void _startTicking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        stop();
      }
    });
  }

  void pause() {
    if (state.isRunning && !state.isPaused) {
      _timer?.cancel();
      state = state.copyWith(isPaused: true);
    }
  }

  void resume() {
    if (state.isRunning && state.isPaused) {
      state = state.copyWith(isPaused: false);
      _startTicking();
    }
  }

  void stop() {
    _timer?.cancel();
    state = const RestTimerState();
  }

  void reset({int seconds = 60}) {
    _timer?.cancel();
    state = RestTimerState(
      secondsRemaining: seconds,
      totalSeconds: seconds,
      isRunning: false,
      isPaused: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// State for logged sets
class LoggedSetsState {
  final List<LoggedSet> sets;

  const LoggedSetsState({this.sets = const []});

  LoggedSetsState copyWith({List<LoggedSet>? sets}) {
    return LoggedSetsState(sets: sets ?? this.sets);
  }
}

/// StateNotifier for logged sets
class LoggedSetsNotifier extends StateNotifier<LoggedSetsState> {
  LoggedSetsNotifier() : super(const LoggedSetsState());

  void addSet(double weight, int reps) {
    final newSet = LoggedSet(
      setNumber: state.sets.length + 1,
      weight: weight,
      reps: reps,
    );
    state = LoggedSetsState(sets: [...state.sets, newSet]);
  }

  void removeSet(int index) {
    final updatedSets = [...state.sets];
    if (index >= 0 && index < updatedSets.length) {
      updatedSets.removeAt(index);
      // Renumber sets
      for (var i = 0; i < updatedSets.length; i++) {
        updatedSets[i] = LoggedSet(
          setNumber: i + 1,
          weight: updatedSets[i].weight,
          reps: updatedSets[i].reps,
          timestamp: updatedSets[i].timestamp,
        );
      }
      state = LoggedSetsState(sets: updatedSets);
    }
  }

  void clear() {
    state = const LoggedSetsState();
  }

  double get totalVolume {
    return state.sets.fold(0, (sum, set) => sum + (set.weight * set.reps));
  }

  int get totalReps {
    return state.sets.fold(0, (sum, set) => sum + set.reps);
  }
}

/// Provider for rest timer
final restTimerProvider =
    StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  return RestTimerNotifier();
});

/// Provider for logged sets
final loggedSetsProvider =
    StateNotifierProvider<LoggedSetsNotifier, LoggedSetsState>((ref) {
  return LoggedSetsNotifier();
});

/// Provider for current exercise session (combines sets + timer)
final exerciseSessionProvider =
    Provider<({LoggedSetsState sets, RestTimerState timer})>((ref) {
  final sets = ref.watch(loggedSetsProvider);
  final timer = ref.watch(restTimerProvider);
  return (sets: sets, timer: timer);
});
