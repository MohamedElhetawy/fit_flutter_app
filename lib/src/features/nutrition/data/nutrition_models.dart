class MacroGoal {
  const MacroGoal({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  factory MacroGoal.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const MacroGoal(calories: 2200, protein: 140, carbs: 230, fat: 70);
    }
    return MacroGoal(
      calories: (map['calories'] as num?)?.toInt() ?? 2200,
      protein: (map['protein'] as num?)?.toInt() ?? 140,
      carbs: (map['carbs'] as num?)?.toInt() ?? 230,
      fat: (map['fat'] as num?)?.toInt() ?? 70,
    );
  }

  Map<String, dynamic> toMap() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}

class NutritionLog {
  NutritionLog({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
  });

  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime loggedAt;

  factory NutritionLog.fromMap(String id, Map<String, dynamic> map) {
    final atRaw = map['loggedAt'];
    final parsedAt = DateTime.tryParse(atRaw?.toString() ?? '');
    return NutritionLog(
      id: id,
      name: (map['name'] ?? 'Meal').toString(),
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toInt() ?? 0,
      carbs: (map['carbs'] as num?)?.toInt() ?? 0,
      fat: (map['fat'] as num?)?.toInt() ?? 0,
      loggedAt: parsedAt ?? DateTime.now(),
    );
  }
}
