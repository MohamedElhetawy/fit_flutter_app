import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';

import '../../../core/providers/firebase_providers.dart';

/// Nutrition Catalog Manager for Trainers
/// Allows adding new food items to the shared nutrition catalog
/// with Egyptian food database structure
class NutritionCatalogManager extends ConsumerStatefulWidget {
  const NutritionCatalogManager({super.key});

  @override
  ConsumerState<NutritionCatalogManager> createState() => _NutritionCatalogManagerState();
}

class _NutritionCatalogManagerState extends ConsumerState<NutritionCatalogManager> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'egyptian_traditional',
    'proteins',
    'grains',
    'vegetables',
    'fruits',
    'dairy',
    'beverages',
    'snacks',
    'supplements',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogStream = ref.watch(_catalogSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Catalog'),
        actions: [
          IconButton(
            onPressed: () => _showAddFoodDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search food items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_categoryDisplayName(cat)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Catalog List
          Expanded(
            child: catalogStream.when(
              data: (items) {
                // Filter by category
                var filtered = items;
                if (_selectedCategory != 'all') {
                  filtered = items.where((i) => i['category'] == _selectedCategory).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No food items found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddFoodDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Food Item'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _FoodItemCard(item: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryDisplayName(String cat) {
    final names = {
      'all': 'All',
      'egyptian_traditional': '🇪🇬 Egyptian',
      'proteins': '🥩 Proteins',
      'grains': '🌾 Grains',
      'vegetables': '🥬 Vegetables',
      'fruits': '🍎 Fruits',
      'dairy': '🥛 Dairy',
      'beverages': '🥤 Drinks',
      'snacks': '🍿 Snacks',
      'supplements': '💊 Supplements',
    };
    return names[cat] ?? cat;
  }

  void _showAddFoodDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proteinCtrl = TextEditingController(text: '0');
    final carbsCtrl = TextEditingController(text: '0');
    final fatCtrl = TextEditingController(text: '0');
    final servingCtrl = TextEditingController(text: '100');
    final servingUnitCtrl = TextEditingController(text: 'g');
    
    String category = 'proteins';
    bool isEgyptian = false;

    final categories = [
      'egyptian_traditional',
      'proteins',
      'grains',
      'vegetables',
      'fruits',
      'dairy',
      'beverages',
      'snacks',
      'supplements',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Food Item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Food Name *',
                      hintText: 'e.g., Koshari, Grilled Chicken',
                    ),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category *'),
                    items: categories.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(_categoryDisplayName(c)),
                    )).toList(),
                    onChanged: (v) => setDialogState(() {
                      category = v!;
                      isEgyptian = category == 'egyptian_traditional';
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Egyptian flag toggle
                  SwitchListTile(
                    title: const Text('Egyptian Traditional Food'),
                    subtitle: const Text('Mark if this is authentic Egyptian cuisine'),
                    value: isEgyptian,
                    onChanged: (v) => setDialogState(() => isEgyptian = v),
                  ),
                  const SizedBox(height: 12),

                  // Macros Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: calCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Calories *',
                            suffixText: 'kcal',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: proteinCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Protein',
                            suffixText: 'g',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: carbsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Carbs',
                            suffixText: 'g',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: fatCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Fat',
                            suffixText: 'g',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Serving Size
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: servingCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Serving Size',
                            suffixText: 'g',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: servingUnitCtrl,
                          decoration: const InputDecoration(labelText: 'Unit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() != true) return;

                final firestore = ref.read(firestoreProvider);
                await firestore.collection('nutrition_catalog').add({
                  'name': nameCtrl.text.trim(),
                  'category': isEgyptian ? 'egyptian_traditional' : category,
                  'isEgyptianTraditional': isEgyptian,
                  'calories': int.tryParse(calCtrl.text) ?? 0,
                  'protein': double.tryParse(proteinCtrl.text) ?? 0,
                  'carbs': double.tryParse(carbsCtrl.text) ?? 0,
                  'fat': double.tryParse(fatCtrl.text) ?? 0,
                  'servingSize': int.tryParse(servingCtrl.text) ?? 100,
                  'servingUnit': servingUnitCtrl.text.trim(),
                  'createdAt': DateTime.now().toIso8601String(),
                  'searchableName': nameCtrl.text.trim().toLowerCase(),
                });

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add to Catalog'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider for catalog search
final _catalogSearchProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, query) {
  final firestore = ref.watch(firestoreProvider);
  
  if (query.isEmpty) {
    return firestore
        .collection('nutrition_catalog')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
  
  return firestore
      .collection('nutrition_catalog')
      .where('searchableName', isGreaterThanOrEqualTo: query)
      .where('searchableName', isLessThan: '${query}z')
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

/// Food Item Card
class _FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _FoodItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isEgyptian = item['isEgyptianTraditional'] == true;
    final calories = item['calories'] ?? 0;
    final protein = item['protein'] ?? 0;
    final carbs = item['carbs'] ?? 0;
    final fat = item['fat'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isEgyptian ? Colors.red[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              isEgyptian ? '🇪🇬' : '🍽️',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item['name'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (isEgyptian)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Egyptian',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$calories kcal per ${item['servingSize'] ?? 100}${item['servingUnit'] ?? 'g'}'),
            const SizedBox(height: 4),
            Row(
              children: [
                _MacroBadge(label: 'P', value: protein, color: Colors.blue),
                const SizedBox(width: 4),
                _MacroBadge(label: 'C', value: carbs, color: Colors.orange),
                const SizedBox(width: 4),
                _MacroBadge(label: 'F', value: fat, color: Colors.red),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final num value;
  final Color color;

  const _MacroBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label${value.toStringAsFixed(0)}g',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
