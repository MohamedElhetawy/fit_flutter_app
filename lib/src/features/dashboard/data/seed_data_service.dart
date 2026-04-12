import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';

/// Writes sample data to the current user's Firestore so we can
/// immediately test the dynamic home screen.
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
      final today = DateTime(now.year, now.month, now.day, 8, 0);

      final batch = firestore.batch();

      // 1. User progress/weight (always at doc 'current')
      batch.set(
        userDoc.collection('progress').doc('current'),
        {
          'currentWeight': 78.5,
          'weightChange': 0.5,
          'goalWeight': 75.0,
          'lastUpdated': Timestamp.fromDate(now),
        },
        SetOptions(merge: true),
      );

      // 2. Today's workout (using date-based ID for better querying)
      final workoutDocId = 'workout_${today.millisecondsSinceEpoch}';
      batch.set(
        userDoc.collection('workouts').doc(workoutDocId),
        {
          'title': "Today's Workout",
          'subtitle': 'Chest Day',
          'isCompleted': false,
          'date': Timestamp.fromDate(today),
          'exercises': [
            {
              'name': 'Bench Press',
              'sets': 4,
              'reps': 8,
              'weight': 100.0,
            },
            {
              'name': 'Incline Dumbbell Press',
              'sets': 3,
              'reps': 10,
              'weight': 40.0,
            },
          ],
        },
        SetOptions(merge: true),
      );

      // 3. Recent activities (multiple entries for realistic data)
      final activities = [
        {
          'name': 'Running',
          'durationMinutes': 30,
          'type': 'running',
          'timestamp': Timestamp.fromDate(
            now.subtract(const Duration(hours: 2)),
          ),
        },
        {
          'name': 'Cycling',
          'durationMinutes': 45,
          'type': 'cycling',
          'timestamp': Timestamp.fromDate(
            now.subtract(const Duration(hours: 4)),
          ),
        },
        {
          'name': 'Weights',
          'durationMinutes': 60,
          'type': 'weights',
          'timestamp': Timestamp.fromDate(
            now.subtract(const Duration(hours: 24)),
          ),
        },
        {
          'name': 'Yoga',
          'durationMinutes': 45,
          'type': 'yoga',
          'timestamp': Timestamp.fromDate(
            now.subtract(const Duration(hours: 48)),
          ),
        },
        {
          'name': 'Swimming',
          'durationMinutes': 30,
          'type': 'swimming',
          'timestamp': Timestamp.fromDate(
            now.subtract(const Duration(hours: 72)),
          ),
        },
      ];

      for (final activity in activities) {
        final ts = activity['timestamp'] as Timestamp;
        final docId = 'activity_${ts.seconds}';
        batch.set(
          userDoc.collection('activities').doc(docId),
          activity,
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return 'Demo data seeded! Check dashboard now 🚀';
    });
  }
}
