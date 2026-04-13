import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../constants.dart';
import '../../../shared/widgets/fitx_card.dart';

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
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(defaultPadding, spaceMd, defaultPadding, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التغذية',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: spaceSm),
                        const Text(
                          'تتبع وجباتك ووحداتك الغذائية',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _CircleActionBtn(
                      icon: Icons.tune,
                      filled: true,
                      onTap: () => _showMacroGoalsDialog(context, ref, uid),
                    ),
                  ],
                ),
              ),
            ),

            // Date Selector
            SliverToBoxAdapter(
              child: _DateSelector(
                selectedDate: _selectedDate,
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),

            // Macro Progress Rings
            SliverToBoxAdapter(
              child: goalsAsync.when(
                data: (goals) => logsAsync.when(
                  data: (logs) => _MacroProgressHeader(goals: goals, logs: logs),
                  loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: primaryColor))),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: primaryColor))),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Hydration Tracker
            SliverToBoxAdapter(child: _HydrationTracker()),

            // Add Food Button
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: spaceMd),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddMealDialog(context, ref, uid, null),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('إضافة وجبة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: const Color(0xFF1A1A00),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radiusMd),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: spaceSm),
                    _CircleActionBtn(
                      icon: Icons.camera_alt,
                      onTap: () => _showComingSoonDialog(context, 'التعرف بالكاميرا'),
                    ),
                  ],
                ),
              ),
            ),

            // Meal Sections
            logsAsync.when(
              data: (logs) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                sliver: _MealsSliver(
                  logs: logs,
                  selectedDate: _selectedDate,
                  onAddMeal: (mealType) => _showAddMealDialog(context, ref, uid, mealType),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: primaryColor)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('خطأ: $e', style: const TextStyle(color: textPrimary))),
              ),
            ),

            const SliverPadding(
              padding: EdgeInsets.only(bottom: 100),
            ),
          ],
        ),
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
        backgroundColor: surfaceColor,
        title: const Text('الأهداف اليومية'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: calCtrl,
                decoration: const InputDecoration(labelText: 'السعرات', suffixText: 'kcal'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: proteinCtrl,
                decoration: const InputDecoration(labelText: 'البروتين', suffixText: 'g'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carbsCtrl,
                decoration: const InputDecoration(labelText: 'الكارب', suffixText: 'g'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fatCtrl,
                decoration: const InputDecoration(labelText: 'الدهون', suffixText: 'g'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('إلغاء')),
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
                      const SnackBar(content: Text('يرجى إدخال أرقام صحيحة')),
                    );
                  }
                  return;
                }
                
                if (calories <= 0 || protein < 0 || carbs < 0 || fat < 0) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('القيم لازم تكون أرقام موجبة')),
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
                    const SnackBar(content: Text('تم تحديث الأهداف بنجاح'), backgroundColor: primaryColor),
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
            child: const Text('حفظ'),
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
          'ميزة "$feature" قيد التطوير وستكون متاحة قريباً',
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
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(radiusSm),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
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
                  value: selectedMealType,
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
                          selectedTileColor: primaryColor.withOpacity(0.1),
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
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(radiusMd),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
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
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: spaceMd),
      child: Row(
        children: [
          _CircleActionBtn(
            icon: Icons.chevron_left_rounded,
            onTap: () => onDateChanged(selectedDate.subtract(const Duration(days: 1))),
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
                    isToday ? 'اليوم' : _formatDate(selectedDate),
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CircleActionBtn(
            icon: Icons.chevron_right_rounded,
            onTap: selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))
                ? null
                : () => onDateChanged(selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
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
            label: 'سعرات',
            current: totalCalories,
            goal: goals.calories,
            color: primaryColor,
          ),
          _MacroRing(
            label: 'بروتين',
            current: totalProtein,
            goal: goals.protein,
            color: Colors.blue,
          ),
          _MacroRing(
            label: 'كارب',
            current: totalCarbs,
            goal: goals.carbs,
            color: Colors.orange,
          ),
          _MacroRing(
            label: 'دهون',
            current: totalFat,
            goal: goals.fat,
            color: Colors.redAccent,
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
                backgroundColor: surfaceBorder,
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
                      style: const TextStyle(
                        fontSize: 10,
                        color: textSecondary,
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
          style: const TextStyle(
            fontSize: 12,
            color: textSecondary,
          ),
        ),
        Text(
          '/$goal',
          style: const TextStyle(
            fontSize: 10,
            color: textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Meals Sliver organized by meal type
class _MealsSliver extends StatelessWidget {
  final List<NutritionLog> logs;
  final DateTime selectedDate;
  final ValueChanged<String> onAddMeal;

  const _MealsSliver({
    required this.logs,
    required this.selectedDate,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    final mealOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-workout', 'Post-workout'];
    
    final grouped = <String, List<NutritionLog>>{};
    for (final mealType in mealOrder) {
      grouped[mealType] = logs.where((log) {
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

    return SliverList(
      delegate: SliverChildListDelegate([
        for (int i = 0; i < mealOrder.length; i++) ...[
          _MealSection(
            mealType: mealOrder[i],
            logs: grouped[mealOrder[i]] ?? [],
            onAdd: () => onAddMeal(mealOrder[i]),
          ),
          if (i < mealOrder.length - 1) const SizedBox(height: spaceMd),
        ],
      ]),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String mealType;
  final List<NutritionLog> logs;
  final VoidCallback onAdd;

  static const _mealLabels = {
    'Breakfast': 'إفطار',
    'Lunch': 'غداء',
    'Dinner': 'عشاء',
    'Snack': 'وجبة خفيفة',
    'Pre-workout': 'قبل التمرين',
    'Post-workout': 'بعد التمرين',
  };

  static const _mealIcons = {
    'Breakfast': Icons.wb_sunny_rounded,
    'Lunch': Icons.lunch_dining_rounded,
    'Dinner': Icons.dinner_dining_rounded,
    'Snack': Icons.cookie_rounded,
    'Pre-workout': Icons.fitness_center_rounded,
    'Post-workout': Icons.local_drink_rounded,
  };

  const _MealSection({
    required this.mealType,
    required this.logs,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = logs.fold<int>(0, (sum, log) => sum + log.calories);
    final label = _mealLabels[mealType] ?? mealType;
    final icon = _mealIcons[mealType] ?? Icons.restaurant_rounded;

    return FitXCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(radiusSm),
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
              const SizedBox(width: spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textPrimary,
                      ),
                    ),
                    if (logs.isNotEmpty)
                      Text(
                        '$totalCalories سعرة',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(radiusXs),
                  ),
                  child: const Icon(Icons.add_rounded, color: primaryColor, size: 18),
                ),
              ),
            ],
          ),
          if (logs.isNotEmpty) ...[
            const SizedBox(height: spaceMd),
            Divider(color: surfaceBorder, thickness: 0.5),
            const SizedBox(height: spaceSm),
            ...logs.map((log) => _MealItem(log: log)),
          ],
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: spaceMd),
              child: Text(
                'لم يتم تسجيل طعام بعد',
                style: TextStyle(
                  color: textTertiary,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealItem extends StatelessWidget {
  final NutritionLog log;

  const _MealItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final displayName = log.name.contains(' - ')
        ? log.name.split(' - ').skip(1).join(' - ')
        : log.name;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: spaceSm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ب:${log.protein.toInt()}g ك:${log.carbs.toInt()}g د:${log.fat.toInt()}g',
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${log.calories} سعرة',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontSize: 13,
            ),
          ),
        ],
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
                  color: Colors.blue.withOpacity(0.2),
                ),
                child: const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الماء',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_waterIntake}مل / ${_goal}مل • $glasses كوب',
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
              _buildWaterButton(250, 'صغير'),
              _buildWaterButton(500, 'وسط'),
              _buildWaterButton(750, 'كبير'),
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
                    color: Colors.blue.withOpacity(0.8),
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
          color: isSelected ? Colors.blue.withOpacity(0.2) : surfaceColorLight,
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

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;
  const _CircleActionBtn({required this.icon, this.filled = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: filled ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(radiusSm),
          border: filled ? null : Border.all(color: surfaceBorder),
        ),
        child: Icon(icon, color: filled ? const Color(0xFF1A1A00) : textSecondary, size: 20),
      ),
    );
  }
}
