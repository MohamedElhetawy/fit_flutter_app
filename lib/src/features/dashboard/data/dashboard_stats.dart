class DashboardStats {
  DashboardStats({
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.totalWorkouts,
  });

  final int totalUsers;
  final int activeSubscriptions;
  final int totalWorkouts;

  Map<String, dynamic> toMap() => {
        'totalUsers': totalUsers,
        'activeSubscriptions': activeSubscriptions,
        'totalWorkouts': totalWorkouts,
      };

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      totalUsers: (map['totalUsers'] as num?)?.toInt() ?? 0,
      activeSubscriptions: (map['activeSubscriptions'] as num?)?.toInt() ?? 0,
      totalWorkouts: (map['totalWorkouts'] as num?)?.toInt() ?? 0,
    );
  }
}
