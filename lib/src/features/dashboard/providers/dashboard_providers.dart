import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';

import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(firestoreProvider));
});

final usersCollectionProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchCollection('users');
});

final subscriptionsCollectionProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchCollection('subscriptions');
});
