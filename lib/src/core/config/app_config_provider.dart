import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import '../providers/firebase_providers.dart';

final appConfigProvider = StreamProvider<AppConfig>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('app_config')
      .doc('global')
      .snapshots()
      .map((doc) => AppConfig.fromMap(doc.data()));
});

final appConfigControllerProvider =
    AsyncNotifierProvider<AppConfigController, void>(AppConfigController.new);

class AppConfigController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateConfig(AppConfig config) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(firestoreProvider)
          .collection('app_config')
          .doc('global')
          .set({
        ...config.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
