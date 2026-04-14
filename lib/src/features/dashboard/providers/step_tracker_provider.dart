import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../core/auth/auth_controller.dart';
import '../data/home_providers.dart';

final stepTrackerProvider =
    NotifierProvider<StepTrackerNotifier, int>(StepTrackerNotifier.new);

class StepTrackerNotifier extends Notifier<int> {
  double _lastMagnitude = 0;
  int _cooldown = 0;
  bool _started = false;
  int _totalSteps = 0;

  @override
  int build() {
    if (!_started) {
      _started = true;
      state = 0;
      _totalSteps = 0;
      accelerometerEventStream().listen(_onSensorData);
    }
    return state;
  }

  void _onSensorData(AccelerometerEvent event) {
    final magnitude = sqrt(
      (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
    );
    final delta = (magnitude - _lastMagnitude).abs();
    _lastMagnitude = magnitude;

    if (_cooldown > 0) {
      _cooldown--;
      return;
    }

    if (delta > 2.2 && magnitude > 10) {
      state += 1;
      _totalSteps += 1;
      _cooldown = 8;
      
      // Sync to Firestore every 10 steps
      if (_totalSteps % 10 == 0) {
        _syncStepsToFirestore(10);
      }
    }
  }

  void _syncStepsToFirestore(int steps) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    await ref.read(dailyStatsRepositoryProvider).addSteps(user.uid, steps);
  }

  void reset() {
    state = 0;
    _totalSteps = 0;
  }
}
