import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import '../../dashboard/data/home_providers.dart';

import '../data/nutrition_models.dart';

// ==================== Providers ====================

final macroGoalProvider = StreamProvider.family<MacroGoal, String>((ref, uid) {
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('nutrition')
      .doc('goal')
      .snapshots()
      .map((doc) => MacroGoal.fromMap(doc.data()));
});

/// Daily macro goals provider for logging screen
final dailyMacroGoalsProvider = StreamProvider.family<MacroGoal, String>((ref, uid) {
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('nutrition')
      .doc('daily_goals')
      .snapshots()
      .map((doc) => doc.exists 
          ? MacroGoal.fromMap(doc.data()) 
          : const MacroGoal(calories: 2200, protein: 140, carbs: 230, fat: 70));
});

/// Daily nutrition logs provider (filtered by date)
final dailyNutritionLogsProvider = StreamProvider.family<List<NutritionLog>, ({String uid, DateTime date})>((ref, params) {
  final startOfDay = DateTime(params.date.year, params.date.month, params.date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(params.uid)
      .collection('nutrition_logs')
      .where('loggedAt', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
      .where('loggedAt', isLessThan: endOfDay.toIso8601String())
      .orderBy('loggedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((d) => NutritionLog.fromMap(d.id, d.data()))
          .toList(growable: false));
});

/// Weekly nutrition summary provider
final weeklyNutritionSummaryProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, uid) {
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('nutrition_logs')
      .where('loggedAt', isGreaterThanOrEqualTo: weekAgo.toIso8601String())
      .snapshots()
      .map((snapshot) {
        final logs = snapshot.docs
            .map((d) => NutritionLog.fromMap(d.id, d.data()))
            .toList();
        
        // Calculate daily totals
        final dailyTotals = <String, int>{};
        for (final log in logs) {
          final dateKey = '${log.loggedAt.year}-${log.loggedAt.month}-${log.loggedAt.day}';
          dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + log.calories;
        }
        
        // Calculate streak
        int streak = 0;
        final today = DateTime.now();
        for (int i = 0; i < 365; i++) {
          final checkDate = today.subtract(Duration(days: i));
          final dateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
          if (dailyTotals.containsKey(dateKey) && dailyTotals[dateKey]! > 0) {
            streak++;
          } else if (i == 0) {
            // Today might be incomplete, continue checking
            continue;
          } else {
            break;
          }
        }
        
        return {
          'streak': streak,
          'dailyTotals': dailyTotals,
          'totalLogs': logs.length,
          'avgCalories': logs.isEmpty ? 0 : logs.fold<int>(0, (total, l) => total + l.calories) / logs.length,
        };
      });
});

/// Nutrition streak provider
final nutritionStreakProvider = StreamProvider.family<int, String>((ref, uid) {
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('nutrition_streak')
      .doc('current')
      .snapshots()
      .map((doc) => doc.data()?['streak'] ?? 0);
});

final nutritionLogsProvider =
    StreamProvider.family<List<NutritionLog>, String>((ref, uid) {
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('nutrition_logs')
      .orderBy('loggedAt', descending: true)
      .limit(30)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((d) => NutritionLog.fromMap(d.id, d.data()))
          .toList(growable: false));
});

final nutritionControllerProvider =
    AsyncNotifierProvider<NutritionController, void>(NutritionController.new);

class NutritionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveGoal({
    required String uid,
    required MacroGoal goal,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('nutrition')
          .doc('goal')
          .set({
        ...goal.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> addLog({
    required String uid,
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('nutrition_logs')
          .add({
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'loggedAt': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

// ==================== Repository ====================

class NutritionRepository {
  final FirebaseFirestore _firestore;
  
  NutritionRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<void> updateMacroGoals(String uid, MacroGoal goals) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('nutrition')
        .doc('daily_goals')
        .set({
      ...goals.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> logFood({
    required String uid,
    required NutritionLog log,
    String? mealType,
  }) async {
    // 1. Add individual log
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('nutrition_logs')
        .add({
      'name': log.name,
      'calories': log.calories,
      'protein': log.protein,
      'carbs': log.carbs,
      'fat': log.fat,
      'mealType': mealType,
      'loggedAt': log.loggedAt.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Aggregate to unified daily_stats for the Interconnected Dashboard
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final statsDoc = _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(startOfDay.millisecondsSinceEpoch.toString());

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(statsDoc);
      if (!snap.exists) {
        transaction.set(statsDoc, {
          'caloriesConsumed': log.calories,
          'protein': log.protein,
          'carbs': log.carbs,
          'fat': log.fat,
          'date': Timestamp.fromDate(startOfDay),
        });
      } else {
        final data = snap.data()!;
        transaction.update(statsDoc, {
          'caloriesConsumed': (data['caloriesConsumed'] ?? 0) + log.calories,
          'protein': (data['protein'] ?? 0) + log.protein,
          'carbs': (data['carbs'] ?? 0) + log.carbs,
          'fat': (data['fat'] ?? 0) + log.fat,
        });
      }
    });

    // 3. Update streak
    await _updateStreak(uid);
  }

  Future<void> _updateStreak(String uid) async {
    final streakDoc = _firestore
        .collection('users')
        .doc(uid)
        .collection('nutrition_streak')
        .doc('current');
    
    final doc = await streakDoc.get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (!doc.exists) {
      await streakDoc.set({
        'streak': 1,
        'lastLogDate': today.toIso8601String(),
        'startedAt': FieldValue.serverTimestamp(),
      });
      return;
    }
    
    final data = doc.data()!;
    final lastLogDate = DateTime.tryParse(data['lastLogDate']?.toString() ?? '');
    final currentStreak = data['streak'] ?? 0;
    
    if (lastLogDate == null) {
      await streakDoc.update({
        'streak': 1,
        'lastLogDate': today.toIso8601String(),
      });
      return;
    }
    
    final lastLogDay = DateTime(lastLogDate.year, lastLogDate.month, lastLogDate.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (lastLogDay.isAtSameMomentAs(yesterday)) {
      // Continued streak
      await streakDoc.update({
        'streak': currentStreak + 1,
        'lastLogDate': today.toIso8601String(),
      });
    } else if (lastLogDay.isBefore(yesterday)) {
      // Streak broken
      await streakDoc.update({
        'streak': 1,
        'lastLogDate': today.toIso8601String(),
      });
    }
    // If already logged today, don't update
  }
}

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository(firestore: ref.watch(firestoreProvider));
});
