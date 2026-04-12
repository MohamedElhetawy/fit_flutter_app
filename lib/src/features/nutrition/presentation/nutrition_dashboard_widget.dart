import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';

import '../providers/nutrition_provider.dart';

class NutritionDashboardWidget extends ConsumerWidget {
  const NutritionDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    if (uid == null) {
      return const SizedBox.shrink();
    }

    final goal = ref.watch(macroGoalProvider(uid));
    final logs = ref.watch(nutritionLogsProvider(uid));

    return Card(
      margin: const EdgeInsets.all(defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nutrition Tracking',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            goal.when(
              data: (g) => Text(
                'Goal: ${g.calories} kcal | P ${g.protein} | C ${g.carbs} | F ${g.fat}',
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Unable to load goals'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: logs.when(
                data: (items) {
                  final points = items.take(7).toList().reversed.toList();
                  if (points.isEmpty) {
                    return const Center(child: Text('No nutrition logs yet'));
                  }
                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < points.length; i++)
                              FlSpot(i.toDouble(), points[i].calories.toDouble()),
                          ],
                          isCurved: true,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        )
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
