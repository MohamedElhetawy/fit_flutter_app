import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_stats.dart';

class DashboardStatsRepository {
  DashboardStatsRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<DashboardStats> getAdminStats() async {
    final users = await _firestore.collection('users').count().get();
    final workouts = await _firestore.collection('workouts').count().get();
    final subscriptions = await _firestore
        .collection('subscriptions')
        .where('status', isEqualTo: 'active')
        .count()
        .get();

    return DashboardStats(
      totalUsers: users.count ?? 0,
      totalWorkouts: workouts.count ?? 0,
      activeSubscriptions: subscriptions.count ?? 0,
    );
  }

  Future<DashboardStats> getTrainerStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return DashboardStats(totalUsers: 0, activeSubscriptions: 0, totalWorkouts: 0);
    }
    final users = await _firestore
        .collection('users')
        .where('trainerId', isEqualTo: uid)
        .count()
        .get();
    final workouts = await _firestore
        .collection('workouts')
        .where('trainerId', isEqualTo: uid)
        .count()
        .get();
    final subscriptions = await _firestore
        .collection('subscriptions')
        .where('trainerId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .count()
        .get();

    return DashboardStats(
      totalUsers: users.count ?? 0,
      totalWorkouts: workouts.count ?? 0,
      activeSubscriptions: subscriptions.count ?? 0,
    );
  }

  Future<DashboardStats> getUserStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return DashboardStats(totalUsers: 0, activeSubscriptions: 0, totalWorkouts: 0);
    }
    final workouts = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: uid)
        .count()
        .get();
    final subscriptions = await _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .count()
        .get();

    return DashboardStats(
      totalUsers: 1,
      totalWorkouts: workouts.count ?? 0,
      activeSubscriptions: subscriptions.count ?? 0,
    );
  }
}
