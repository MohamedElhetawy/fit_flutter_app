import 'package:cloud_firestore/cloud_firestore.dart';
import 'gym_models.dart';

class GymRepository {
  GymRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<GymOverview> watchGymOverview(String gymId) {
    return _firestore.collection('gyms').doc(gymId).snapshots().map((doc) {
      final data = doc.data() ?? {};
      return GymOverview.fromMap(data);
    });
  }

  Stream<List<Trainer>> watchGymTrainers(String gymId) {
    return _firestore
        .collection('users')
        .where('gymId', isEqualTo: gymId)
        .where('role', isEqualTo: 'trainer')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Trainer.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<Trainee>> watchGymTrainees(String gymId) {
    return _firestore
        .collection('users')
        .where('gymId', isEqualTo: gymId)
        .where('role', isEqualTo: 'trainee')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Trainee.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<GymActivity>> watchGymActivities(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((d) => GymActivity.fromMap(d.data(), d.id)).toList());
  }
}
