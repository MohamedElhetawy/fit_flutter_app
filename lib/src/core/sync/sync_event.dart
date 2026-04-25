import 'package:isar/isar.dart';

part 'sync_event.g.dart';

@collection
class SyncEvent {
  Id id = Isar.autoIncrement;

  /// The table or collection name this event relates to (e.g., 'workouts', 'meal_logs')
  late String collectionName;

  /// Unique identifier of the record in the local database
  late String recordId;

  /// The operation type. Could be: 'CREATE', 'UPDATE', 'DELETE'
  late String operation;

  /// Serialized payload of the data (JSON string)
  late String payload;

  /// Timestamp of when the event occurred initially
  late DateTime createdAt;

  /// Number of times the engine has tried processing this event
  int retryCount = 0;

  /// Whether we could not process this error ultimately and gave up
  bool hasError = false;

  String? errorMessage;
}
