import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  UserProgress({
    required this.currentWeight,
    required this.weightChange,
    required this.lastUpdated,
    this.goalWeight,
  });

  final double currentWeight;
  final double weightChange;
  final DateTime lastUpdated;
  final double? goalWeight;

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      currentWeight: (map['currentWeight'] as num?)?.toDouble() ?? 0.0,
      weightChange: (map['weightChange'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      goalWeight: (map['goalWeight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'currentWeight': currentWeight,
        'weightChange': weightChange,
        'lastUpdated': Timestamp.fromDate(lastUpdated),
        'goalWeight': goalWeight,
      };

  /// Weight progress ratio (0.0 – 1.0) relative to an optional goal.
  double get progressRatio {
    if (goalWeight == null || goalWeight == 0) return 0.5;
    // Clamp between 0 and 1
    final ratio = currentWeight / goalWeight!;
    return ratio.clamp(0.0, 1.0);
  }
}
