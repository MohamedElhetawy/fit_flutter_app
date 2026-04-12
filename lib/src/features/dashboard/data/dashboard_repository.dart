import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRepository {
  DashboardRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Map<String, dynamic>>> watchCollection(String collection) {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .toList(growable: false);
    });
  }
}
