import 'dart:convert';
import 'package:flutter/services.dart';

/// Food item from local database
class FoodItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String unit;

  const FoodItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.unit,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  /// Searchable text combines both Arabic and English names
  String get searchableText => '$nameAr $nameEn'.toLowerCase();

  /// Display name based on preference (default to Arabic)
  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;

  /// Calculate macros for a given quantity
  Map<String, double> calculateMacros(double quantity) {
    final multiplier = quantity / 100; // Database values are per 100g/ml
    return {
      'calories': calories * multiplier,
      'protein': protein * multiplier,
      'carbs': carbs * multiplier,
      'fat': fat * multiplier,
    };
  }
}

/// Local food database service
class FoodDatabase {
  static List<FoodItem>? _cachedItems;

  /// Load all food items from JSON
  static Future<List<FoodItem>> loadFoods() async {
    if (_cachedItems != null) return _cachedItems!;

    final jsonString =
        await rootBundle.loadString('assets/data/food_database.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    _cachedItems = jsonList
        .map((json) => FoodItem.fromJson(json as Map<String, dynamic>))
        .toList();

    return _cachedItems!;
  }

  /// Search foods by query (matches from first 2+ characters)
  static List<FoodItem> search(List<FoodItem> foods, String query) {
    if (query.length < 2) return [];

    final lowerQuery = query.toLowerCase().trim();

    return foods.where((food) {
      final searchText = food.searchableText;
      // Match if query appears anywhere in name
      return searchText.contains(lowerQuery);
    }).toList();
  }

  /// Get quick suggestions (first 10 items matching first 2 letters)
  static List<FoodItem> getSuggestions(List<FoodItem> foods, String query,
      {int limit = 10}) {
    final results = search(foods, query);
    return results.take(limit).toList();
  }

  /// Get food by ID
  static FoodItem? getById(List<FoodItem> foods, String id) {
    try {
      return foods.firstWhere((food) => food.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear cache (useful for testing)
  static void clearCache() {
    _cachedItems = null;
  }
}
