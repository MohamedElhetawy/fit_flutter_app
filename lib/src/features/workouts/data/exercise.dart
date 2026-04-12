import 'dart:convert';
import 'package:flutter/services.dart';

/// Exercise from local database
class Exercise {
  final String id;
  final String nameAr;
  final String nameEn;
  final String mainCategory;
  final String bodyPart;
  final String muscleGroup;
  final String muscleAngle;
  final String equipment;
  final String difficulty;
  final String gifUrl;

  const Exercise({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.mainCategory,
    required this.bodyPart,
    required this.muscleGroup,
    required this.muscleAngle,
    required this.equipment,
    required this.difficulty,
    required this.gifUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      mainCategory: json['main_category'] as String,
      bodyPart: json['body_part'] as String,
      muscleGroup: json['muscle_group'] as String,
      muscleAngle: json['muscle_angle'] as String,
      equipment: json['equipment'] as String,
      difficulty: json['difficulty'] as String,
      gifUrl: json['gif_url'] as String,
    );
  }

  /// Display name (Arabic)
  String get displayName => nameAr;

  /// Searchable text
  String get searchableText => '$nameAr $nameEn $muscleGroup'.toLowerCase();
}

/// Logged set for exercise tracking
class LoggedSet {
  final int setNumber;
  final double weight;
  final int reps;
  final DateTime timestamp;

  LoggedSet({
    required this.setNumber,
    required this.weight,
    required this.reps,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Local workout database service
class WorkoutDatabase {
  static List<Exercise>? _cachedExercises;

  /// Load all exercises from JSON
  static Future<List<Exercise>> loadExercises() async {
    if (_cachedExercises != null) return _cachedExercises!;

    final jsonString = await rootBundle.loadString('assets/data/mustles.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    _cachedExercises = jsonList
        .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
        .toList();

    return _cachedExercises!;
  }

  /// Get unique muscle groups
  static List<String> getMuscleGroups(List<Exercise> exercises) {
    final groups = exercises.map((e) => e.muscleGroup).toSet().toList();
    groups.sort();
    return groups;
  }

  /// Filter exercises by muscle group
  static List<Exercise> filterByMuscleGroup(
    List<Exercise> exercises,
    String muscleGroup,
  ) {
    return exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  /// Get exercise by ID
  static Exercise? getById(List<Exercise> exercises, String id) {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get unique muscle angles for a muscle group
  static List<String> getMuscleAngles(
    List<Exercise> exercises,
    String muscleGroup,
  ) {
    final angles = exercises
        .where((e) => e.muscleGroup == muscleGroup)
        .map((e) => e.muscleAngle)
        .toSet()
        .toList();
    angles.sort();
    return angles;
  }

  /// Filter exercises by muscle angle
  static List<Exercise> filterByMuscleAngle(
    List<Exercise> exercises,
    String muscleAngle,
  ) {
    return exercises.where((e) => e.muscleAngle == muscleAngle).toList();
  }

  /// Get exercises by muscle group and angle
  static List<Exercise> getExercisesByGroupAndAngle(
    List<Exercise> exercises,
    String muscleGroup,
    String muscleAngle,
  ) {
    return exercises
        .where((e) => e.muscleGroup == muscleGroup && e.muscleAngle == muscleAngle)
        .toList();
  }

  /// Clear cache
  static void clearCache() {
    _cachedExercises = null;
  }
}

/// Muscle Group with display info and image
class MuscleGroup {
  final String id;
  final String nameEn;
  final String nameAr;
  final String imageUrl;
  final int exerciseCount;

  const MuscleGroup({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    this.exerciseCount = 0,
  });

  /// Get muscle groups with images
  static List<MuscleGroup> getDefaultGroups(List<Exercise> exercises) {
    // Using reliable placeholder images with different seeds for each group
    final groupData = {
      'Chest': {
        'nameAr': 'الصدر',
        'image': 'https://picsum.photos/seed/chest/400/300',
      },
      'Back': {
        'nameAr': 'الظهر',
        'image': 'https://picsum.photos/seed/back/400/300',
      },
      'Shoulders': {
        'nameAr': 'الأكتاف',
        'image': 'https://picsum.photos/seed/shoulders/400/300',
      },
      'Arms': {
        'nameAr': 'الذراعين',
        'image': 'https://picsum.photos/seed/arms/400/300',
      },
      'Core': {
        'nameAr': 'البطن',
        'image': 'https://picsum.photos/seed/core/400/300',
      },
      'Legs': {
        'nameAr': 'الرجلين',
        'image': 'https://picsum.photos/seed/legs/400/300',
      },
    };

    final groups = <MuscleGroup>[];
    for (final entry in groupData.entries) {
      final count = exercises.where((e) => e.muscleGroup == entry.key).length;
      if (count > 0 || entry.key == 'Legs') {
        groups.add(MuscleGroup(
          id: entry.key.toLowerCase(),
          nameEn: entry.key,
          nameAr: entry.value['nameAr']!,
          imageUrl: entry.value['image']!,
          exerciseCount: count,
        ));
      }
    }
    return groups;
  }
}

/// Muscle Angle with display info
class MuscleAngle {
  final String id;
  final String nameEn;
  final String nameAr;
  final String muscleGroup;
  final int exerciseCount;

  const MuscleAngle({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.muscleGroup,
    required this.exerciseCount,
  });

  /// Translate muscle angles to Arabic
  static String translateToArabic(String angle) {
    final translations = {
      'Middle Chest': 'الصدر الأوسط',
      'Upper Chest': 'الصدر العلوي',
      'Lower Chest': 'الصدر السفلي',
      'Lats': 'اللاتس',
      'Middle Back': 'وسط الظهر',
      'Front Deltoid': 'الكتف الأمامي',
      'Side Deltoid': 'الكتف الجانبي',
      'Rear Deltoid': 'الكتف الخلفي',
      'Long Head Bicep': 'البايسبس الطويل',
      'Brachialis': 'البايسبس القصير',
      'Long Head Triceps': ' الترايسبس الطويل',
      'Lateral Head Triceps': 'الترايسبس الجانبي',
      'Rectus Abdominis': 'العضلات المستقيمة',
    };
    return translations[angle] ?? angle;
  }

  /// Get muscle angles for a group
  static List<MuscleAngle> getAnglesForGroup(
    List<Exercise> exercises,
    String muscleGroup,
  ) {
    final angles = WorkoutDatabase.getMuscleAngles(exercises, muscleGroup);
    return angles.map((angle) {
      final count = exercises
          .where((e) => e.muscleGroup == muscleGroup && e.muscleAngle == angle)
          .length;
      return MuscleAngle(
        id: '${muscleGroup.toLowerCase()}_${angle.toLowerCase().replaceAll(' ', '_')}',
        nameEn: angle,
        nameAr: translateToArabic(angle),
        muscleGroup: muscleGroup,
        exerciseCount: count,
      );
    }).toList();
  }
}
