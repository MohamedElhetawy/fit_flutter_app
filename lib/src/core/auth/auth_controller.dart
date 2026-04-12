import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_role.dart';
import 'app_user.dart';
import 'auth_repository.dart';
import 'permissions.dart';
import '../providers/firebase_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserRoleProvider = StreamProvider<AppRole?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(authRepositoryProvider).watchRole(user.uid);
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(authRepositoryProvider).watchUser(user.uid);
});

final currentPermissionsProvider = Provider<Set<AppPermission>>((ref) {
  final role = ref.watch(currentUserRoleProvider).value;
  if (role == null) return <AppPermission>{};
  return RolePermissions.byRole[role] ?? <AppPermission>{};
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email: email, password: password);
    });
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmailAndPassword(email: email, password: password);
    });
  }

  Future<void> signInWithGoogleMobile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogleMobile();
    });
  }

  /// Unified Google Sign-In that works on both Web and Mobile
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (kIsWeb) {
        await ref.read(authRepositoryProvider).signInWithGoogleWeb();
      } else {
        await ref.read(authRepositoryProvider).signInWithGoogleMobile();
      }
    });
  }

  Future<void> saveRole(AppRole role) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('No authenticated user found');
      await ref.read(authRepositoryProvider).saveUserRole(
            uid: user.uid,
            role: role,
            email: user.email,
          );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
    });
  }
}
