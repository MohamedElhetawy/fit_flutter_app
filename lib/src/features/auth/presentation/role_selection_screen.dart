import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/app_role.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(defaultPadding, spaceLg, defaultPadding, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FitX',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: spaceSm),
                    const Text(
                      'اختر نوع حسابك',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: spaceSm),
                    const Text(
                      'اختر الدور المناسب لتخصيص تجربتك في التطبيق',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _RoleTile(
                    title: 'متدرب',
                    subtitle: 'تمارين، تقدم، اشتراك',
                    icon: Icons.fitness_center,
                    onTap: () => _saveRole(context, ref, AppRole.trainee),
                    loading: loading,
                  ),
                  const SizedBox(height: spaceMd),
                  _RoleTile(
                    title: 'مدرب',
                    subtitle: 'إدارة المتدربين والخطط',
                    icon: Icons.school,
                    onTap: () => _saveRole(context, ref, AppRole.trainer),
                    loading: loading,
                  ),
                  const SizedBox(height: spaceMd),
                  _RoleTile(
                    title: 'نادي رياضي',
                    subtitle: 'إدارة المدربين والاشتراكات',
                    icon: Icons.business,
                    onTap: () => _saveRole(context, ref, AppRole.gym),
                    loading: loading,
                  ),
                  const SizedBox(height: spaceMd),
                  _RoleTile(
                    title: 'مدير',
                    subtitle: 'وصول كامل للنظام',
                    icon: Icons.admin_panel_settings,
                    onTap: () => _saveRole(context, ref, AppRole.admin),
                    loading: loading,
                  ),
                ]),
              ),
            ),
          ],
        ),
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
    required this.icon,
    required this.onTap,
    required this.loading,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FitXCard(
      onTap: loading ? null : onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(radiusSm),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                )
              : const Icon(Icons.chevron_right, color: textTertiary),
        ],
      ),
    );
  }
}
