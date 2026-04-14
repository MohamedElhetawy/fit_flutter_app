import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/sync/sync_engine.dart';
import '../data/unified_steps_service.dart';

/// Unified Steps Service Provider
final unifiedStepsServiceProvider = Provider<UnifiedStepsService>((ref) {
  final service = UnifiedStepsService();
  
  // Initialize when auth state is available
  ref.listen(authStateProvider, (previous, next) {
    final user = next.value;
    if (user != null) {
      service.initialize(
        userId: user.uid,
        firestore: ref.read(firestoreProvider),
        syncEngine: ref.read(syncEngineProvider),
      );
    }
  });  
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream of current steps (real-time)
final unifiedStepsStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(unifiedStepsServiceProvider);
  return service.stepsStream;
});

/// Current steps value
final unifiedStepsProvider = Provider<int>((ref) {
  final asyncSteps = ref.watch(unifiedStepsStreamProvider);
  return asyncSteps.when(
    data: (steps) => steps,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Today's steps with source info
final todayStepsDetailedProvider = FutureProvider<StepsInfo>((ref) async {
  final service = ref.watch(unifiedStepsServiceProvider);
  final steps = service.currentSteps;
  final history = await service.getTodayHistory();
  
  return StepsInfo(
    totalSteps: steps,
    source: _determinePrimarySource(history),
    isSynced: history.isNotEmpty && history.last.isSynced,
    lastSyncTime: history.isNotEmpty ? history.last.timestamp : null,
  );
});

class StepsInfo {
  final int totalSteps;
  final String source;
  final bool isSynced;
  final DateTime? lastSyncTime;

  const StepsInfo({
    required this.totalSteps,
    required this.source,
    required this.isSynced,
    this.lastSyncTime,
  });
}

String _determinePrimarySource(List<StepsData> history) {
  if (history.isEmpty) return 'none';
  
  // Count steps by source
  final sources = <StepSource, int>{};
  for (final entry in history) {
    sources[entry.source] = (sources[entry.source] ?? 0) + entry.steps;
  }
  
  // Return the source with most steps (using display name)
  final topSource = sources.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  return topSource.displayNameAr;
}

/// Notifier for manual step operations
class UnifiedStepsNotifier extends StateNotifier<AsyncValue<void>> {
  final UnifiedStepsService _service;

  UnifiedStepsNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> addSteps(int steps) async {
    state = const AsyncValue.loading();
    try {
      await _service.addManualSteps(steps);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> forceSync() async {
    state = const AsyncValue.loading();
    try {
      await _service.forceSync();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> resetDaily() async {
    state = const AsyncValue.loading();
    try {
      await _service.resetDaily();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final unifiedStepsOperationsProvider = StateNotifierProvider<UnifiedStepsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(unifiedStepsServiceProvider);
  return UnifiedStepsNotifier(service);
});
