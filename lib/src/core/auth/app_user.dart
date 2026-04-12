import 'app_role.dart';

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.phone,
    this.createdBy,
    this.gymId,
    this.authProvider,
    this.lastLogin,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final AppRole role;
  final String status;
  final String? createdBy;
  final String? gymId;
  final String? authProvider;
  final DateTime? lastLogin;
  final DateTime? createdAt;

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      if (raw is DateTime) return raw;
      if (raw.toString().isEmpty) return null;
      return DateTime.tryParse(raw.toString());
    }

    return AppUser(
      id: id,
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: map['phone']?.toString(),
      role: AppRoleX.fromString(map['role']?.toString()) ?? AppRole.trainee,
      status: (map['status'] ?? 'active').toString(),
      createdBy: map['createdBy']?.toString(),
      gymId: map['gymId']?.toString(),
      authProvider: map['authProvider']?.toString(),
      lastLogin: parseDate(map['lastLogin']),
      createdAt: parseDate(map['createdAt']),
    );
  }
}
