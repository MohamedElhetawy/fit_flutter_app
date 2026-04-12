import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../constants.dart';

import '../../../core/auth/auth_controller.dart';
import '../data/nutrition_models.dart';
import '../data/food_database.dart';
import '../providers/nutrition_provider.dart';
import '../providers/food_search_provider.dart';

/// Nutrition Logging Screen - Meal by meal tracking with macro goals
class NutritionLoggingScreen extends ConsumerStatefulWidget {
  const NutritionLoggingScreen({super.key});

  @override
  ConsumerState<NutritionLoggingScreen> createState() => _NutritionLoggingScreenState();
}

class _NutritionLoggingScreenState extends ConsumerState<NutritionLoggingScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid;
    if (uid == null) return const SizedBox.shrink();

    final goalsAsync = ref.watch(dailyMacroGoalsProvider(uid));
    final logsAsync = ref.watch(dailyNutritionLogsProvider((uid: uid, date: _selectedDate)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Log'),
        actions: [
          IconButton(
            onPressed: () => _showMacroGoalsDialog(context, ref, uid),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          _DateSelector(
            selectedDate: _selectedDate,
            onDateChanged: (date) => setState(() => _selectedDate = date),
          ),

          // Macro Progress Rings
          goalsAsync.when(
            data: (goals) => logsAsync.when(
              data: (logs) => _MacroProgressHeader(goals: goals, logs: logs),
              loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
            loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Hydration Tracker
          _HydrationTracker(),

          // Meal Sections
          Expanded(
            child: logsAsync.when(
              data: (logs) => _MealsList(
                logs: logs,
                selectedDate: _selectedDate,
                onAddMeal: (mealType) => _showAddMealDialog(context, ref, uid, mealType),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Food Recognition - Coming Soon
          FloatingActionButton.small(
            onPressed: () => _showComingSoonDialog(context, 'AI Food Recognition'),
            backgroundColor: surfaceColorLight,
            heroTag: 'ai_food',
            child: Stack(
              children: [
                const Icon(Icons.camera_alt, color: textSecondary),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'قريباً',
                      style: TextStyle(
                        color: Color(0xFF1A1A00),
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Main Add Food Button
          FloatingActionButton.extended(
            onPressed: () => _showAddMealDialog(context, ref, uid, null),
            icon: const Icon(Icons.add),
            label: const Text('Log Food'),
            heroTag: 'add_food',
          ),
        ],
      ),
    );
  }

  void _showMacroGoalsDialog(BuildContext context, WidgetRef ref, String uid) {
    final goals = ref.read(dailyMacroGoalsProvider(uid)).valueOrNull ?? const MacroGoal(calories: 2200, protein: 140, carbs: 230, fat: 70);
    
    final calCtrl = TextEditingController(text: goals.calories.toString());
    final proteinCtrl = TextEditingController(text: goals.protein.toString());
    final carbsCtrl = TextEditingController(text: goals.carbs.toString());
    final fatCtrl = TextEditingController(text: goals.fat.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Macro Goals'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: calCtrl,
                decoration: const InputDecoration(labelText: 'Calories', suffixText: 'kcal'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: proteinCtrl,
                decoration: const InputDecoration(labelText: 'Protein', suffixText: 'g'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carbsCtrl,
                decoration: const InputDecoration(labelText: 'Carbs', suffixText: 'g'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fatCtrl,
                decoration: const InputDecoration(labelText: 'Fat', suffixText: 'g'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final calories = int.tryParse(calCtrl.text);
                final protein = int.tryParse(proteinCtrl.text);
                final carbs = int.tryParse(carbsCtrl.text);
                final fat = int.tryParse(fatCtrl.text);
                
                if (calories == null || protein == null || carbs == null || fat == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid numbers for all fields')),
                    );
                  }
                  return;
                }
                
                if (calories <= 0 || protein < 0 || carbs < 0 || fat < 0) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Values must be positive numbers')),
                    );
                  }
                  return;
                }
                
                final newGoals = MacroGoal(
                  calories: calories,
                  protein: protein,
                  carbs: carbs,
                  fat: fat,
                );
                await ref.read(nutritionRepositoryProvider).updateMacroGoals(uid, newGoals);
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goals updated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating goals: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.construction, color: primaryColor),
            SizedBox(width: 8),
            Text('قريباً'),
          ],
        ),
        content: Text(
          'ميزة $feature قيد التطوير حالياً و ستكون متاحة في التحديث القادم',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, WidgetRef ref, String uid, String? initialMealType) {
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-workout', 'Post-workout'];
    String selectedMealType = initialMealType ?? 'Snack';
    
    final searchCtrl = TextEditingController();
    final quantityCtrl = TextEditingController(text: '100');
    FoodItem? selectedFood;
    List<FoodItem> searchResults = [];
    bool isSearching = false;
    
    // Debounce timer for search
    Timer? searchTimer;

    // Load food database
    ref.read(allFoodsProvider.future).then((foods) {
      // Pre-load complete
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: surfaceColor,
          title: Row(
            children: [
              const Expanded(child: Text('إضافة طعام')),
              // AI Recognition Button
              GestureDetector(
                onTap: () => _showComingSoonDialog(context, 'التعرف بالكاميرا'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(radiusSm),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt, color: primaryColor, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'AI',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'قريباً',
                          style: TextStyle(
                            color: Color(0xFF1A1A00),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedMealType,
                  decoration: InputDecoration(
                    labelText: 'نوع الوجبة',
                    labelStyle: const TextStyle(color: textSecondary),
                    filled: true,
                    fillColor: surfaceColorLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radiusSm),
                      borderSide: const BorderSide(color: surfaceBorder),
                    ),
                  ),
                  dropdownColor: surfaceColorLight,
                  items: mealTypes.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, style: const TextStyle(color: textPrimary)),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedMealType = v!),
                ),
                const SizedBox(height: 16),

                // Food Search with Dropdown
                TextField(
                  controller: searchCtrl,
                  style: const TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: 'ابحث عن طعام (اكتب أول حرفين على الأقل)',
                    labelStyle: const TextStyle(color: textSecondary),
                    hintText: 'مثال: دجاج، موز، أرز...',
                    hintStyle: const TextStyle(color: textTertiary),
                    filled: true,
                    fillColor: surfaceColorLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radiusSm),
                      borderSide: const BorderSide(color: surfaceBorder),
                    ),
                    prefixIcon: const Icon(Icons.search, color: textSecondary),
                    suffixIcon: searchCtrl.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchCtrl.clear();
                              searchTimer?.cancel();
                              setState(() {
                                searchResults = [];
                                selectedFood = null;
                              });
                            },
                            icon: const Icon(Icons.clear, color: textSecondary),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    // Cancel previous timer
                    searchTimer?.cancel();
                    
                    if (value.length < 2) {
                      setState(() {
                        searchResults = [];
                        isSearching = false;
                      });
                      return;
                    }
                    
                    setState(() => isSearching = true);
                    
                    // Start new timer for debounce
                    searchTimer = Timer(const Duration(milliseconds: 300), () async {
                      final allFoods = await ref.read(allFoodsProvider.future);
                      if (context.mounted) {
                        setState(() {
                          searchResults = FoodDatabase.getSuggestions(allFoods, value, limit: 10);
                          isSearching = false;
                        });
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Search Results Dropdown
                if (isSearching)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (searchResults.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: surfaceColorLight,
                      borderRadius: BorderRadius.circular(radiusSm),
                      border: Border.all(color: surfaceBorder),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final food = searchResults[index];
                        final isSelected = selectedFood?.id == food.id;
                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          selectedTileColor: primaryColor.withValues(alpha: 0.1),
                          title: Text(
                            food.displayName,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${food.calories.toInt()} سعرة | ب:${food.protein.toInt()} ك:${food.carbs.toInt()} د:${food.fat.toInt()}',
                            style: const TextStyle(color: textSecondary, fontSize: 12),
                          ),
                          trailing: Text(
                            food.unit,
                            style: const TextStyle(color: textTertiary, fontSize: 11),
                          ),
                          onTap: () => setState(() {
                            selectedFood = food;
                            searchResults = []; // Hide dropdown after selection
                          }),
                        );
                      },
                    ),
                  )
                else if (searchCtrl.text.length >= 2 && !isSearching)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceColorLight,
                      borderRadius: BorderRadius.circular(radiusSm),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_off, color: textTertiary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'لا توجد نتائج',
                          style: TextStyle(color: textSecondary),
                        ),
                      ],
                    ),
                  ),

                // Selected Food Display
                if (selectedFood != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(radiusMd),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedFood!.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'لكل 100${selectedFood!.unit}: ${selectedFood!.calories.toInt()} سعرة | بروتين: ${selectedFood!.protein.toInt()}g | كارب: ${selectedFood!.carbs.toInt()}g | دهون: ${selectedFood!.fat.toInt()}g',
                          style: const TextStyle(color: textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'الكمية: ',
                              style: TextStyle(color: textPrimary),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: quantityCtrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: textPrimary),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: surfaceColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(radiusSm),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                  suffixText: 'g',
                                  suffixStyle: const TextStyle(color: textSecondary, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                searchTimer?.cancel();
                context.pop();
              },
              child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
            ),
            ElevatedButton(
              onPressed: selectedFood == null
                  ? null
                  : () async {
                      try {
                        searchTimer?.cancel();
                        final qty = double.tryParse(quantityCtrl.text);
                        if (qty == null || qty <= 0) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يرجى إدخال كمية صحيحة')),
                            );
                          }
                          return;
                        }
                        
                        final macros = selectedFood!.calculateMacros(qty);
                        
                        final log = NutritionLog(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: '$selectedMealType - ${selectedFood!.displayName}',
                          calories: macros['calories']!.toInt(),
                          protein: macros['protein']!.toInt(),
                          carbs: macros['carbs']!.toInt(),
                          fat: macros['fat']!.toInt(),
                          loggedAt: DateTime.now(),
                        );

                        await ref.read(nutritionRepositoryProvider).logFood(
                          uid: uid,
                          log: log,
                          mealType: selectedMealType,
                        );

                        if (context.mounted) {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إضافة ${selectedFood!.displayName} بنجاح'),
                              backgroundColor: primaryColor,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('خطأ: $e')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: const Color(0xFF1A1A00),
              ),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date Selector Widget
class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = selectedDate.day == DateTime.now().day &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.year == DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => onDateChanged(selectedDate.subtract(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (date != null) onDateChanged(date);
              },
              child: Column(
                children: [
                  Text(
                    isToday ? 'Today' : _formatDate(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))
                ? null
                : () => onDateChanged(selectedDate.add(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

/// Macro Progress Header with Rings
class _MacroProgressHeader extends StatelessWidget {
  final MacroGoal goals;
  final List<NutritionLog> logs;

  const _MacroProgressHeader({
    required this.goals,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = logs.fold<int>(0, (sum, log) => sum + log.calories);
    final totalProtein = logs.fold<int>(0, (sum, log) => sum + log.protein.toInt());
    final totalCarbs = logs.fold<int>(0, (sum, log) => sum + log.carbs.toInt());
    final totalFat = logs.fold<int>(0, (sum, log) => sum + log.fat.toInt());

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MacroRing(
            label: 'Calories',
            current: totalCalories,
            goal: goals.calories,
            color: Theme.of(context).colorScheme.primary,
          ),
          _MacroRing(
            label: 'Protein',
            current: totalProtein,
            goal: goals.protein,
            color: Theme.of(context).colorScheme.secondary,
          ),
          _MacroRing(
            label: 'Carbs',
            current: totalCarbs,
            goal: goals.carbs,
            color: Colors.green,
          ),
          _MacroRing(
            label: 'Fat',
            current: totalFat,
            goal: goals.fat,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final Color color;

  const _MacroRing({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress.toDouble(),
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '$current',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '/$goal',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

/// Meals List organized by meal type
class _MealsList extends StatelessWidget {
  final List<NutritionLog> logs;
  final DateTime selectedDate;
  final ValueChanged<String> onAddMeal;

  const _MealsList({
    required this.logs,
    required this.selectedDate,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    final mealOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-workout', 'Post-workout'];
    
    // Group logs by meal type - temporarily filter by name until mealType field is added
    final grouped = <String, List<NutritionLog>>{};
    for (final mealType in mealOrder) {
      grouped[mealType] = logs.where((log) {
        // Extract meal type from log name or use a different approach
        // This is a temporary solution - ideally NutritionLog should have a mealType field
        final logName = log.name.toLowerCase();
        switch (mealType.toLowerCase()) {
          case 'breakfast':
            return logName.contains('breakfast') || logName.contains('صباح');
          case 'lunch':
            return logName.contains('lunch') || logName.contains('غداء');
          case 'dinner':
            return logName.contains('dinner') || logName.contains('عشاء');
          case 'snack':
            return logName.contains('snack') || logName.contains('وجبة خفيفة');
          case 'pre-workout':
            return logName.contains('pre-workout') || logName.contains('قبل التمرين');
          case 'post-workout':
            return logName.contains('post-workout') || logName.contains('بعد التمرين');
          default:
            return false;
        }
      }).toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(defaultPadding),
      itemCount: mealOrder.length,
      itemBuilder: (context, index) {
        final mealType = mealOrder[index];
        final mealLogs = grouped[mealType] ?? [];
        
        return _MealSection(
          mealType: mealType,
          logs: mealLogs,
          onAdd: () => onAddMeal(mealType),
        );
      },
    );
  }
}

class _MealSection extends StatelessWidget {
  final String mealType;
  final List<NutritionLog> logs;
  final VoidCallback onAdd;

  const _MealSection({
    required this.mealType,
    required this.logs,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = logs.fold<int>(0, (sum, log) => sum + log.calories);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (logs.isNotEmpty)
                        Text(
                          '$totalCalories kcal',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (logs.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              ...logs.map((log) => _MealItem(log: log)),
            ],
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'No food logged yet',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MealItem extends StatelessWidget {
  final NutritionLog log;

  const _MealItem({required this.log});

  @override
  Widget build(BuildContext context) {
    // Extract food name from the log name (remove meal type prefix)
    final displayName = log.name.contains(' - ') 
        ? log.name.split(' - ').skip(1).join(' - ')
        : log.name;
    
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(displayName),
      subtitle: Text('P:${log.protein.toInt()}g C:${log.carbs.toInt()}g F:${log.fat.toInt()}g'),
      trailing: Text(
        '${log.calories} kcal',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Hydration Tracker with +/- buttons
class _HydrationTracker extends StatefulWidget {
  @override
  State<_HydrationTracker> createState() => _HydrationTrackerState();
}

class _HydrationTrackerState extends State<_HydrationTracker> {
  int _waterIntake = 0; // in ml
  final int _goal = 2500; // 2.5 liters

  void _addWater(int amount) {
    setState(() {
      _waterIntake = (_waterIntake + amount).clamp(0, 5000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_waterIntake / _goal).clamp(0.0, 1.0);
    final glasses = (_waterIntake / 250).floor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: spaceSm),
      padding: const EdgeInsets.all(spaceMd),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hydration',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_waterIntake}ml / ${_goal}ml • $glasses glasses',
                      style: const TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Progress indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: surfaceColorLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),
          // Quick add buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWaterButton(250, 'Small'),
              _buildWaterButton(500, 'Medium'),
              _buildWaterButton(750, 'Large'),
            ],
          ),
          const SizedBox(height: spaceSm),
          // +/- buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _addWater(-250),
                icon: const Icon(Icons.remove_circle_outline, color: errorColor),
                iconSize: 32,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: spaceMd),
                child: Text(
                  '+250ml',
                  style: TextStyle(
                    color: Colors.blue.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _addWater(250),
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(int amount, String label) {
    final isSelected = _waterIntake >= amount;
    return GestureDetector(
      onTap: () => _addWater(amount - (_waterIntake % amount)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.2) : surfaceColorLight,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(
            color: isSelected ? Colors.blue : surfaceBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.water_drop,
              color: isSelected ? Colors.blue : textTertiary,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
