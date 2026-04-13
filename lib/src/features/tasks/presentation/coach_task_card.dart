import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import 'package:fitx/src/features/tasks/data/task_models.dart';
import 'package:fitx/src/features/tasks/providers/task_providers.dart';
import 'task_detail_screen.dart';

/// Coach Task Card widget for Home screen
/// Displays 3 states: Empty, New (unread), In Progress
class CoachTaskCard extends ConsumerWidget {
  const CoachTaskCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(userTasksProvider);

    return tasksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (tasks) {
        // Find the most relevant active task
        final activeTasks = tasks.where((t) =>
          t.status == TaskStatus.pending || t.status == TaskStatus.inProgress
        ).toList();

        if (activeTasks.isEmpty) {
          return _buildEmptyState();
        }

        // Prioritize unread tasks, then by priority
        activeTasks.sort((a, b) {
          if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
          return b.priority.index - a.priority.index;
        });

        final task = activeTasks.first;

        if (!task.isRead) {
          return _buildNewState(context, ref, task);
        }

        return _buildInProgressState(context, ref, task);
      },
    );
  }

  /// Empty state - waiting for next task
  Widget _buildEmptyState() {
    return FitXCard(
      child: Row(
        children: [
          // Coach avatar placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surfaceColorLight,
              border: Border.all(
                color: surfaceBorder,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coach',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Waiting for your next task...',
                  style: TextStyle(
                    color: textPrimary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// New state - unread task with pulsing badge
  Widget _buildNewState(BuildContext context, WidgetRef ref, Task task) {
    return FitXCard(
      accentGlow: true,
      onTap: () => _navigateToDetail(context, ref, task),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Pulsing notification badge
              _PulsingBadge(),
              const SizedBox(width: spaceSm),
              Expanded(
                child: Text(
                  'New task from ${task.assignedByName ?? 'Coach'}',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),
          Row(
            children: [
              Icon(
                task.type == TaskType.workout
                    ? Icons.fitness_center
                    : Icons.restaurant,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: spaceSm),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(task.createdAt),
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _navigateToDetail(context, ref, task),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: spaceMd,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radiusMd),
                  ),
                ),
                child: const Text(
                  'View Now',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// In Progress state - shows progress bar
  Widget _buildInProgressState(BuildContext context, WidgetRef ref, Task task) {
    final progress = _calculateProgress(task);
    final checkedCount = task.items.where((i) => i.isChecked).length;
    final totalCount = task.items.length;

    return FitXCard(
      onTap: () => _navigateToDetail(context, ref, task),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surfaceColorLight,
                  border: Border.all(
                    color: surfaceBorder,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.assignedByName ?? 'Coach',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                  ],
                ),
              ),
            ],
          ),
          if (task.items.isNotEmpty) ...[
            const SizedBox(height: spaceMd),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(radiusXs),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: surfaceBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: spaceSm),
            Text(
              '$checkedCount/$totalCount exercises',
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _navigateToDetail(context, ref, task),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: spaceMd,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, WidgetRef ref, Task task) async {
    // Mark as read when navigating
    if (!task.isRead) {
      await ref.read(coachTaskControllerProvider(task.id).notifier).markAsRead();
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskDetailScreen(task: task),
        ),
      );
    }
  }

  double _calculateProgress(Task task) {
    if (task.items.isEmpty) return 0;
    final checked = task.items.where((i) => i.isChecked).length;
    return checked / task.items.length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Just now';
      }
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    }
    return '${diff.inDays} days ago';
  }
}

/// Pulsing notification badge widget
class _PulsingBadge extends StatefulWidget {
  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 14,
            ),
          ),
        );
      },
    );
  }
}
