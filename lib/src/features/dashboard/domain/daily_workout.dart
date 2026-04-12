import 'package:cloud_firestore/cloud_firestore.dart';

class DailyWorkout {
  DailyWorkout({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.date,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final DateTime date;

  factory DailyWorkout.fromMap(Map<String, dynamic> map, String docId) {
    return DailyWorkout(
      id: docId,
      title: (map['title'] as String?) ?? 'Workout',
      subtitle: (map['subtitle'] as String?) ?? '',
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'isCompleted': isCompleted,
        'date': Timestamp.fromDate(date),
      };
}
