import 'package:cloud_firestore/cloud_firestore.dart';

class GymStats {
  final int trainees;
  final int trainers;
  final int subscriptions;
  final int revenue;

  const GymStats({this.trainees = 0, this.trainers = 0, this.subscriptions = 0, this.revenue = 0});

  factory GymStats.fromMap(Map<String, dynamic>? map) {
    return GymStats(
      trainees: (map?['traineeCount'] as num?)?.toInt() ?? 0,
      trainers: (map?['trainerCount'] as num?)?.toInt() ?? 0,
      subscriptions: (map?['subscriptionCount'] as num?)?.toInt() ?? 0,
      revenue: (map?['totalRevenue'] as num?)?.toInt() ?? 0,
    );
  }
}

class GymRevenue {
  final int total;
  final int monthly;
  final int activeSubscriptions;

  const GymRevenue({this.total = 0, this.monthly = 0, this.activeSubscriptions = 0});

  factory GymRevenue.fromMap(Map<String, dynamic>? map) {
    return GymRevenue(
      total: (map?['totalRevenue'] as num?)?.toInt() ?? 0,
      monthly: (map?['monthlyRevenue'] as num?)?.toInt() ?? 0,
      activeSubscriptions: (map?['activeSubscriptionCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class GymOverview {
  final GymStats stats;
  final GymRevenue revenue;

  const GymOverview({required this.stats, required this.revenue});

  factory GymOverview.fromMap(Map<String, dynamic>? map) {
    return GymOverview(
      stats: GymStats.fromMap(map),
      revenue: GymRevenue.fromMap(map),
    );
  }
}

class Trainer {
  final String id;
  final String name;
  final String email;
  final int traineeCount;

  const Trainer({required this.id, required this.name, required this.email, required this.traineeCount});

  factory Trainer.fromMap(Map<String, dynamic> map, String id) {
    return Trainer(
      id: id,
      name: map['name'] ?? 'بدون اسم',
      email: map['email'] ?? '',
      traineeCount: (map['traineeCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class Trainee {
  final String id;
  final String name;
  final String email;
  final String trainerName;

  const Trainee({required this.id, required this.name, required this.email, required this.trainerName});

  factory Trainee.fromMap(Map<String, dynamic> map, String id) {
    return Trainee(
      id: id,
      name: map['name'] ?? 'بدون اسم',
      email: map['email'] ?? '',
      trainerName: map['trainerName'] ?? 'غير محدد',
    );
  }
}

class GymActivity {
  final String id;
  final String type;
  final String message;
  final DateTime timestamp;

  const GymActivity({required this.id, required this.type, required this.message, required this.timestamp});

  factory GymActivity.fromMap(Map<String, dynamic> map, String id) {
    final ts = map['timestamp'];
    DateTime time = DateTime.now();
    if (ts is Timestamp) {
      time = ts.toDate();
    } else if (ts is DateTime) {
      time = ts;
    }
    return GymActivity(
      id: id,
      type: map['type'] ?? '',
      message: map['message'] ?? '',
      timestamp: time,
    );
  }
}
