import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile.dart';

/// Backend Repository for User Profiles and Exercise History
/// Uses Firebase Firestore for real-time data
class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  // ═══════════════════════════════════════════════════════════════
  // USER PROFILE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user profile from backend
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return userProfileFromFirestore(doc.data()!, uid);
  }

  /// Get all users for K-NN (excluding current user)
  Future<List<UserProfile>> getAllUsersForKNN() async {
    final uid = currentUserId;
    
    final snapshot = await _firestore
        .collection('users')
        .where('profileComplete', isEqualTo: true)
        .limit(100) // Limit for performance
        .get();

    return snapshot.docs
        .where((doc) => doc.id != uid) // Exclude current user
        .map((doc) => userProfileFromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Get similar users by criteria
  Future<List<UserProfile>> getSimilarUsers({
    FitnessGoal? goal,
    FitnessLevel? level,
    double? minAge,
    double? maxAge,
    int limit = 20,
  }) async {
    var query = _firestore
        .collection('users')
        .where('profileComplete', isEqualTo: true);

    if (goal != null) {
      query = query.where('goal', isEqualTo: goal.name);
    }

    if (level != null) {
      query = query.where('level', isEqualTo: level.name);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => userProfileFromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Update current user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(uid).set({
      'name': profile.name,
      'age': profile.age,
      'weight': profile.weight,
      'height': profile.height,
      'goal': profile.goal.name,
      'level': profile.level.name,
      'gender': profile.gender.name,
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ═══════════════════════════════════════════════════════════════
  // EXERCISE HISTORY OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Log a new exercise set
  Future<void> logExerciseSet({
    required String exerciseId,
    required String exerciseName,
    required double weight,
    required int reps,
    int? setNumber,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final oneRepMax = UserExerciseHistory.calculateOneRepMax(weight, reps);

    // Add to exercise history collection
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('exerciseHistory')
        .add({
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'setNumber': setNumber,
      'oneRepMax': oneRepMax,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update aggregated stats
    await _updateExerciseStats(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      weight: weight,
      reps: reps,
      oneRepMax: oneRepMax,
    );
  }

  /// Update aggregated exercise statistics
  Future<void> _updateExerciseStats({
    required String exerciseId,
    required String exerciseName,
    required double weight,
    required int reps,
    required double oneRepMax,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final statsRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('exerciseStats')
        .doc(exerciseId);

    final statsDoc = await statsRef.get();

    if (statsDoc.exists) {
      final data = statsDoc.data()!;
      final totalSets = (data['totalSets'] ?? 0) + 1;
      final currentAvgWeight = data['avgWeight'] ?? 0.0;
      final currentAvgReps = data['avgReps'] ?? 0;

      // Calculate new averages
      final newAvgWeight = ((currentAvgWeight * (totalSets - 1)) + weight) / totalSets;
      final newAvgReps = ((currentAvgReps * (totalSets - 1)) + reps) ~/ totalSets;
      final bestOneRepMax = (data['bestOneRepMax'] ?? 0.0) > oneRepMax
          ? data['bestOneRepMax']
          : oneRepMax;

      await statsRef.update({
        'exerciseName': exerciseName,
        'totalSets': totalSets,
        'avgWeight': newAvgWeight,
        'avgReps': newAvgReps,
        'bestOneRepMax': bestOneRepMax,
        'lastPerformed': FieldValue.serverTimestamp(),
      });
    } else {
      await statsRef.set({
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'totalSets': 1,
        'avgWeight': weight,
        'avgReps': reps,
        'bestOneRepMax': oneRepMax,
        'lastPerformed': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get user's exercise history for an exercise
  Future<UserExerciseHistory?> getExerciseHistory(String exerciseId) async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('exerciseStats')
        .doc(exerciseId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return UserExerciseHistory(
      exerciseId: data['exerciseId'],
      exerciseName: data['exerciseName'],
      avgWeight: (data['avgWeight'] as num).toDouble(),
      avgReps: data['avgReps'],
      totalSets: data['totalSets'],
      lastPerformed: (data['lastPerformed'] as Timestamp).toDate(),
      oneRepMax: (data['bestOneRepMax'] as num).toDouble(),
    );
  }

  /// Get all exercise history for current user
  Future<List<UserExerciseHistory>> getAllExerciseHistory() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('exerciseStats')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserExerciseHistory(
        exerciseId: data['exerciseId'],
        exerciseName: data['exerciseName'],
        avgWeight: (data['avgWeight'] as num).toDouble(),
        avgReps: data['avgReps'],
        totalSets: data['totalSets'],
        lastPerformed: (data['lastPerformed'] as Timestamp).toDate(),
        oneRepMax: (data['bestOneRepMax'] as num).toDouble(),
      );
    }).toList();
  }

  /// Get exercise history for a specific user (for K-NN)
  Future<List<UserExerciseHistory>> getUserExerciseHistory(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('exerciseStats')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserExerciseHistory(
        exerciseId: data['exerciseId'],
        exerciseName: data['exerciseName'],
        avgWeight: (data['avgWeight'] as num).toDouble(),
        avgReps: data['avgReps'],
        totalSets: data['totalSets'],
        lastPerformed: (data['lastPerformed'] as Timestamp).toDate(),
        oneRepMax: (data['bestOneRepMax'] as num).toDouble(),
      );
    }).toList();
  }

  /// Stream of user's exercise stats (real-time)
  Stream<List<UserExerciseHistory>> watchExerciseStats() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('exerciseStats')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return UserExerciseHistory(
                exerciseId: data['exerciseId'],
                exerciseName: data['exerciseName'],
                avgWeight: (data['avgWeight'] as num).toDouble(),
                avgReps: data['avgReps'],
                totalSets: data['totalSets'],
                lastPerformed: (data['lastPerformed'] as Timestamp).toDate(),
                oneRepMax: (data['bestOneRepMax'] as num).toDouble(),
              );
            }).toList());
  }

  /// Stream of all users (for K-NN real-time updates)
  Stream<List<UserProfile>> watchAllUsersForKNN() {
    final uid = currentUserId;

    return _firestore
        .collection('users')
        .where('profileComplete', isEqualTo: true)
        .limit(100)
        .snapshots()
        .asyncMap((snapshot) async {
      final users = <UserProfile>[];

      for (final doc in snapshot.docs) {
        if (doc.id == uid) continue; // Skip current user

        final history = await getUserExerciseHistory(doc.id);
        users.add(userProfileFromFirestore(
          doc.data(),
          doc.id,
          exerciseHistory: history,
        ));
      }

      return users;
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Convert Firestore document to UserProfile (public for providers)
  UserProfile userProfileFromFirestore(
    Map<String, dynamic> data,
    String uid, {
    List<UserExerciseHistory>? exerciseHistory,
  }) {
    return UserProfile(
      id: uid,
      name: data['name'] ?? 'Unknown',
      age: (data['age'] as num?)?.toDouble() ?? 25,
      weight: (data['weight'] as num?)?.toDouble() ?? 70,
      height: (data['height'] as num?)?.toDouble() ?? 175,
      goal: _parseGoal(data['goal']),
      level: _parseLevel(data['level']),
      gender: _parseGender(data['gender']),
      exerciseHistory: exerciseHistory ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  FitnessGoal _parseGoal(String? value) {
    return FitnessGoal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FitnessGoal.buildMuscle,
    );
  }

  FitnessLevel _parseLevel(String? value) {
    return FitnessLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FitnessLevel.beginner,
    );
  }

  Gender _parseGender(String? value) {
    return Gender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Gender.male,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // VOLUME PERCENTILE CALCULATION (REAL DATA)
  // ═══════════════════════════════════════════════════════════════

  /// Calculate real volume percentile comparing user to all users today
  /// Returns 0-100 representing user's rank among all users
  Future<int> calculateVolumePercentile(double userVolume) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // Get all users' workout volumes for today
      final snapshot = await _firestore
          .collectionGroup('daily_stats')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('steps', isGreaterThan: 0) // Users with activity
          .get();

      final volumes = <double>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Calculate estimated volume from steps + calories burned
        final steps = (data['steps'] ?? 0) as int;
        final caloriesBurned = (data['caloriesBurned'] ?? 0) as int;
        
        // Estimate workout volume: calories * 0.5 + steps * 0.1
        final estimatedVolume = (caloriesBurned * 0.5) + (steps * 0.1);
        volumes.add(estimatedVolume);
      }

      if (volumes.isEmpty) {
        return 50; // Default if no data
      }

      // Sort volumes
      volumes.sort();
      
      // Calculate percentile
      final countBelow = volumes.where((v) => v < userVolume).length;
      final percentile = ((countBelow / volumes.length) * 100).round();
      
      // Clamp between 0-100
      return percentile.clamp(0, 100);
    } catch (e) {
      return 50; // Default on error
    }
  }

  /// Get today's workout volume for current user
  Future<double> getTodayWorkoutVolume() async {
    final uid = currentUserId;
    if (uid == null) return 0;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(startOfDay.millisecondsSinceEpoch.toString())
        .get();

    if (!doc.exists) return 0;

    final data = doc.data()!;
    final caloriesBurned = (data['caloriesBurned'] ?? 0) as int;
    final steps = (data['steps'] ?? 0) as int;
    
    // Estimate volume
    return (caloriesBurned * 0.5) + (steps * 0.1);
  }
}
