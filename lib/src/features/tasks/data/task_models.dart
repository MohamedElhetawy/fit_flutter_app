/// Comprehensive Task model with full lifecycle support
class Task {
  final String id;
  final String userId; // Assigned to
  final String? assignedById; // Trainer who assigned (null if self-assigned)
  final String? assignedByName;
  final TaskType type;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? qrNonce; // If created via QR scan
  final Map<String, dynamic>? metadata; // Workout details, nutrition macros, etc.
  final List<TaskComment> comments;
  final bool isRead; // NEW: Whether user has viewed the task
  final List<TaskItem> items; // NEW: Checkable items for task completion

  const Task({
    required this.id,
    required this.userId,
    this.assignedById,
    this.assignedByName,
    required this.type,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.startedAt,
    this.completedAt,
    this.qrNonce,
    this.metadata,
    this.comments = const [],
    this.isRead = false, // NEW
    this.items = const [], // NEW
  });

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      userId: map['userId']?.toString() ?? '',
      assignedById: map['assignedById']?.toString(),
      assignedByName: map['assignedByName']?.toString(),
      type: _parseTaskType(map['type']?.toString()),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      status: _parseTaskStatus(map['status']?.toString()),
      priority: _parseTaskPriority(map['priority']?.toString()),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate']?.toString() ?? ''),
      startedAt: DateTime.tryParse(map['startedAt']?.toString() ?? ''),
      completedAt: DateTime.tryParse(map['completedAt']?.toString() ?? ''),
      qrNonce: map['qrNonce']?.toString(),
      metadata: map['metadata'] as Map<String, dynamic>?,
      comments: (map['comments'] as List<dynamic>?)
              ?.map((c) => TaskComment.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      isRead: map['isRead'] as bool? ?? false, // NEW
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => TaskItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [], // NEW
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'assignedById': assignedById,
        'assignedByName': assignedByName,
        'type': type.name,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'qrNonce': qrNonce,
        'metadata': metadata,
        'comments': comments.map((c) => c.toMap()).toList(),
        'isRead': isRead, // NEW
        'items': items.map((i) => i.toMap()).toList(growable: false), // NEW
      };

  Task copyWith({
    TaskStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    List<TaskComment>? comments,
    bool? isRead,
    List<TaskItem>? items,
  }) {
    return Task(
      id: id,
      userId: userId,
      assignedById: assignedById,
      assignedByName: assignedByName,
      type: type,
      title: title,
      description: description,
      status: status ?? this.status,
      priority: priority,
      createdAt: createdAt,
      dueDate: dueDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      qrNonce: qrNonce,
      metadata: metadata,
      comments: comments ?? this.comments,
      isRead: isRead ?? this.isRead,
      items: items ?? this.items,
    );
  }

  /// Can transition to in_progress?
  bool get canStart => status == TaskStatus.pending;

  /// Can transition to completed?
  bool get canComplete => status == TaskStatus.inProgress || status == TaskStatus.pending;

  /// Can transition to cancelled?
  bool get canCancel => status == TaskStatus.pending || status == TaskStatus.inProgress;

  /// Is overdue?
  bool get isOverdue {
    if (dueDate == null) return false;
    if (status == TaskStatus.completed || status == TaskStatus.cancelled) return false;
    return DateTime.now().isAfter(dueDate!);
  }
}

enum TaskType { nutrition, workout, measurement, general }

enum TaskStatus { pending, inProgress, completed, cancelled }

enum TaskPriority { low, medium, high, urgent }

class TaskComment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const TaskComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory TaskComment.fromMap(Map<String, dynamic> map) {
    return TaskComment(
      id: map['id']?.toString() ?? '',
      authorId: map['authorId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Checkable item within a task (e.g., an exercise or meal)
class TaskItem {
  final String id;
  final String title;
  final bool isChecked;

  const TaskItem({
    required this.id,
    required this.title,
    this.isChecked = false,
  });

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      isChecked: map['isChecked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isChecked': isChecked,
      };

  TaskItem copyWith({
    String? id,
    String? title,
    bool? isChecked,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

// Extension getters for display
extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get name {
    switch (this) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'inProgress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
    }
  }
}

extension TaskTypeExtension on TaskType {
  String get name {
    switch (this) {
      case TaskType.nutrition:
        return 'nutrition';
      case TaskType.workout:
        return 'workout';
      case TaskType.measurement:
        return 'measurement';
      case TaskType.general:
        return 'general';
    }
  }

  String get displayName {
    switch (this) {
      case TaskType.nutrition:
        return 'Nutrition';
      case TaskType.workout:
        return 'Workout';
      case TaskType.measurement:
        return 'Body Measurement';
      case TaskType.general:
        return 'General';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
      case TaskPriority.urgent:
        return 'urgent';
    }
  }

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

// Parsing helpers
TaskType _parseTaskType(String? value) {
  switch (value) {
    case 'nutrition':
      return TaskType.nutrition;
    case 'workout':
      return TaskType.workout;
    case 'measurement':
      return TaskType.measurement;
    case 'general':
      return TaskType.general;
    default:
      return TaskType.general;
  }
}

TaskStatus _parseTaskStatus(String? value) {
  switch (value) {
    case 'pending':
      return TaskStatus.pending;
    case 'inProgress':
      return TaskStatus.inProgress;
    case 'completed':
      return TaskStatus.completed;
    case 'cancelled':
      return TaskStatus.cancelled;
    default:
      return TaskStatus.pending;
  }
}

TaskPriority _parseTaskPriority(String? value) {
  switch (value) {
    case 'low':
      return TaskPriority.low;
    case 'medium':
      return TaskPriority.medium;
    case 'high':
      return TaskPriority.high;
    case 'urgent':
      return TaskPriority.urgent;
    default:
      return TaskPriority.medium;
  }
}
