import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';

/// Writes sample data to the current user's Firestore so we can
/// immediately test the dynamic home screen with INTERCONNECTED DATA.
final seedDataProvider =
    AsyncNotifierProvider<SeedDataNotifier, String?>(SeedDataNotifier.new);

class SeedDataNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> seed() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Not authenticated');

      final firestore = ref.read(firestoreProvider);
      final userDoc = firestore.collection('users').doc(user.uid);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final batch = firestore.batch();

      // 1. Unified Daily Stats (The brain of the dashboard)
      final statsDoc = userDoc.collection('daily_stats').doc(today.millisecondsSinceEpoch.toString());
      batch.set(statsDoc, {
        'steps': 6420,
        'caloriesBurned': 320,
        'caloriesConsumed': 1850,
        'protein': 120,
        'carbs': 180,
        'fat': 55,
        'water': 1.8,
        'date': Timestamp.fromDate(today),
      });

      // 2. User progress/weight
      batch.set(
        userDoc.collection('progress').doc('current'),
        {
          'currentWeight': 78.5,
          'weightChange': -0.5,
          'goalWeight': 75.0,
          'lastUpdated': Timestamp.fromDate(now),
        },
        SetOptions(merge: true),
      );

      // 3. Today's workout
      final workoutDocId = 'workout_${today.millisecondsSinceEpoch}';
      batch.set(
        userDoc.collection('workouts').doc(workoutDocId),
        {
          'title': "Morning Strength",
          'subtitle': 'Upper Body Focus',
          'isCompleted': true,
          'date': Timestamp.fromDate(today),
        },
        SetOptions(merge: true),
      );

      // 4. Recent activities
      final activities = [
        {
          'name': 'Upper Body Workout',
          'durationMinutes': 45,
          'type': 'workout',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        },
        {
          'name': 'Morning Walk',
          'durationMinutes': 20,
          'type': 'running',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 8))),
        },
      ];

      for (final activity in activities) {
        final docId = 'activity_${DateTime.now().millisecondsSinceEpoch}_${activity['name'].hashCode}';
        batch.set(userDoc.collection('activities').doc(docId), activity);
      }

      await batch.commit();
      return 'Unified system data seeded! 🚀';
    });
  }
}
