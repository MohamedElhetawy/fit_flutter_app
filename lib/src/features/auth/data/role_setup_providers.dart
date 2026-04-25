import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'role_setup_repository.dart';

final roleSetupRepositoryProvider = Provider<RoleSetupRepository>((ref) {
  return RoleSetupRepository(
    ref.watch(firestoreProvider),
    ref.watch(authRepositoryProvider),
  );
});
