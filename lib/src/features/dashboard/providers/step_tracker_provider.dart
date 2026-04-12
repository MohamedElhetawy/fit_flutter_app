import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final stepTrackerProvider =
    NotifierProvider<StepTrackerNotifier, int>(StepTrackerNotifier.new);

class StepTrackerNotifier extends Notifier<int> {
  double _lastMagnitude = 0;
  int _cooldown = 0;
  bool _started = false;

  @override
  int build() {
    if (!_started) {
      _started = true;
      state = 0;
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
      _cooldown = 8;
    }
  }

  void reset() => state = 0;
}
