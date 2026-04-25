import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../local_db/local_db_service.dart';
import 'sync_event.dart';
import '../network/connectivity_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/firebase_providers.dart';
import '../providers/local_db_provider.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final connectivityStatus = ref.watch(connectivityStatusProvider);
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  
  final engine = SyncEngine(LocalDbService().isar, firestore, auth);
  
  // Re-trigger sync queue if network comes online
  if (connectivityStatus == CustomNetworkStatus.on) {
    engine.processQueue();
  }
  
  return engine;
});

/// Async provider variant that waits for an initialized Isar instance.
final syncEngineAsyncProvider = FutureProvider<SyncEngine>((ref) async {
  final connectivityStatus = ref.watch(connectivityStatusProvider);
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);

  final isar = await ref.watch(isarProvider.future);

  final engine = SyncEngine(isar, firestore, auth);

  // Re-trigger sync queue if network comes online
  if (connectivityStatus == CustomNetworkStatus.on) {
    engine.processQueue();
  }

  return engine;
});

class SyncEngine {
  final Isar _isar;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  bool _isProcessing = false;

  SyncEngine(this._isar, this._firestore, this._auth);

  /// Enqueue a sync event to be processed
  Future<void> enqueueEvent({
    required String collectionName,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final event = SyncEvent()
      ..collectionName = collectionName
      ..recordId = recordId
      ..operation = operation
      ..payload = jsonEncode(payload)
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.syncEvents.put(event);
    });

    // Try processing the queue whenever a new event is added
    processQueue();
  }

  /// Process the queue in the background
  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final pendingEvents = await _isar.syncEvents
          .filter()
          .hasErrorEqualTo(false)
          .sortByCreatedAt()
          .findAll();

      for (final event in pendingEvents) {
        bool success = await _uploadToFirebase(event);
        
        if (success) {
          await _isar.writeTxn(() async {
            await _isar.syncEvents.delete(event.id);
          });
        } else {
          await _isar.writeTxn(() async {
            event.retryCount += 1;
            if (event.retryCount > 5) {
              event.hasError = true;
              event.errorMessage = 'Max retries exceeded.';
            }
            await _isar.syncEvents.put(event);
          });
        }
      }
    } catch (e) {
      debugPrint('SyncEngine processQueue error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _uploadToFirebase(SyncEvent event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false; // Don't wipe the queue, wait for login

      // If collection name implies a user specific root, we inject the UID dynamically.
      String targetPath = event.collectionName;
      if (targetPath.contains('{uid}')) {
        targetPath = targetPath.replaceAll('{uid}', user.uid);
      } else if (!targetPath.contains('/')) {
        // Safe fallback for root-level stuff maybe? Usually we want it isolated per user in FitX.
        // E.g., 'daily_stats' becomes 'users/{uid}/daily_stats' if passed like that.
      }

      final docRef = _firestore.collection(targetPath).doc(event.recordId);
      final payload = jsonDecode(event.payload);

      if (event.operation == 'CREATE' || event.operation == 'UPDATE') {
        await docRef.set(payload, SetOptions(merge: true));
        return true;
      } else if (event.operation == 'DELETE') {
        await docRef.delete();
        return true;
      }
      
      return false; // Unknown operation type
    } catch (e) {
      debugPrint('SyncEngine Upload Error: $e');
      return false; 
    }
  }
}
