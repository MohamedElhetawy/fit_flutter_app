import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Activity {
  Activity({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.type,
    required this.timestamp,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final String type; // 'running', 'cycling', 'swimming', 'weights', etc.
  final DateTime timestamp;

  factory Activity.fromMap(Map<String, dynamic> map, String docId) {
    return Activity(
      id: docId,
      name: (map['name'] as String?) ?? 'Activity',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      type: (map['type'] as String?) ?? 'other',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'durationMinutes': durationMinutes,
        'type': type,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'swimming':
        return Icons.pool;
      case 'weights':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'walking':
        return Icons.directions_walk;
      default:
        return Icons.sports;
    }
  }
}
