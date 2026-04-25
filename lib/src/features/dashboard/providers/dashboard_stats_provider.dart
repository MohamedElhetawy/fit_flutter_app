import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/auth/app_role.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';

import '../data/dashboard_stats.dart';
import '../data/dashboard_stats_repository.dart';

const _statsCacheKey = 'dashboard_admin_stats_cache';

final dashboardStatsRepositoryProvider =
    Provider<DashboardStatsRepository>((ref) {
  return DashboardStatsRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final dashboardStatsProvider =
    AsyncNotifierProvider<DashboardStatsNotifier, DashboardStats>(
  DashboardStatsNotifier.new,
);

class DashboardStatsNotifier extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    final cached = await _readCache();
    if (cached != null) {
      Future<void>(() => refresh());
      return cached;
    }
    return refresh();
  }

  Future<DashboardStats> refresh() async {
    final role = ref.read(currentUserRoleProvider).value ?? AppRole.trainee;
    final repo = ref.read(dashboardStatsRepositoryProvider);
    final latest = switch (role) {
      AppRole.superAdmin => await repo.getAdminStats(),
      AppRole.admin || AppRole.gym => await repo.getAdminStats(),
      AppRole.trainer => await repo.getTrainerStats(),
      AppRole.trainee => await repo.getUserStats(),
    };
    await _writeCache(latest);
    state = AsyncData(latest);
    return latest;
  }

  Future<void> _writeCache(DashboardStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsCacheKey, jsonEncode(stats.toMap()));
  }

  Future<DashboardStats?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsCacheKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return DashboardStats.fromMap(map);
  }
}
