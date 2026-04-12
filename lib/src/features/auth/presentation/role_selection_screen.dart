import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/app_role.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Nerva X Role Setup')),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: defaultPadding),
            child: Text(
              'Choose your FitX role to personalize your SaaS dashboard.',
            ),
          ),
          _RoleTile(
            title: 'Trainee',
            subtitle: 'Workouts, progress, subscription',
            onTap: () => _saveRole(context, ref, AppRole.trainee),
            loading: loading,
          ),
          _RoleTile(
            title: 'Trainer',
            subtitle: 'Assigned users and plans',
            onTap: () => _saveRole(context, ref, AppRole.trainer),
            loading: loading,
          ),
          _RoleTile(
            title: 'Gym',
            subtitle: 'Manage trainers and subscriptions',
            onTap: () => _saveRole(context, ref, AppRole.gym),
            loading: loading,
          ),
          _RoleTile(
            title: 'Admin',
            subtitle: 'Full dashboard access',
            onTap: () => _saveRole(context, ref, AppRole.admin),
            loading: loading,
          ),
        ],
      ),
    );
  }

  Future<void> _saveRole(
    BuildContext context,
    WidgetRef ref,
    AppRole role,
  ) async {
    await ref.read(authControllerProvider.notifier).saveRole(role);
    if (context.mounted) {
      context.go('/dashboard');
    }
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.loading,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: loading ? null : onTap,
      ),
    );
  }
}
