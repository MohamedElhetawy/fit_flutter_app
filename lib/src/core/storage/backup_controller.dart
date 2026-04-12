import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';

import 'drive_backup_service.dart';
import 'local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final driveBackupServiceProvider = Provider<DriveBackupService>((ref) {
  return DriveBackupService();
});

final backupControllerProvider =
    AsyncNotifierProvider<BackupController, String?>(BackupController.new);

class BackupController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> backupCurrentUserData() async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) throw Exception('User not authenticated');

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final userDoc = await firestore.collection('users').doc(uid).get();
      final workouts = await firestore
          .collection('workouts')
          .where('userId', isEqualTo: uid)
          .get();
      final subscriptions = await firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: uid)
          .get();
      final tasks = await firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .get();
      final nutrition = await firestore
          .collection('users')
          .doc(uid)
          .collection('nutrition_logs')
          .get();

      final snapshot = <String, dynamic>{
        'uid': uid,
        'user': userDoc.data(),
        'workouts': workouts.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        'subscriptions':
            subscriptions.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        'tasks': tasks.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        'nutrition': nutrition.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      };

      await ref.read(localStorageServiceProvider).saveSnapshot(uid, snapshot);
      await ref.read(driveBackupServiceProvider).uploadBackup(
            uid: uid,
            payload: snapshot,
          );

      return 'Backup uploaded to Google Drive and saved locally';
    });
  }

  Future<void> restoreCurrentUserData() async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) throw Exception('User not authenticated');

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final backup = await ref.read(driveBackupServiceProvider).downloadBackup(uid);
      if (backup == null) return 'No backup found in Drive';

      final batch = firestore.batch();
      final user = backup['user'] as Map<String, dynamic>?;
      if (user != null) {
        batch.set(
          firestore.collection('users').doc(uid),
          user,
          SetOptions(merge: true),
        );
      }

      final tasks = (backup['tasks'] as List?) ?? [];
      for (final item in tasks) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map.remove('id')?.toString();
        if (id == null) continue;
        batch.set(
          firestore.collection('users').doc(uid).collection('tasks').doc(id),
          map,
          SetOptions(merge: true),
        );
      }

      final nutrition = (backup['nutrition'] as List?) ?? [];
      for (final item in nutrition) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map.remove('id')?.toString();
        if (id == null) continue;
        batch.set(
          firestore.collection('users').doc(uid).collection('nutrition_logs').doc(id),
          map,
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      await ref.read(localStorageServiceProvider).saveSnapshot(uid, backup);
      return 'Data restored from Google Drive';
    });
  }
}
