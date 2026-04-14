import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';

import '../data/task_models.dart';
import '../providers/task_providers.dart';
import 'task_detail_screen.dart';

/// Tasks Screen - dedicated screen with Workout and Nutrition sections
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(userTasksProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مهامي',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spaceSm),
                    Text(
                      'تمارين ومهام تغذية من مدربك',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Task Sections
            tasksAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'خطأ: $e',
                    style: const TextStyle(color: textPrimary),
                  ),
                ),
              ),
              data: (tasks) {
                final workoutTasks = tasks
                    .where((t) => t.type == TaskType.workout)
                    .toList();
                final nutritionTasks = tasks
                    .where((t) => t.type == TaskType.nutrition)
                    .toList();

                return SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Workout Tasks Section
                      _buildSectionHeader(
                        icon: Icons.fitness_center,
                        title: 'مهام التمرين',
                        color: primaryColor,
                      ),
                      const SizedBox(height: spaceMd),
                      if (workoutTasks.isEmpty)
                        _buildEmptySection('لا توجد مهام تمرين')
                      else
                        ...workoutTasks.map((task) => _TaskCard(task: task)),

                      const SizedBox(height: spaceLg),

                      // Nutrition Tasks Section
                      _buildSectionHeader(
                        icon: Icons.restaurant,
                        title: 'مهام التغذية',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: spaceMd),
                      if (nutritionTasks.isEmpty)
                        _buildEmptySection('لا توجد مهام تغذية')
                      else
                        ...nutritionTasks.map((task) => _TaskCard(task: task)),

                      const SizedBox(height: spaceLg),
                      const SizedBox(height: 100), // Bottom nav padding
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: spaceSm),
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      padding: const EdgeInsets.all(spaceLg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: surfaceBorder),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FitXCard(
      margin: const EdgeInsets.only(bottom: spaceMd),
      onTap: () => _navigateToDetail(context),
      child: Row(
        children: [
          // Completion checkbox
          _buildCheckbox(context, ref),
          const SizedBox(width: spaceMd),

          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Coach name
                Text(
                  task.assignedByName ?? 'Coach',
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),

                // Date sent + Status
                Row(
                  children: [
                    Text(
                      _formatDate(task.createdAt),
                      style: const TextStyle(
                        color: textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: spaceSm),
                    _buildStatusIndicator(),
                  ],
                ),
              ],
            ),
          ),

          // Arrow icon
          const Icon(
            Icons.chevron_right,
            color: textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == TaskStatus.completed;
    final controller = ref.watch(coachTaskControllerProvider(task.id));

    return GestureDetector(
      onTap: controller.isLoading
          ? null
          : () async {
              if (!isCompleted && task.items.isNotEmpty) {
                // Check if all items are checked
                final allChecked = task.items.every((i) => i.isChecked);
                if (!allChecked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('أكمل كل العناصر أولاً'),
                      backgroundColor: errorColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
              }

              if (isCompleted) {
                // Already completed - can't undo from here
                return;
              }

              try {
                await ref
                    .read(coachTaskControllerProvider(task.id).notifier)
                    .markTaskComplete();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إكمال المهمة!'),
                      backgroundColor: successColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: errorColor,
                    ),
                  );
                }
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isCompleted ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(
            color: isCompleted ? primaryColor : surfaceBorder,
            width: 2,
          ),
        ),
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.black,
                size: 18,
              )
            : null,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final colors = {
      TaskStatus.pending: Colors.orange,
      TaskStatus.inProgress: Colors.blue,
      TaskStatus.completed: successColor,
      TaskStatus.cancelled: textSecondary,
    };

    final labels = {
      TaskStatus.pending: 'جديد',
      TaskStatus.inProgress: 'جاري',
      TaskStatus.completed: 'مكتمل',
      TaskStatus.cancelled: 'ملغي',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors[task.status]?.withAlpha(51),
        borderRadius: BorderRadius.circular(radiusXs),
      ),
      child: Text(
        labels[task.status]!,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors[task.status],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) return 'الآن';
      return 'اليوم';
    } else if (diff.inDays == 1) {
      return 'أمس';
    }
    return '${date.day}/${date.month}';
  }
}
