import 'app_role.dart';

enum AppPermission {
  usersRead('users.read'),
  usersCreate('users.create'),
  usersUpdate('users.update'),
  usersDelete('users.delete'),
  subscriptionsManage('subscriptions.manage'),
  reportsView('reports.view');

  const AppPermission(this.value);
  final String value;
}

class RolePermissions {
  static final Map<AppRole, Set<AppPermission>> byRole = {
    AppRole.superAdmin: {
      AppPermission.usersRead,
      AppPermission.usersCreate,
      AppPermission.usersUpdate,
      AppPermission.usersDelete,
      AppPermission.subscriptionsManage,
      AppPermission.reportsView,
    },
    AppRole.admin: {
      AppPermission.usersRead,
      AppPermission.usersCreate,
      AppPermission.usersUpdate,
      AppPermission.usersDelete,
      AppPermission.subscriptionsManage,
      AppPermission.reportsView,
    },
    AppRole.gym: {
      AppPermission.usersRead,
      AppPermission.usersCreate,
      AppPermission.usersUpdate,
      AppPermission.subscriptionsManage,
      AppPermission.reportsView,
    },
    AppRole.trainer: {
      AppPermission.usersRead,
      AppPermission.usersUpdate,
      AppPermission.reportsView,
    },
    AppRole.trainee: {
      AppPermission.reportsView,
    },
  };
}
