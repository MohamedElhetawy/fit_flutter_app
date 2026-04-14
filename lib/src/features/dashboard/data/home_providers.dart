import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'package:fitx/src/features/dashboard/domain/user_progress.dart';
import 'package:fitx/src/features/dashboard/domain/daily_workout.dart';
import 'package:fitx/src/features/dashboard/domain/activity.dart';
import 'package:fitx/src/core/local_db/local_db_service.dart';
import 'package:fitx/src/features/dashboard/data/dashboard_local_data_source.dart';
import 'package:fitx/src/core/sync/sync_engine.dart';

// ─── MODELS ───────────────────────────────────────────────

class DailyHealthMetrics {
  final int steps;
  final int caloriesBurned;
  final int caloriesConsumed;
  final int protein;
  final int carbs;
  final int fat;
  final double waterLiters;
  final DateTime date;

  const DailyHealthMetrics({
    this.steps = 0,
    this.caloriesBurned = 0,
    this.caloriesConsumed = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.waterLiters = 0.0,
    required this.date,
  });

  // Business Logic inside Model
  double get calorieProgress => (caloriesConsumed / 2200).clamp(0.0, 1.0);
  double get stepProgress => (steps / 10000).clamp(0.0, 1.0);
  double get waterProgress => (waterLiters / 2.5).clamp(0.0, 1.0);
  int get remainingCalories => (2200 - caloriesConsumed).clamp(0, 2200);

  factory DailyHealthMetrics.fromMap(Map<String, dynamic> map, DateTime date) {
    return DailyHealthMetrics(
      steps: map['steps'] ?? 0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
      caloriesConsumed: map['caloriesConsumed'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fat: map['fat'] ?? 0,
      waterLiters: (map['water'] ?? 0.0).toDouble(),
      date: date,
    );
  }
}

// ─── PROVIDERS ────────────────────────────────────────────

// ─── PROVIDERS ────────────────────────────────────────────

final dashboardLocalDataSourceProvider = Provider((ref) => DashboardLocalDataSource(LocalDbService().isar));

final dailyHealthProvider = StreamProvider<DailyHealthMetrics>((ref) {
  final dataSource = ref.watch(dashboardLocalDataSourceProvider);
  
  final now = DateTime.now();
  final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  return dataSource.watchTodayStats(todayStr).map((stat) {
    if (stat == null) return DailyHealthMetrics(date: now);
    
    return DailyHealthMetrics(
      steps: stat.steps,
      caloriesBurned: stat.activeCalories,
      caloriesConsumed: stat.caloriesConsumed,
      protein: stat.protein,
      carbs: stat.carbs,
      fat: stat.fat,
      waterLiters: stat.hydrationMl / 1000.0,
      date: now,
    );
  });
});

final recentActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('activities')
      .orderBy('timestamp', descending: true)
      .limit(5)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Activity.fromMap(doc.data(), doc.id)).toList());
});

final todayWorkoutProvider = StreamProvider<DailyWorkout?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  return ref.watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('workouts')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .limit(1)
      .snapshots()
      .map((snap) => snap.docs.isEmpty ? null : DailyWorkout.fromMap(snap.docs.first.data(), snap.docs.first.id));
});

final userProgressProvider = StreamProvider<UserProgress?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return ref.watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('progress')
      .doc('current')
      .snapshots()
      .map((snap) => snap.exists ? UserProgress.fromMap(snap.data()!) : null);
});

// ─── REPOSITORY ───────────────────────────────────────────

class DailyStatsRepository {
  DailyStatsRepository(this._localDataSource, this._syncEngine);
  
  final DashboardLocalDataSource _localDataSource;
  final SyncEngine _syncEngine;

  Future<void> addWater(String uid, double amountLiters) async {
    final todayStr = _getTodayStr();
    final hydrationMl = (amountLiters * 1000).toInt();
    
    final totalHydration = await _localDataSource.addHydration(todayStr, hydrationMl);
    
    final now = DateTime.now();
    final startOfDayMs = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch.toString();
    
    await _syncEngine.enqueueEvent(
      collectionName: 'users/{uid}/daily_stats',
      recordId: startOfDayMs,
      operation: 'UPDATE',
      payload: {'water': (totalHydration / 1000.0)},
    );
  }

  Future<void> addSteps(String uid, int steps) async {
    // Currently unified_steps_service is the main source of truth for steps.
    // If anything manually injects steps here, we should update data source.
  }

  String _getTodayStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}

final dailyStatsRepositoryProvider = Provider((ref) => DailyStatsRepository(
  ref.watch(dashboardLocalDataSourceProvider),
  ref.watch(syncEngineProvider),
));

class AppUserProfile {
  final String uid;
  final String name;
  final double weight;

  AppUserProfile({required this.uid, required this.name, this.weight = 70.0});

  factory AppUserProfile.fromMap(Map<String, dynamic> map) {
    return AppUserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'User',
      weight: (map['weight'] ?? 70.0).toDouble(),
    );
  }
}

final currentUserProfileProvider = StreamProvider<AppUserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(firestoreProvider).collection('users').doc(user.uid)
      .snapshots().map((snap) => snap.exists ? AppUserProfile.fromMap(snap.data()!) : null);
});
