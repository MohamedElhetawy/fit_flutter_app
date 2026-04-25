import 'package:flutter/material.dart';

class AppConfig {
  const AppConfig({
    required this.primaryColorValue,
    required this.enableSteps,
    required this.enableWorkoutRecommendations,
    required this.typographyScale,
    required this.spacingScale,
    required this.cardRadius,
    required this.showNutritionSection,
  });

  final int primaryColorValue;
  final bool enableSteps;
  final bool enableWorkoutRecommendations;
  final double typographyScale;
  final double spacingScale;
  final double cardRadius;
  final bool showNutritionSection;

  Color get primaryColor => Color(primaryColorValue);

  factory AppConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AppConfig.defaults();
    return AppConfig(
      primaryColorValue:
          (map['primaryColorValue'] as num?)?.toInt() ?? 0xFF7B61FF,
      enableSteps: (map['enableSteps'] as bool?) ?? true,
      enableWorkoutRecommendations:
          (map['enableWorkoutRecommendations'] as bool?) ?? true,
      typographyScale: (map['typographyScale'] as num?)?.toDouble() ?? 1.0,
      spacingScale: (map['spacingScale'] as num?)?.toDouble() ?? 1.0,
      cardRadius: (map['cardRadius'] as num?)?.toDouble() ?? 12.0,
      showNutritionSection: (map['showNutritionSection'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'primaryColorValue': primaryColorValue,
        'enableSteps': enableSteps,
        'enableWorkoutRecommendations': enableWorkoutRecommendations,
        'typographyScale': typographyScale,
        'spacingScale': spacingScale,
        'cardRadius': cardRadius,
        'showNutritionSection': showNutritionSection,
      };

  const AppConfig.defaults()
      : primaryColorValue = 0xFF7B61FF,
        enableSteps = true,
        enableWorkoutRecommendations = true,
        typographyScale = 1.0,
        spacingScale = 1.0,
        cardRadius = 12.0,
        showNutritionSection = true;
}
