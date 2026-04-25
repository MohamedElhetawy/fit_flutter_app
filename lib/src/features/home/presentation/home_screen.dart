import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import '../../../shared/widgets/fitx_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/fitx_shimmer.dart';
import '../../dashboard/data/home_providers.dart';
import '../../dashboard/providers/unified_steps_provider.dart';
import '../../tasks/presentation/coach_task_card.dart';

// ─── HOME SCREEN (CLEAN VERSION) ──────────────────────────

class FitXHomeScreen extends ConsumerWidget {
  const FitXHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _HomeAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: spaceLg),
                  _RecentActivityCard(),
                  const SizedBox(height: spaceLg),
                  const CoachTaskCard(),
                  const SizedBox(height: spaceLg),
                  const SectionHeader(title: 'التقدم اليومي'),
                  const SizedBox(height: spaceSm),
                  _UnifiedMetricsGrid(),
                  const SizedBox(height: spaceLg),
                  const SectionHeader(title: 'موصى به'),
                  const SizedBox(height: spaceSm),
                  _WorkoutFeaturedCard(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SUB-WIDGETS (MODULAR) ────────────────────────────────

class _HomeAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    return SliverPadding(
      padding:
          const EdgeInsets.fromLTRB(defaultPadding, spaceMd, defaultPadding, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            _CircularAvatar(onTap: () => context.go('/profile')),
            const SizedBox(width: spaceMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أهلاً بيك 👋',
                    style: TextStyle(color: textSecondary, fontSize: 13)),
                Text(profile?.name ?? 'Loading...',
                    style: const TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            const _IconButton(icon: Icons.notifications_none_rounded),
          ],
        ),
      ),
    );
  }
}

class _UnifiedMetricsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(dailyHealthProvider).valueOrNull;
    final steps = ref.watch(unifiedStepsProvider); // Real-time unified steps
    if (health == null) return const FitXShimmerCard(height: 150);

    return Wrap(
      spacing: spaceSm,
      runSpacing: spaceSm,
      children: [
        _MetricCard(
          title: 'الخطوات',
          value: steps.toString(), // Use unified steps (real-time)
          unit: 'خطوة',
          icon: Icons.directions_walk,
          color: primaryColor,
          progress: (steps / 10000).clamp(0.0, 1.0),
        ),
        _MetricCard(
          title: 'التغذية',
          value: health.caloriesConsumed.toString(),
          unit: 'سعرة',
          icon: Icons.restaurant,
          color: Colors.orange,
          progress: health.calorieProgress,
        ),
        _MetricCard(
          title: 'الماء',
          value: health.waterLiters.toStringAsFixed(1),
          unit: 'لتر',
          icon: Icons.water_drop,
          color: Colors.blue,
          progress: health.waterProgress,
        ),
        _MetricCard(
          title: 'محروق',
          value: health.caloriesBurned.toString(),
          unit: 'سعرة',
          icon: Icons.bolt,
          color: Colors.redAccent,
          progress: (health.caloriesBurned / 500).clamp(0.0, 1.0),
        ),
      ],
    );
  }
}

class _RecentActivityCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivitiesProvider).valueOrNull;
    if (activities == null || activities.isEmpty) {
      return const SizedBox.shrink();
    }

    final latest = activities.first;
    return FitXCard(
      accentGlow: true,
      child: Row(
        children: [
          const _IconCircle(icon: Icons.bolt, color: primaryColor),
          const SizedBox(width: spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(latest.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${latest.durationMinutes} دقيقة نشاط',
                    style: const TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: textTertiary),
        ],
      ),
    );
  }
}

class _WorkoutFeaturedCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(todayWorkoutProvider).valueOrNull;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusLg),
        gradient: const LinearGradient(
            colors: [surfaceColor, bgColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        border: Border.all(color: surfaceBorder),
      ),
      child: Stack(
        children: [
          Positioned(
              right: -10,
              bottom: -10,
              child: Icon(Icons.fitness_center,
                  size: 100, color: primaryColor.withAlpha(13))),
          Padding(
            padding: const EdgeInsets.all(spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الجلسة اليومية',
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(workout?.title ?? 'Full Body Blast',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton(onPressed: () {}, child: const Text('استمرار')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SHARED MINI COMPONENTS ───────────────────────────────

class _MetricCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;
  final double progress;

  const _MetricCard(
      {required this.title,
      required this.value,
      required this.unit,
      required this.icon,
      required this.color,
      required this.progress});

  @override
  Widget build(BuildContext context) {
    final width =
        (MediaQuery.of(context).size.width - (defaultPadding * 2 + spaceSm)) /
            2;
    return Container(
      width: width,
      padding: const EdgeInsets.all(spaceMd),
      decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radiusMd),
          border: Border.all(color: surfaceBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.5,
                      backgroundColor: surfaceBorder,
                      valueColor: AlwaysStoppedAnimation(color))),
            ],
          ),
          const SizedBox(height: spaceMd),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: grandisExtendedFont)),
          Text(unit,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CircularAvatar extends StatelessWidget {
  final VoidCallback onTap;
  const _CircularAvatar({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withAlpha(77), width: 2),
              color: surfaceColor),
          child: const Icon(Icons.person, color: textSecondary, size: 22)),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  const _IconButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(radiusSm),
            border: Border.all(color: surfaceBorder)),
        child: Icon(icon, color: textSecondary, size: 20));
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconCircle({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(26)),
        child: Icon(icon, color: color, size: 20));
  }
}
