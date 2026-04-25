import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_profile.dart';
import '../data/knn_service.dart';
import '../data/exercise.dart';
import 'user_repository_providers.dart';

/// K-NN Providers using Backend Data (Firebase)
///
/// These providers replace the mock data providers in knn_providers.dart
/// and use real-time data from Firestore.

/// K value for K-NN (configurable)
final knnKValueProvider = StateProvider<int>((ref) => 5);

/// Performance comparison provider - BACKEND VERSION
final performanceComparisonBackendProvider = Provider.family<
    AsyncValue<PerformanceComparison?>,
    (
      Exercise exercise,
      double currentWeight,
      int currentReps,
    )>((ref, params) {
  final currentUserAsync = ref.watch(currentUserBackendProvider);
  final allUsersAsync = ref.watch(allUsersBackendProvider);
  final k = ref.watch(knnKValueProvider);

  return currentUserAsync.when(
    data: (currentUser) {
      if (currentUser == null) {
        return const AsyncValue.data(null);
      }

      return allUsersAsync.when(
        data: (allUsers) {
          if (allUsers.length < k) {
            return const AsyncValue.data(null);
          }

          final result = KNNService.comparePerformance(
            currentUser,
            allUsers,
            params.$1.id,
            params.$2,
            params.$3,
            k: k,
          );

          return AsyncValue.data(result);
        },
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

/// Weight suggestion provider - BACKEND VERSION
final weightSuggestionBackendProvider = Provider.family<
    AsyncValue<WeightSuggestion?>,
    (
      Exercise exercise,
      double currentWeight,
      int currentReps,
    )>((ref, params) {
  final currentUserAsync = ref.watch(currentUserBackendProvider);
  final allUsersAsync = ref.watch(allUsersBackendProvider);
  final k = ref.watch(knnKValueProvider);

  return currentUserAsync.when(
    data: (currentUser) {
      if (currentUser == null) {
        return const AsyncValue.data(null);
      }

      return allUsersAsync.when(
        data: (allUsers) {
          if (allUsers.length < k) {
            return const AsyncValue.data(null);
          }

          final result = KNNService.suggestNextWeight(
            currentUser,
            allUsers,
            params.$1.id,
            params.$2,
            params.$3,
            k: k,
          );

          return AsyncValue.data(result);
        },
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

/// Exercise recommendation provider - BACKEND VERSION
final exerciseRecommendationBackendProvider =
    FutureProvider.family<KNNRecommendation?, Exercise>(
  (ref, exercise) async {
    final currentUser = await ref.watch(currentUserBackendProvider.future);
    final allUsers = await ref.watch(allUsersBackendProvider.future);
    final k = ref.watch(knnKValueProvider);

    if (currentUser == null || allUsers.length < k) {
      return null;
    }

    return KNNService.recommendExercise(
      currentUser,
      allUsers,
      exercise,
      k: k,
    );
  },
);

/// Similar users for current exercise - BACKEND VERSION
final similarUsersBackendProvider =
    Provider.family<AsyncValue<List<SimilarUser>?>, Exercise>(
  (ref, exercise) {
    final currentUserAsync = ref.watch(currentUserBackendProvider);
    final allUsersAsync = ref.watch(allUsersBackendProvider);
    final k = ref.watch(knnKValueProvider);

    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          return const AsyncValue.data(null);
        }

        return allUsersAsync.when(
          data: (allUsers) {
            if (allUsers.length < k) {
              return const AsyncValue.data(null);
            }

            final neighbors = KNNService.findNearestNeighbors(
              currentUser,
              allUsers,
              k: k,
            );

            final similarUsers = neighbors
                .where(
                    (n) => n.user.getExercisePerformance(exercise.id) != null)
                .map((n) {
              final perf = n.user.getExercisePerformance(exercise.id)!;
              return SimilarUser(
                userId: n.user.id,
                name: n.user.name,
                similarityScore: n.similarityScore,
                theirWeight: perf.avgWeight,
                theirReps: perf.avgReps,
              );
            }).toList();

            return AsyncValue.data(similarUsers);
          },
          loading: () => const AsyncValue.loading(),
          error: (err, stack) => AsyncValue.error(err, stack),
        );
      },
      loading: () => const AsyncValue.loading(),
      error: (err, stack) => AsyncValue.error(err, stack),
    );
  },
);

/// K-NN stats provider - BACKEND VERSION
final knnStatsBackendProvider =
    Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final currentUserAsync = ref.watch(currentUserBackendProvider);
  final allUsersAsync = ref.watch(allUsersBackendProvider);

  return allUsersAsync.when(
    data: (allUsers) {
      // Count users by level
      final beginnerCount =
          allUsers.where((u) => u.level == FitnessLevel.beginner).length;
      final intermediateCount =
          allUsers.where((u) => u.level == FitnessLevel.intermediate).length;
      final advancedCount =
          allUsers.where((u) => u.level == FitnessLevel.advanced).length;

      // Count by goal
      final goalDistribution = <FitnessGoal, int>{};
      for (final goal in FitnessGoal.values) {
        goalDistribution[goal] = allUsers.where((u) => u.goal == goal).length;
      }

      double similarityScore = 0;
      if (currentUserAsync.hasValue && currentUserAsync.value != null) {
        similarityScore = _calculateAverageSimilarity(
          currentUserAsync.value!,
          allUsers,
        );
      }

      return AsyncValue.data({
        'totalUsers': allUsers.length,
        'beginnerCount': beginnerCount,
        'intermediateCount': intermediateCount,
        'advancedCount': advancedCount,
        'goalDistribution': goalDistribution,
        'currentUserSimilarityScore': similarityScore,
      });
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

/// Helper function to calculate average similarity
double _calculateAverageSimilarity(
    UserProfile target, List<UserProfile> allUsers) {
  if (allUsers.isEmpty) return 0;

  final targetFeatures = target.toFeatureVector();
  double totalSimilarity = 0;
  int count = 0;

  for (final user in allUsers) {
    if (user.id == target.id) continue;

    final userFeatures = user.toFeatureVector();
    double sumSquaredDiff = 0;

    for (int i = 0; i < targetFeatures.length; i++) {
      final diff = targetFeatures[i] - userFeatures[i];
      sumSquaredDiff += diff * diff;
    }

    final distance = sumSquaredDiff == 0 ? 0 : sumSquaredDiff;
    final similarity = 1 / (1 + distance);
    totalSimilarity += similarity;
    count++;
  }

  return count > 0 ? totalSimilarity / count : 0;
}

/// Combined K-NN data provider for UI consumption
/// Provides all K-NN data in one place for the ExerciseExecutionScreen
final knnDataForExerciseProvider = Provider.family<
    AsyncValue<KNNExerciseData>,
    (
      Exercise exercise,
      double? currentWeight,
      int? currentReps,
    )>((ref, params) {
  final exercise = params.$1;
  final weight = params.$2 ?? 0;
  final reps = params.$3 ?? 0;

  final recommendationAsync =
      ref.watch(exerciseRecommendationBackendProvider(exercise));
  final comparisonAsync =
      ref.watch(performanceComparisonBackendProvider((exercise, weight, reps)));
  final suggestionAsync =
      ref.watch(weightSuggestionBackendProvider((exercise, weight, reps)));
  final similarUsersAsync = ref.watch(similarUsersBackendProvider(exercise));

  // Combine all async values
  if (recommendationAsync is AsyncLoading ||
      comparisonAsync is AsyncLoading ||
      suggestionAsync is AsyncLoading ||
      similarUsersAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (recommendationAsync is AsyncError) {
    return AsyncValue.error(
        recommendationAsync.error!, recommendationAsync.stackTrace!);
  }

  return AsyncValue.data(KNNExerciseData(
    recommendation: recommendationAsync.value,
    comparison: comparisonAsync.value,
    weightSuggestion: suggestionAsync.value,
    similarUsers: similarUsersAsync.value ?? [],
  ));
});

/// Data class to hold all K-NN data for an exercise
class KNNExerciseData {
  final KNNRecommendation? recommendation;
  final PerformanceComparison? comparison;
  final WeightSuggestion? weightSuggestion;
  final List<SimilarUser> similarUsers;

  const KNNExerciseData({
    this.recommendation,
    this.comparison,
    this.weightSuggestion,
    this.similarUsers = const [],
  });

  bool get hasData =>
      recommendation != null ||
      comparison != null ||
      weightSuggestion != null ||
      similarUsers.isNotEmpty;
}
