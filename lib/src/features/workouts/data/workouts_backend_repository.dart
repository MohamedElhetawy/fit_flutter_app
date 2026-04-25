import 'package:cloud_firestore/cloud_firestore.dart';
import 'workout.dart';

class WorkoutsBackendRepository {
  WorkoutsBackendRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Workout>> watchWorkouts({int limit = 50}) {
    return _firestore.collection('workouts').limit(limit).snapshots().map(
        (snap) => snap.docs
            .map((d) => Workout.fromMap(d.id, d.data()))
            .toList(growable: false));
  }

  Future<void> addWorkout(Map<String, dynamic> payload) async {
    await _firestore.collection('workouts').add(payload);
  }

  Future<void> updateWorkout(String id, Map<String, dynamic> payload) async {
    await _firestore
        .collection('workouts')
        .doc(id)
        .set(payload, SetOptions(merge: true));
  }

  Future<void> deleteWorkout(String id) async {
    await _firestore.collection('workouts').doc(id).delete();
  }
}
