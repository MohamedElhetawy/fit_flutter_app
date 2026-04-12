import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pedometer_service.dart';

/// Provider for pedometer service instance
final pedometerServiceProvider = Provider<PedometerService>((ref) {
  final service = PedometerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for real-time step count
final stepsStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(pedometerServiceProvider);
  service.initialize();
  return service.stepsStream;
});

/// Stream provider for pedestrian status (walking, stopped, unknown)
final pedestrianStatusProvider = StreamProvider<String>((ref) {
  final service = ref.watch(pedometerServiceProvider);
  return service.statusStream;
});

/// Provider for today's total steps (combines sensor + manual)
final todayStepsProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(pedometerServiceProvider);
  return await service.getTodaySteps();
});

/// Notifier for manual step entry
class ManualStepsNotifier extends StateNotifier<AsyncValue<void>> {
  final PedometerService _service;

  ManualStepsNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> addSteps(int steps) async {
    state = const AsyncValue.loading();
    try {
      await _service.addManualSteps(steps);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> resetSteps() async {
    state = const AsyncValue.loading();
    try {
      await _service.resetDailySteps();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Provider for manual steps operations
final manualStepsProvider = StateNotifierProvider<ManualStepsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(pedometerServiceProvider);
  return ManualStepsNotifier(service);
});

/// Provider for steps goal (can be customized by user)
final stepsGoalProvider = StateProvider<int>((ref) => 10000);

/// Provider for calories calculation based on steps
/// Formula: steps * 0.04 * (weight / 70) where 70kg is baseline
final stepsCaloriesProvider = Provider.family<int, double>((ref, weight) {
  final stepsAsync = ref.watch(stepsStreamProvider);
  return stepsAsync.when(
    data: (steps) => (steps * 0.04 * (weight / 70)).round(),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
