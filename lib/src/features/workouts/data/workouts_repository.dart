import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout.dart';

class WorkoutsRepository {
  WorkoutsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Workout>> watchWorkouts() {
    return _firestore.collection('workouts').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Workout.fromMap(doc.id, doc.data()))
          .toList(growable: false);
    });
  }
}
