enum AppRole {
  superAdmin,
  admin,
  gym,
  trainer,
  trainee,
}

extension AppRoleX on AppRole {
  String get value => name;

  static AppRole? fromString(String? raw) {
    if (raw == null) return null;
    final normalized = raw == 'super_admin' ? 'superAdmin' : raw;
    return AppRole.values.where((role) => role.value == normalized).firstOrNull;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
