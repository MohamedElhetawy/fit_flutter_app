import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../data/task_models.dart';
import '../data/task_repository.dart' show TaskRepository, TaskException, taskRepositoryProvider;

/// Stream of all tasks for current user
final userTasksProvider = StreamProvider<List<Task>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(taskRepositoryProvider).watchUserTasks(uid);
});

/// Stream of tasks by status
final userTasksByStatusProvider = StreamProvider.family<List<Task>, TaskStatus>((ref, status) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(taskRepositoryProvider).watchUserTasksByStatus(uid, status);
});

/// Stream of pending task count (for badges)
final pendingTaskCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(0);
  return ref.watch(taskRepositoryProvider).watchPendingCount(uid);
});

/// Stream of overdue tasks
final overdueTasksProvider = StreamProvider<List<Task>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(taskRepositoryProvider).watchOverdueTasks(uid);
});

/// NEW: Stream of unread task count (for coach task badge)
final unreadTaskCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(0);
  return ref.watch(taskRepositoryProvider).watchUnreadCount(uid);
});

/// Controller for task actions with loading states
final taskActionControllerProvider =
    AsyncNotifierProviderFamily<TaskActionController, void, String>(
  TaskActionController.new,
);

class TaskActionController extends FamilyAsyncNotifier<void, String> {
  late String _userId;
  late String _taskId;

  @override
  Future<void> build(String arg) async {
    _taskId = arg;
    _userId = ref.read(authStateProvider).value?.uid ?? '';
    return;
  }

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  Future<void> startTask() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.startTask(_userId, _taskId);
    });
  }

  Future<void> completeTask() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.completeTask(_userId, _taskId);
    });
  }

  Future<void> cancelTask({String? reason}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.cancelTask(_userId, _taskId, reason: reason);
    });
  }

  Future<void> addComment({required String authorName, required String content}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.addComment(
        userId: _userId,
        taskId: _taskId,
        authorId: _userId,
        authorName: authorName,
        content: content,
      );
    });
  }
}

/// Controller for creating tasks (trainer use)
final taskCreateControllerProvider = AsyncNotifierProvider<TaskCreateController, String?>(
  TaskCreateController.new,
);

class TaskCreateController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  Future<String> createTask({
    required String userId,
    String? assignedById,
    String? assignedByName,
    required TaskType type,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    String? qrNonce,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncLoading();
    
    try {
      final id = await _repo.createTask(
        userId: userId,
        assignedById: assignedById,
        assignedByName: assignedByName,
        type: type,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        qrNonce: qrNonce,
        metadata: metadata,
      );
      
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// NEW: Controller for coach task operations (mark as read, check items, complete)
final coachTaskControllerProvider =
    AsyncNotifierProviderFamily<CoachTaskController, void, String>(
  CoachTaskController.new,
);

class CoachTaskController extends FamilyAsyncNotifier<void, String> {
  late String _userId;
  late String _taskId;

  @override
  Future<void> build(String arg) async {
    _taskId = arg;
    _userId = ref.read(authStateProvider).value?.uid ?? '';
    return;
  }

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  /// Mark task as read
  Future<void> markAsRead() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.markAsRead(_userId, _taskId);
    });
  }

  /// Mark a specific item as checked/unchecked
  Future<void> markItemChecked(String itemId, bool checked) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.markItemChecked(_userId, _taskId, itemId, checked);
    });
  }

  /// Mark task as complete (validates all items are checked first)
  Future<void> markTaskComplete() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Get current task state
      final task = await _repo.getTask(_userId, _taskId);
      if (task == null) throw TaskException('Task not found');

      // Check if all items are checked (if task has items)
      if (task.items.isNotEmpty) {
        final allChecked = task.items.every((item) => item.isChecked);
        if (!allChecked) {
          throw TaskException('Please complete all items before marking task complete');
        }
      }

      // Complete the task
      await _repo.completeTask(_userId, _taskId);
    });
  }
}
