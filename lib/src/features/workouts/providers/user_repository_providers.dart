import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../data/user_profile.dart';
import '../data/user_repository.dart';

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return UserRepository(firestore: firestore, auth: auth);
});

/// Current user profile from backend (Future)
final currentUserBackendProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getCurrentUserProfile();
});

/// Current user profile from backend (Stream for real-time)
final currentUserStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  final uid = repository.currentUserId;
  
  if (uid == null) return Stream.value(null);

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return repository.userProfileFromFirestore(doc.data()!, uid);
  });
});

/// All users for K-NN from backend (Future)
final allUsersBackendProvider = FutureProvider<List<UserProfile>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getAllUsersForKNN();
});

/// All users for K-NN from backend (Stream for real-time)
final allUsersBackendStreamProvider = StreamProvider<List<UserProfile>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchAllUsersForKNN();
});

/// Current user's exercise history from backend
final currentUserExerciseHistoryProvider = FutureProvider<List<UserExerciseHistory>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getAllExerciseHistory();
});

/// Stream of current user's exercise history (real-time)
final exerciseHistoryStreamProvider = StreamProvider<List<UserExerciseHistory>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchExerciseStats();
});

/// Get exercise history for a specific exercise
final exerciseHistoryForExerciseProvider = FutureProvider.family<UserExerciseHistory?, String>((ref, exerciseId) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getExerciseHistory(exerciseId);
});

/// Similar users from backend (with caching)
final similarUsersBackendProvider = FutureProvider.family<List<UserProfile>, SimilarUsersFilter>((ref, filter) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getSimilarUsers(
    goal: filter.goal,
    level: filter.level,
    minAge: filter.minAge,
    maxAge: filter.maxAge,
    limit: filter.limit,
  );
});

/// Filter class for similar users query
class SimilarUsersFilter {
  final FitnessGoal? goal;
  final FitnessLevel? level;
  final double? minAge;
  final double? maxAge;
  final int limit;

  const SimilarUsersFilter({
    this.goal,
    this.level,
    this.minAge,
    this.maxAge,
    this.limit = 20,
  });
}

/// K-NN enabled provider - uses backend data
/// This replaces the mock data provider in knn_providers.dart
final knnAllUsersBackendProvider = Provider<AsyncValue<List<UserProfile>>>((ref) {
  // Use real-time stream if available, otherwise fallback to future
  final streamAsync = ref.watch(allUsersBackendStreamProvider);
  
  if (streamAsync.hasValue) {
    return streamAsync;
  }
  
  // Fallback to one-time fetch
  return ref.watch(allUsersBackendProvider);
});

/// Current user for K-NN from backend
final knnCurrentUserBackendProvider = Provider<AsyncValue<UserProfile?>>((ref) {
  final streamAsync = ref.watch(currentUserStreamProvider);
  
  if (streamAsync.hasValue) {
    return streamAsync;
  }
  
  return ref.watch(currentUserBackendProvider);
});
