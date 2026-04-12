import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import 'task_models.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;

  const TaskRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _userTasks(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  /// Create a new task (trainer assigning to trainee, or self-task)
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
    final doc = await _userTasks(userId).add({
      'userId': userId,
      'assignedById': assignedById,
      'assignedByName': assignedByName,
      'type': type.name,
      'title': title,
      'description': description,
      'status': 'pending',
      'priority': priority.name,
      'createdAt': DateTime.now().toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'qrNonce': qrNonce,
      'metadata': metadata,
      'comments': [],
    });
    return doc.id;
  }

  /// Start a task (pending -> inProgress)
  Future<void> startTask(String userId, String taskId) async {
    final task = await getTask(userId, taskId);
    if (task == null) throw TaskException('Task not found');
    if (!task.canStart) throw TaskException('Cannot start task from ${task.status.name}');

    await _userTasks(userId).doc(taskId).update({
      'status': 'inProgress',
      'startedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Complete a task (pending/inProgress -> completed)
  Future<void> completeTask(String userId, String taskId) async {
    final task = await getTask(userId, taskId);
    if (task == null) throw TaskException('Task not found');
    if (!task.canComplete) throw TaskException('Cannot complete task from ${task.status.name}');

    await _userTasks(userId).doc(taskId).update({
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Cancel a task (pending/inProgress -> cancelled)
  Future<void> cancelTask(String userId, String taskId, {String? reason}) async {
    final task = await getTask(userId, taskId);
    if (task == null) throw TaskException('Task not found');
    if (!task.canCancel) throw TaskException('Cannot cancel task from ${task.status.name}');

    await _userTasks(userId).doc(taskId).update({
      'status': 'cancelled',
      'cancelReason': reason,
    });
  }

  /// Add a comment to a task
  Future<void> addComment({
    required String userId,
    required String taskId,
    required String authorId,
    required String authorName,
    required String content,
  }) async {
    final comment = TaskComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
    );

    await _userTasks(userId).doc(taskId).update({
      'comments': FieldValue.arrayUnion([comment.toMap()]),
    });
  }

  /// Delete a task (only allowed for pending tasks or by creator)
  Future<void> deleteTask(String userId, String taskId) async {
    await _userTasks(userId).doc(taskId).delete();
  }

  /// Get single task
  Future<Task?> getTask(String userId, String taskId) async {
    final doc = await _userTasks(userId).doc(taskId).get();
    if (!doc.exists) return null;
    return Task.fromMap(doc.id, doc.data()!);
  }

  /// Stream all tasks for a user
  Stream<List<Task>> watchUserTasks(String userId) {
    return _userTasks(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Stream tasks by status
  Stream<List<Task>> watchUserTasksByStatus(String userId, TaskStatus status) {
    return _userTasks(userId)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Stream pending tasks (for badges/notifications)
  Stream<int> watchPendingCount(String userId) {
    return _userTasks(userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// NEW: Stream unread tasks count (for coach task badge)
  Stream<int> watchUnreadCount(String userId) {
    return _userTasks(userId)
        .where('isRead', isEqualTo: false)
        .where('status', whereIn: ['pending', 'inProgress'])
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// NEW: Mark task as read
  Future<void> markAsRead(String userId, String taskId) async {
    await _userTasks(userId).doc(taskId).update({
      'isRead': true,
    });
  }

  /// NEW: Mark a specific item as checked/unchecked
  Future<void> markItemChecked(
    String userId,
    String taskId,
    String itemId,
    bool checked,
  ) async {
    final task = await getTask(userId, taskId);
    if (task == null) throw TaskException('Task not found');

    final updatedItems = task.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isChecked: checked);
      }
      return item;
    }).toList();

    await _userTasks(userId).doc(taskId).update({
      'items': updatedItems.map((i) => i.toMap()).toList(),
    });
  }

  /// Stream overdue tasks
  Stream<List<Task>> watchOverdueTasks(String userId) {
    final now = DateTime.now().toIso8601String();
    return _userTasks(userId)
        .where('dueDate', isLessThan: now)
        .where('status', whereIn: ['pending', 'inProgress'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .where((t) => t.isOverdue)
            .toList());
  }

  /// Update task metadata (e.g., nutrition macros logged)
  Future<void> updateMetadata(
    String userId,
    String taskId,
    Map<String, dynamic> metadata,
  ) async {
    await _userTasks(userId).doc(taskId).update({
      'metadata': metadata,
    });
  }
}

class TaskException implements Exception {
  final String message;
  TaskException(this.message);
  @override
  String toString() => message;
}

/// Riverpod provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(firestore: ref.watch(firestoreProvider));
});
