import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import 'link_request.dart';

class LinkRequestRepository {
  final FirebaseFirestore _firestore;

  const LinkRequestRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('link_requests');

  /// Create a new link request from trainee to trainer
  Future<String> createRequest({
    required String traineeId,
    required String traineeName,
    required String traineeEmail,
    required String trainerId,
    required String trainerName,
    String? qrNonce,
  }) async {
    // Check if there's already a pending request
    final existing = await _collection
        .where('traineeId', isEqualTo: traineeId)
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existing.docs.isNotEmpty) {
      throw LinkRequestException('A pending request already exists');
    }

    final doc = await _collection.add({
      'traineeId': traineeId,
      'traineeName': traineeName,
      'traineeEmail': traineeEmail,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'qrNonce': qrNonce,
    });

    return doc.id;
  }

  /// Accept a link request (trainer action)
  Future<void> acceptRequest({
    required String requestId,
    String? message,
  }) async {
    final request = await getRequest(requestId);
    if (request == null) {
      throw LinkRequestException('Request not found');
    }
    if (request.status != LinkRequestStatus.pending) {
      throw LinkRequestException('Request is not pending');
    }

    // Transaction: update request + set trainerId on user
    await _firestore.runTransaction((transaction) async {
      // Update request
      transaction.update(_collection.doc(requestId), {
        'status': 'accepted',
        'respondedAt': DateTime.now().toIso8601String(),
        'responseMessage': message,
      });

      // Update trainee's trainerId
      transaction.update(
        _firestore.collection('users').doc(request.traineeId),
        {'trainerId': request.trainerId},
      );
    });
  }

  /// Decline a link request (trainer action)
  Future<void> declineRequest({
    required String requestId,
    String? reason,
  }) async {
    final request = await getRequest(requestId);
    if (request == null) {
      throw LinkRequestException('Request not found');
    }
    if (request.status != LinkRequestStatus.pending) {
      throw LinkRequestException('Request is not pending');
    }

    await _collection.doc(requestId).update({
      'status': 'declined',
      'respondedAt': DateTime.now().toIso8601String(),
      'responseMessage': reason,
    });
  }

  /// Cancel a pending request (trainee action)
  Future<void> cancelRequest(String requestId) async {
    final request = await getRequest(requestId);
    if (request == null) {
      throw LinkRequestException('Request not found');
    }
    if (request.status != LinkRequestStatus.pending) {
      throw LinkRequestException('Can only cancel pending requests');
    }

    await _collection.doc(requestId).update({
      'status': 'cancelled',
      'respondedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get a single request by ID
  Future<LinkRequest?> getRequest(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return LinkRequest.fromMap(doc.id, doc.data()!);
  }

  /// Stream requests for a trainer (incoming)
  Stream<List<LinkRequest>> watchTrainerRequests(String trainerId) {
    return _collection
        .where('trainerId', isEqualTo: trainerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LinkRequest.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Stream requests for a trainee (outgoing)
  Stream<List<LinkRequest>> watchTraineeRequests(String traineeId) {
    return _collection
        .where('traineeId', isEqualTo: traineeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LinkRequest.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Get pending request count for trainer (for badges)
  Stream<int> watchPendingCount(String trainerId) {
    return _collection
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.length);
  }
}

class LinkRequestException implements Exception {
  final String message;
  LinkRequestException(this.message);
  @override
  String toString() => message;
}

/// Riverpod provider
final linkRequestRepositoryProvider = Provider<LinkRequestRepository>((ref) {
  return LinkRequestRepository(firestore: ref.watch(firestoreProvider));
});
