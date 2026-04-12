import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthStepsState {
  const HealthStepsState({
    required this.steps,
    required this.granted,
    required this.source,
    this.message,
  });

  final int steps;
  final bool granted;
  final String source;
  final String? message;
}

final healthStepsProvider =
    AsyncNotifierProvider<HealthStepsNotifier, HealthStepsState>(
  HealthStepsNotifier.new,
);

class HealthStepsNotifier extends AsyncNotifier<HealthStepsState> {
  @override
  Future<HealthStepsState> build() async {
    return refresh();
  }

  Future<HealthStepsState> refresh() async {
    try {
      final permission = await Permission.activityRecognition.request();
      if (!permission.isGranted) {
        return const HealthStepsState(
          steps: 0,
          granted: false,
          source: 'none',
          message: 'Activity recognition permission denied',
        );
      }

      final health = Health();
      final types = [HealthDataType.STEPS];
      final perms = [HealthDataAccess.READ];
      final ok = await health.requestAuthorization(types, permissions: perms);
      if (!ok) {
        return const HealthStepsState(
          steps: 0,
          granted: false,
          source: 'none',
          message: 'Health authorization denied',
        );
      }

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final steps = await health.getTotalStepsInInterval(start, now) ?? 0;

      return HealthStepsState(
        steps: steps,
        granted: true,
        source: defaultTargetPlatform.name,
      );
    } catch (e) {
      return HealthStepsState(
        steps: 0,
        granted: false,
        source: 'none',
        message: e.toString(),
      );
    }
  }
}
