import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'package:fitx/src/features/dashboard/domain/user_progress.dart';
import 'package:fitx/src/features/dashboard/domain/daily_workout.dart';
import 'package:fitx/src/features/dashboard/domain/activity.dart';

/// Streams the current user's weight/progress document in real-time.
final userProgressProvider = StreamProvider<UserProgress?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('progress')
      .doc('current')
      .snapshots()
      .map((snap) {
    if (!snap.exists || snap.data() == null) return null;
    return UserProgress.fromMap(snap.data()!);
  });
});

/// Streams today's workout for the current user.
final todayWorkoutProvider = StreamProvider<DailyWorkout?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  final firestore = ref.watch(firestoreProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('workouts')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('date', isLessThan: Timestamp.fromDate(endOfDay))
      .limit(1)
      .snapshots()
      .map((snap) {
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return DailyWorkout.fromMap(doc.data(), doc.id);
  });
});

/// Streams the 5 most recent activities for the current user.
final recentActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('activities')
      .orderBy('timestamp', descending: true)
      .limit(5)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => Activity.fromMap(doc.data(), doc.id))
          .toList());
});

/// Health data model for daily metrics
class HealthData {
  final int steps;
  final int calories;
  final int? heartRate;
  final double? sleepHours;
  final DateTime date;

  const HealthData({
    this.steps = 0,
    this.calories = 0,
    this.heartRate,
    this.sleepHours,
    required this.date,
  });

  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      steps: map['steps'] ?? 0,
      calories: map['calories'] ?? 0,
      heartRate: map['heartRate'],
      sleepHours: map['sleepHours']?.toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}

/// Streams today's health data (steps, calories) from Firestore
/// Falls back to local sensor data if Firestore data is not available
final healthDataProvider = StreamProvider<HealthData>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(HealthData(date: DateTime.now()));

  final firestore = ref.watch(firestoreProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('health_data')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('date', isLessThan: Timestamp.fromDate(endOfDay))
      .limit(1)
      .snapshots()
      .map((snap) {
    if (snap.docs.isEmpty) {
      // Return default health data if none exists
      return HealthData(
        steps: 0,
        calories: 0,
        date: DateTime.now(),
      );
    }
    final doc = snap.docs.first;
    return HealthData.fromMap(doc.data());
  });
});

/// Current user profile data with weight
class AppUserProfile {
  final String uid;
  final String name;
  final String email;
  final double weight;
  final double height;
  final int age;
  final String gender;

  const AppUserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.weight = 70.0,
    this.height = 170.0,
    this.age = 25,
    this.gender = 'male',
  });

  factory AppUserProfile.fromMap(Map<String, dynamic> map) {
    return AppUserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: (map['weight'] ?? 70.0).toDouble(),
      height: (map['height'] ?? 170.0).toDouble(),
      age: map['age'] ?? 25,
      gender: map['gender'] ?? 'male',
    );
  }
}

/// Streams current user profile with weight and other details
final currentUserProfileProvider = StreamProvider<AppUserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) {
    if (!snap.exists || snap.data() == null) {
      return AppUserProfile(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
    }
    return AppUserProfile.fromMap(snap.data()!);
  });
});
