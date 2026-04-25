import 'dart:math';
import 'user_profile.dart';
import 'exercise.dart';

/// K-Nearest Neighbors Service for Exercise Recommendations
class KNNService {
  static const int defaultK = 5;

  /// Find K nearest neighbors based on user features
  static List<NeighborDistance> findNearestNeighbors(
    UserProfile target,
    List<UserProfile> allUsers, {
    int k = defaultK,
  }) {
    final targetFeatures = target.toFeatureVector();

    // Calculate distances to all users
    final distances = <NeighborDistance>[];

    for (final user in allUsers) {
      if (user.id == target.id) continue; // Skip self

      final userFeatures = user.toFeatureVector();
      final distance = _calculateWeightedEuclideanDistance(
        targetFeatures,
        userFeatures,
      );

      distances.add(NeighborDistance(
        user: user,
        distance: distance,
        similarityScore: 1 / (1 + distance), // Convert distance to similarity
      ));
    }

    // Sort by distance (ascending)
    distances.sort((a, b) => a.distance.compareTo(b.distance));

    // Return top K
    return distances.take(k).toList();
  }

  /// Get exercise recommendations for target user
  static KNNRecommendation? recommendExercise(
    UserProfile target,
    List<UserProfile> allUsers,
    Exercise exercise, {
    int k = defaultK,
  }) {
    // Find similar users
    final neighbors = findNearestNeighbors(target, allUsers, k: k);

    if (neighbors.isEmpty) return null;

    // Get exercise history from neighbors
    final neighborPerformances = <UserExerciseHistory>[];

    for (final neighbor in neighbors) {
      final performance = neighbor.user.getExercisePerformance(exercise.id);
      if (performance != null) {
        neighborPerformances.add(performance);
      }
    }

    if (neighborPerformances.isEmpty) {
      // No similar users have done this exercise
      return _createDefaultRecommendation(exercise, target, neighbors);
    }

    // Calculate weighted average based on similarity
    double totalWeight = 0;
    double weightSum = 0;
    double repsSum = 0;
    int setsSum = 0;

    for (int i = 0; i < neighborPerformances.length; i++) {
      final performance = neighborPerformances[i];
      final similarity = neighbors[i].similarityScore;

      totalWeight += similarity;
      weightSum += performance.avgWeight * similarity;
      repsSum += performance.avgReps * similarity;
      setsSum += (performance.totalSets ~/ 3) *
          similarity.round(); // Average sets per session
    }

    final recommendedWeight = weightSum / totalWeight;
    final recommendedReps = (repsSum / totalWeight).round();
    final recommendedSets = (setsSum / totalWeight).round().clamp(3, 5);

    // Calculate confidence based on data availability
    final confidence = neighborPerformances.length / k;

    // Build similar users list
    final similarUsers = neighbors
        .where((n) => n.user.getExercisePerformance(exercise.id) != null)
        .map((n) {
          final perf = n.user.getExercisePerformance(exercise.id)!;
          return SimilarUser(
            userId: n.user.id,
            name: n.user.name,
            similarityScore: n.similarityScore,
            theirWeight: perf.avgWeight,
            theirReps: perf.avgReps,
          );
        })
        .take(3)
        .toList();

    // Generate reason
    final reason = _generateRecommendationReason(
      target,
      neighbors.first.user,
      exercise,
      recommendedWeight,
    );

    return KNNRecommendation(
      exerciseId: exercise.id,
      exerciseName: exercise.nameAr,
      recommendedWeight: recommendedWeight,
      recommendedReps: recommendedReps,
      recommendedSets: recommendedSets,
      confidence: confidence,
      similarUsers: similarUsers,
      reason: reason,
    );
  }

  /// Compare current performance with similar users
  static PerformanceComparison comparePerformance(
    UserProfile target,
    List<UserProfile> allUsers,
    String exerciseId,
    double currentWeight,
    int currentReps, {
    int k = defaultK,
  }) {
    final neighbors = findNearestNeighbors(target, allUsers, k: k);

    if (neighbors.isEmpty) {
      return const PerformanceComparison(
        isBetter: false,
        difference: 0,
        message: 'لا يوجد بيانات كافية للمقارنة',
        percentile: 50,
      );
    }

    // Get current 1RM
    final current1RM =
        UserExerciseHistory.calculateOneRepMax(currentWeight, currentReps);

    // Collect 1RMs from similar users
    final similar1RMs = <double>[];

    for (final neighbor in neighbors) {
      final performance = neighbor.user.getExercisePerformance(exerciseId);
      if (performance != null) {
        similar1RMs.add(performance.oneRepMax);
      }
    }

    if (similar1RMs.isEmpty) {
      return const PerformanceComparison(
        isBetter: false,
        difference: 0,
        message: 'المستخدمون المشابهون لم يجربوا هذا التمرين بعد',
        percentile: 50,
      );
    }

    // Calculate statistics
    similar1RMs.sort();
    final avg1RM = similar1RMs.reduce((a, b) => a + b) / similar1RMs.length;

    // Calculate percentile
    int betterCount = 0;
    for (final rm in similar1RMs) {
      if (current1RM > rm) betterCount++;
    }
    final percentile = (betterCount / similar1RMs.length * 100).round();

    // Determine if better or worse
    final difference = ((current1RM - avg1RM) / avg1RM * 100).round();
    final isBetter = difference > 0;

    String message;
    if (difference > 10) {
      message = '💪 أداؤك أقوى من $percentile% من المستخدمين المشابهين!';
    } else if (difference < -10) {
      message =
          '📈 أنت أقل من المتوسط بـ ${difference.abs()}%. حاول زيادة الوزن تدريجياً';
    } else {
      message = '✅ أداؤك متوسط مقارنة بالمستخدمين المشابهين';
    }

    return PerformanceComparison(
      isBetter: isBetter,
      difference: difference,
      message: message,
      percentile: percentile,
    );
  }

  /// Get next weight recommendation
  static WeightSuggestion suggestNextWeight(
    UserProfile target,
    List<UserProfile> allUsers,
    String exerciseId,
    double currentWeight,
    int currentReps, {
    int k = defaultK,
  }) {
    final neighbors = findNearestNeighbors(target, allUsers, k: k);

    // Find users who progressed from similar stats
    final progressions = <double>[]; // Weight increases

    for (final neighbor in neighbors) {
      final performance = neighbor.user.getExercisePerformance(exerciseId);
      if (performance != null) {
        final neighbor1RM = performance.oneRepMax;
        final current1RM =
            UserExerciseHistory.calculateOneRepMax(currentWeight, currentReps);

        // If neighbor is stronger, see what weight they use
        if (neighbor1RM > current1RM * 1.1) {
          // Assume they started similar to current user
          final suggestedIncrease = performance.avgWeight - currentWeight;
          if (suggestedIncrease > 0 && suggestedIncrease <= 10) {
            progressions.add(suggestedIncrease);
          }
        }
      }
    }

    if (progressions.isEmpty) {
      // Default progression
      return WeightSuggestion(
        suggestedWeight: currentWeight + 2.5,
        confidence: 0.5,
        reason: 'زيادة تدريجية قياسية 2.5 كجم',
      );
    }

    // Average the suggested increases
    final avgIncrease =
        progressions.reduce((a, b) => a + b) / progressions.length;
    final roundedIncrease =
        (avgIncrease / 2.5).round() * 2.5; // Round to nearest 2.5

    return WeightSuggestion(
      suggestedWeight: currentWeight + roundedIncrease.clamp(2.5, 10.0),
      confidence: 0.7,
      reason:
          'المستخدمون المشابهون زادوا بمتوسط ${avgIncrease.toStringAsFixed(1)} كجم',
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Calculate weighted Euclidean distance
  static double _calculateWeightedEuclideanDistance(
    List<double> a,
    List<double> b,
  ) {
    assert(a.length == b.length);

    final weights = [
      FeatureWeights.age,
      FeatureWeights.weight,
      FeatureWeights.height,
      FeatureWeights.goal,
      FeatureWeights.level,
      FeatureWeights.gender,
    ];

    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += weights[i] * diff * diff;
    }

    return sqrt(sum);
  }

  /// Create default recommendation when no data
  static KNNRecommendation _createDefaultRecommendation(
    Exercise exercise,
    UserProfile target,
    List<NeighborDistance> neighbors,
  ) {
    // Based on fitness level
    double baseWeight;
    int baseReps;

    switch (target.level) {
      case FitnessLevel.beginner:
        baseWeight = 20; // Start light
        baseReps = 12;
        break;
      case FitnessLevel.intermediate:
        baseWeight = 40;
        baseReps = 10;
        break;
      case FitnessLevel.advanced:
        baseWeight = 60;
        baseReps = 8;
        break;
    }

    // Adjust for goal
    if (target.goal == FitnessGoal.buildMuscle) {
      baseReps = 10;
    } else if (target.goal == FitnessGoal.increaseStrength) {
      baseReps = 5;
      baseWeight *= 1.2;
    }

    return KNNRecommendation(
      exerciseId: exercise.id,
      exerciseName: exercise.nameAr,
      recommendedWeight: baseWeight,
      recommendedReps: baseReps,
      recommendedSets: 3,
      confidence: 0.3,
      similarUsers: neighbors
          .take(2)
          .map((n) => SimilarUser(
                userId: n.user.id,
                name: n.user.name,
                similarityScore: n.similarityScore,
                theirWeight: 0,
                theirReps: 0,
              ))
          .toList(),
      reason:
          'توصية أولية بناءً على مستواك (${target.level.displayName}) وهدفك',
    );
  }

  /// Generate human-readable reason
  static String _generateRecommendationReason(
    UserProfile target,
    UserProfile mostSimilar,
    Exercise exercise,
    double recommendedWeight,
  ) {
    final parts = <String>[];

    if ((target.age - mostSimilar.age).abs() < 5) {
      parts.add('نفس الفئة العمرية');
    }

    if (target.goal == mostSimilar.goal) {
      parts.add('نفس الهدف (${target.goal.displayName})');
    }

    if ((target.weight - mostSimilar.weight).abs() < 10) {
      parts.add('وزن مشابه');
    }

    if (parts.isEmpty) {
      return 'بناءً على ${mostSimilar.name} المستخدم المشابه';
    }

    return 'بناءً على: ${parts.join('، ')}';
  }
}

/// Neighbor with distance
class NeighborDistance {
  final UserProfile user;
  final double distance;
  final double similarityScore;

  NeighborDistance({
    required this.user,
    required this.distance,
    required this.similarityScore,
  });
}

/// Performance comparison result
class PerformanceComparison {
  final bool isBetter;
  final int difference; // Percentage
  final String message;
  final int percentile; // 0-100

  const PerformanceComparison({
    required this.isBetter,
    required this.difference,
    required this.message,
    required this.percentile,
  });
}

/// Weight suggestion
class WeightSuggestion {
  final double suggestedWeight;
  final double confidence;
  final String reason;

  const WeightSuggestion({
    required this.suggestedWeight,
    required this.confidence,
    required this.reason,
  });
}
