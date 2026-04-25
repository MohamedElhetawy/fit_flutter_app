import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import 'package:fitx/src/features/tasks/data/task_models.dart';
import 'package:fitx/src/features/tasks/providers/task_providers.dart';

/// Task Detail Screen - full screen view with interactive checkable items
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late List<TaskItem> _localItems;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _localItems = List.from(widget.task.items);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final progress = _calculateProgress();
    final allChecked = progress == 1.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: textPrimary),
              ),
              actions: [
                // Progress indicator in app bar
                if (task.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: defaultPadding),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(radiusFull),
                          border: Border.all(color: surfaceBorder),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header: Coach + Type
                  _buildHeader(task),
                  const SizedBox(height: spaceLg),

                  // Progress bar (if has items)
                  if (task.items.isNotEmpty) ...[
                    _buildProgressBar(progress),
                    const SizedBox(height: spaceLg),
                  ],

                  // Task Title
                  Text(
                    task.title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: spaceSm),

                  // Description
                  if (task.description != null) ...[
                    Text(
                      task.description!,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: spaceLg),
                  ],

                  // Task Items (Checkable list)
                  if (task.items.isNotEmpty) ...[
                    _buildItemsList(),
                    const SizedBox(height: spaceLg),
                  ],

                  // Complete Button
                  _buildCompleteButton(task, allChecked),

                  const SizedBox(height: spaceLg * 2),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Task task) {
    return Row(
      children: [
        // Coach avatar placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: surfaceColorLight,
            border: Border.all(
              color: surfaceBorder,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.person,
            color: textSecondary,
            size: 28,
          ),
        ),
        const SizedBox(width: spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.assignedByName ?? 'مدرب',
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    task.type == TaskType.workout
                        ? Icons.fitness_center
                        : Icons.restaurant,
                    color: primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task.type == TaskType.workout ? 'تمرين' : 'تغذية',
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'التقدم',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              '${_localItems.where((i) => i.isChecked).length}/${_localItems.length}',
              style: const TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: spaceSm),
        ClipRRect(
          borderRadius: BorderRadius.circular(radiusXs),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: surfaceBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return FitXCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.type == TaskType.workout ? 'التمارين' : 'عناصر الوجبة',
            style: const TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: spaceMd),
          ...List.generate(_localItems.length, (index) {
            final item = _localItems[index];
            return _buildItemRow(item, index);
          }),
        ],
      ),
    );
  }

  Widget _buildItemRow(TaskItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spaceSm),
      child: GestureDetector(
        onTap: () => _toggleItem(index),
        child: Container(
          padding: const EdgeInsets.all(spaceSm),
          decoration: BoxDecoration(
            color:
                item.isChecked ? primaryColor.withAlpha(26) : surfaceColorLight,
            borderRadius: BorderRadius.circular(radiusMd),
            border: Border.all(
              color:
                  item.isChecked ? primaryColor.withAlpha(77) : surfaceBorder,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.isChecked ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(radiusSm),
                  border: Border.all(
                    color: item.isChecked ? primaryColor : surfaceBorder,
                    width: 2,
                  ),
                ),
                child: item.isChecked
                    ? const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: spaceSm),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: item.isChecked ? textSecondary : textPrimary,
                    fontSize: 14,
                    decoration:
                        item.isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton(Task task, bool allChecked) {
    final canComplete = allChecked || task.items.isEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            canComplete && !_isCompleting ? () => _completeTask(task) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canComplete ? primaryColor : surfaceColorLight,
          foregroundColor: canComplete ? Colors.black : textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          elevation: canComplete ? 4 : 0,
          shadowColor: canComplete ? primaryColor.withAlpha(102) : null,
        ),
        child: _isCompleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canComplete ? Icons.check_circle : Icons.lock,
                    size: 20,
                  ),
                  const SizedBox(width: spaceSm),
                  Text(
                    canComplete ? 'تحديد كمكتمل' : 'أكمل كل العناصر أولاً',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _toggleItem(int index) async {
    final item = _localItems[index];
    final newValue = !item.isChecked;

    // Update local state immediately for responsive UI
    setState(() {
      _localItems[index] = item.copyWith(isChecked: newValue);
    });

    // Sync with backend
    try {
      await ref
          .read(coachTaskControllerProvider(widget.task.id).notifier)
          .markItemChecked(item.id, newValue);
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _localItems[index] = item;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التحديث: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  Future<void> _completeTask(Task task) async {
    setState(() => _isCompleting = true);

    try {
      await ref
          .read(coachTaskControllerProvider(task.id).notifier)
          .markTaskComplete();

      if (mounted) {
        // Show success animation/feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: spaceSm),
                Text('تم إكمال المهمة! عمل رائع!'),
              ],
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back after delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCompleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  double _calculateProgress() {
    if (_localItems.isEmpty) return 0;
    final checked = _localItems.where((i) => i.isChecked).length;
    return checked / _localItems.length;
  }
}
