import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/food_database.dart';

/// Provider for all food items (loaded once)
final allFoodsProvider = FutureProvider<List<FoodItem>>((ref) async {
  return await FoodDatabase.loadFoods();
});

/// Search query state (for debounced input)
final foodSearchQueryProvider = StateProvider<String>((ref) => '');

/// Debounced search provider - waits 300ms after typing stops
final debouncedFoodSearchProvider = StreamProvider<List<FoodItem>>((ref) async* {
  final query = ref.watch(foodSearchQueryProvider);
  
  // Wait 300ms for debounce
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Check if query still matches (user might have typed more)
  final currentQuery = ref.read(foodSearchQueryProvider);
  if (query != currentQuery) return;
  
  // Need at least 2 characters to search
  if (query.length < 2) {
    yield [];
    return;
  }
  
  final allFoods = await ref.watch(allFoodsProvider.future);
  final results = FoodDatabase.getSuggestions(allFoods, query, limit: 15);
  yield results;
});

/// Provider for selected food item
final selectedFoodProvider = StateProvider<FoodItem?>((ref) => null);

/// Provider for quantity input
final foodQuantityProvider = StateProvider<double>((ref) => 1.0);

/// Notifier for managing food search with debounce
class FoodSearchNotifier extends StateNotifier<AsyncValue<List<FoodItem>>> {
  FoodSearchNotifier() : super(const AsyncValue.data([]));
  
  Timer? _debounceTimer;
  List<FoodItem> _allFoods = [];
  bool _isLoaded = false;

  /// Initialize with food data
  Future<void> initialize() async {
    if (_isLoaded) return;
    _allFoods = await FoodDatabase.loadFoods();
    _isLoaded = true;
  }

  /// Search with debounce (300ms)
  void search(String query) {
    _debounceTimer?.cancel();
    
    if (query.length < 2) {
      state = const AsyncValue.data([]);
      return;
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isLoaded) return;
      
      final results = FoodDatabase.getSuggestions(_allFoods, query, limit: 15);
      state = AsyncValue.data(results);
    });
  }

  /// Immediate search (no debounce) for quick suggestions
  List<FoodItem> searchImmediate(String query, {int limit = 10}) {
    if (query.length < 2 || !_isLoaded) return [];
    return FoodDatabase.getSuggestions(_allFoods, query, limit: limit);
  }

  /// Get food by ID
  FoodItem? getById(String id) {
    if (!_isLoaded) return null;
    return FoodDatabase.getById(_allFoods, id);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for food search notifier
final foodSearchNotifierProvider = StateNotifierProvider<FoodSearchNotifier, AsyncValue<List<FoodItem>>>((ref) {
  final notifier = FoodSearchNotifier();
  notifier.initialize();
  return notifier;
});
