import 'dart:math';

/// User Profile with features for K-NN algorithm
class UserProfile {
  final String id;
  final String name;
  final double age; // years
  final double weight; // kg
  final double height; // cm
  final FitnessGoal goal;
  final FitnessLevel level;
  final Gender gender;
  final List<UserExerciseHistory> exerciseHistory;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    required this.level,
    required this.gender,
    this.exerciseHistory = const [],
    required this.createdAt,
  });

  /// Convert to feature vector for K-NN
  /// [age, weight, height, goal_encoded, level_encoded, gender_encoded]
  List<double> toFeatureVector() {
    return [
      age,
      weight,
      height,
      goal.encodedValue,
      level.encodedValue,
      gender.encodedValue,
    ];
  }

  /// Calculate BMI
  double get bmi => weight / pow(height / 100, 2);

  /// Get average performance for an exercise
  UserExerciseHistory? getExercisePerformance(String exerciseId) {
    try {
      return exerciseHistory.firstWhere((e) => e.exerciseId == exerciseId);
    } catch (_) {
      return null;
    }
  }

  /// Factory for current user (placeholder - replace with actual auth)
  factory UserProfile.currentUser() {
    return UserProfile(
      id: 'current_user',
      name: 'المستخدم',
      age: 25,
      weight: 75,
      height: 175,
      goal: FitnessGoal.buildMuscle,
      level: FitnessLevel.beginner,
      gender: Gender.male,
      createdAt: DateTime.now(),
    );
  }

  /// Copy with updates
  UserProfile copyWith({
    String? id,
    String? name,
    double? age,
    double? weight,
    double? height,
    FitnessGoal? goal,
    FitnessLevel? level,
    Gender? gender,
    List<UserExerciseHistory>? exerciseHistory,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      gender: gender ?? this.gender,
      exerciseHistory: exerciseHistory ?? this.exerciseHistory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// User exercise history entry
class UserExerciseHistory {
  final String exerciseId;
  final String exerciseName;
  final double avgWeight;
  final int avgReps;
  final int totalSets;
  final DateTime lastPerformed;
  final double oneRepMax; // Estimated 1RM

  const UserExerciseHistory({
    required this.exerciseId,
    required this.exerciseName,
    required this.avgWeight,
    required this.avgReps,
    required this.totalSets,
    required this.lastPerformed,
    required this.oneRepMax,
  });

  /// Calculate 1RM using Epley formula: weight * (1 + reps/30)
  static double calculateOneRepMax(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }
}

/// Fitness Goal enum
enum FitnessGoal {
  loseWeight,
  buildMuscle,
  maintainFitness,
  increaseStrength,
  improveEndurance;

  String get displayName {
    switch (this) {
      case FitnessGoal.loseWeight:
        return 'إنقاص الوزن';
      case FitnessGoal.buildMuscle:
        return 'بناء العضلات';
      case FitnessGoal.maintainFitness:
        return 'المحافظة على اللياقة';
      case FitnessGoal.increaseStrength:
        return 'زيادة القوة';
      case FitnessGoal.improveEndurance:
        return 'تحسين القدرة التحملية';
    }
  }

  /// Encoded value for K-NN
  double get encodedValue {
    switch (this) {
      case FitnessGoal.loseWeight:
        return 0.0;
      case FitnessGoal.buildMuscle:
        return 1.0;
      case FitnessGoal.maintainFitness:
        return 2.0;
      case FitnessGoal.increaseStrength:
        return 3.0;
      case FitnessGoal.improveEndurance:
        return 4.0;
    }
  }
}

/// Fitness Level enum
enum FitnessLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return 'مبتدئ';
      case FitnessLevel.intermediate:
        return 'متوسط';
      case FitnessLevel.advanced:
        return 'متقدم';
    }
  }

  /// Encoded value for K-NN
  double get encodedValue {
    switch (this) {
      case FitnessLevel.beginner:
        return 0.0;
      case FitnessLevel.intermediate:
        return 1.0;
      case FitnessLevel.advanced:
        return 2.0;
    }
  }
}

/// Gender enum
enum Gender {
  male,
  female;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'ذكر';
      case Gender.female:
        return 'أنثى';
    }
  }

  /// Encoded value for K-NN
  double get encodedValue {
    switch (this) {
      case Gender.male:
        return 0.0;
      case Gender.female:
        return 1.0;
    }
  }
}

/// K-NN Recommendation Result
class KNNRecommendation {
  final String exerciseId;
  final String exerciseName;
  final double recommendedWeight;
  final int recommendedReps;
  final int recommendedSets;
  final double confidence; // 0.0 to 1.0
  final List<SimilarUser> similarUsers;
  final String reason;

  const KNNRecommendation({
    required this.exerciseId,
    required this.exerciseName,
    required this.recommendedWeight,
    required this.recommendedReps,
    required this.recommendedSets,
    required this.confidence,
    required this.similarUsers,
    required this.reason,
  });
}

/// Similar user info for explanations
class SimilarUser {
  final String userId;
  final String name;
  final double similarityScore; // 0.0 to 1.0
  final double theirWeight;
  final int theirReps;

  const SimilarUser({
    required this.userId,
    required this.name,
    required this.similarityScore,
    required this.theirWeight,
    required this.theirReps,
  });
}

/// Feature weights for distance calculation
class FeatureWeights {
  static const double age = 0.15;
  static const double weight = 0.25;
  static const double height = 0.15;
  static const double goal = 0.20;
  static const double level = 0.20;
  static const double gender = 0.05;
}
