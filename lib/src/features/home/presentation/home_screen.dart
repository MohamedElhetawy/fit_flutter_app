import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/features/dashboard/data/home_providers.dart';
import 'package:fitx/src/features/dashboard/data/seed_data_service.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import 'package:fitx/src/shared/widgets/section_header.dart';
import 'package:fitx/src/shared/widgets/category_pills.dart';
import 'package:fitx/src/shared/widgets/fitx_shimmer.dart';
import 'package:fitx/src/features/tasks/presentation/coach_task_card.dart';

/// Primary FitX home screen – premium design matching reference.
class FitXHomeScreen extends ConsumerStatefulWidget {
  const FitXHomeScreen({super.key});

  @override
  ConsumerState<FitXHomeScreen> createState() => _FitXHomeScreenState();
}

class _FitXHomeScreenState extends ConsumerState<FitXHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  int _selectedCategory = 0;

  final _categories = const [
    'All type',
    'Strength',
    'Chest',
    'Arm',
    'Cardio',
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding, spaceMd, defaultPadding, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: spaceLg),
                  _buildRunningCard(),
                  const SizedBox(height: spaceLg),
                  // Coach Task Card - shows active/new tasks from coach
                  const CoachTaskCard(),
                  const SizedBox(height: spaceLg),
                  const SectionHeader(
                    title: 'Health Metrics',
                    actionText: 'See all',
                  ),
                  const SizedBox(height: spaceSm),
                  _buildHealthMetrics(),
                  const SizedBox(height: spaceLg),
                  const SectionHeader(
                    title: 'Health Metrics',
                    actionText: 'See all',
                  ),
                  const SizedBox(height: spaceSm),
                  CategoryPills(
                    categories: _categories,
                    selectedIndex: _selectedCategory,
                    onSelected: (i) => setState(() => _selectedCategory = i),
                  ),
                  const SizedBox(height: spaceMd),
                  _buildWorkoutShowcase(),
                  const SizedBox(height: spaceXxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HEADER — Welcome + Avatar + Notification
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0, 0.4),
        ),
        child: Row(
          children: [
            // Avatar - Clickable to Profile
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  color: surfaceColor,
                ),
                child: const Icon(
                  Icons.person,
                  color: textSecondary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: spaceSm + spaceXs),
            // Greeting
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back 👋',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            // Seed data subtle button (only visible in dev)
            Consumer(
              builder: (context, devRef, _) {
                final seedState = devRef.watch(seedDataProvider);
                final isSeeding = seedState.isLoading;

                return GestureDetector(
                  onTap: isSeeding
                      ? null
                      : () async {
                          await devRef.read(seedDataProvider.notifier).seed();
                          // Show snackbar on completion
                          if (!context.mounted) return;
                          final result = devRef.read(seedDataProvider).value;
                          if (result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                duration: const Duration(seconds: 2),
                                backgroundColor: primaryColor.withValues(
                                  alpha: 0.9,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(radiusSm),
                                ),
                              ),
                            );
                          }
                        },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(radiusSm),
                      border: Border.all(color: surfaceBorder, width: 1),
                    ),
                    child: isSeeding
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.storage_rounded,
                            color: textSecondary,
                            size: 20,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  RUNNING CARD — Activity summary
  // ═══════════════════════════════════════════════════════════
  Widget _buildRunningCard() {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return activitiesAsync.when(
      loading: () => const FitXShimmerCard(height: 80),
      error: (_, __) => _buildErrorChip('Could not load activity'),
      data: (activities) {
        final latest = activities.isNotEmpty ? activities.first : null;
        final name = latest?.name ?? 'Running 7 days';
        final duration = latest?.durationMinutes ?? 72;
        final icon = latest?.icon ?? Icons.directions_run;

        return FitXCard(
          padding: const EdgeInsets.all(spaceMd),
          child: Row(
            children: [
              // Activity icon with olive bg
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: primaryColor, size: 26),
              ),
              const SizedBox(width: spaceMd),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: spaceXs),
                    Text(
                      '1 Days • 8 Km • ${_formatDuration(duration)}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow button
              _buildIconButton(
                icon: Icons.north_east_rounded,
                filled: true,
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HEALTH METRICS — 4 cards: Steps, Calories, Heart Rate, Sleep
  // ═══════════════════════════════════════════════════════════
  Widget _buildHealthMetrics() {
    final healthDataAsync = ref.watch(healthDataProvider);
    final userAsync = ref.watch(currentUserProfileProvider);

    return healthDataAsync.when(
      loading: () => const Wrap(
        spacing: spaceSm,
        runSpacing: spaceSm,
        children: [
          SizedBox(width: 160, height: 130, child: FitXShimmerCard(height: 130)),
          SizedBox(width: 160, height: 130, child: FitXShimmerCard(height: 130)),
          SizedBox(width: 160, height: 130, child: FitXShimmerCard(height: 130)),
          SizedBox(width: 160, height: 130, child: FitXShimmerCard(height: 130)),
        ],
      ),
      error: (_, __) => _buildErrorChip('Could not load metrics'),
      data: (healthData) {
        return userAsync.when(
          loading: () => const Wrap(
            spacing: spaceSm,
            runSpacing: spaceSm,
            children: [
              SizedBox(width: 160, height: 130, child: FitXShimmerCard(height: 130)),
              SizedBox(width: 160, height: 130, child: FitXShimmerCard(height: 130)),
              SizedBox(width: 160, height: 130, child: FitXShimmerCard(height: 130)),
              SizedBox(width: 160, height: 130, child: FitXShimmerCard(height: 130)),
            ],
          ),
          error: (_, __) => _buildErrorChip('Could not load user data'),
          data: (user) {
            // Calculate calories based on user profile and steps
            final weight = user?.weight ?? 70.0;
            final steps = healthData.steps;
            final calories = (steps * 0.04 * (weight / 70)).round(); // Approximate formula

            return Wrap(
              spacing: spaceSm,
              runSpacing: spaceSm,
              children: [
                // Steps Card
                SizedBox(
                  width: (MediaQuery.of(context).size.width - (defaultPadding * 2 + spaceSm)) / 2,
                  child: _MetricCard(
                    title: 'Steps',
                    value: steps.toString(),
                    unit: 'steps',
                    icon: Icons.directions_walk_rounded,
                    chartType: _ChartType.bar,
                    goal: 10000,
                    onTap: () => _showMetricDetail(context, 'Steps', steps, 10000, 'steps'),
                  ),
                ),
                // Calories Card
                SizedBox(
                  width: (MediaQuery.of(context).size.width - (defaultPadding * 2 + spaceSm)) / 2,
                  child: _MetricCard(
                    title: 'Calories',
                    value: calories.toString(),
                    unit: 'kcal',
                    icon: Icons.local_fire_department_rounded,
                    chartType: _ChartType.line,
                    goal: 500,
                    onTap: () => _showMetricDetail(context, 'Calories', calories, 500, 'kcal'),
                  ),
                ),
                // Heart Rate Card (Smart Watch - Coming Soon)
                SizedBox(
                  width: (MediaQuery.of(context).size.width - (defaultPadding * 2 + spaceSm)) / 2,
                  child: _MetricCard(
                    title: 'Heart Rate',
                    value: '--',
                    unit: 'bpm',
                    icon: Icons.favorite_rounded,
                    chartType: _ChartType.none,
                    isComingSoon: true,
                    comingSoonText: 'ساعة ذكية',
                    onTap: () => _showComingSoonDialog(context, 'Smart Watch Connection'),
                  ),
                ),
                // Sleep Card (Smart Watch - Coming Soon)
                SizedBox(
                  width: (MediaQuery.of(context).size.width - (defaultPadding * 2 + spaceSm)) / 2,
                  child: _MetricCard(
                    title: 'Sleep',
                    value: '--',
                    unit: 'hrs',
                    icon: Icons.bedtime_rounded,
                    chartType: _ChartType.none,
                    isComingSoon: true,
                    comingSoonText: 'ساعة ذكية',
                    onTap: () => _showComingSoonDialog(context, 'Smart Watch Connection'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMetricDetail(BuildContext context, String title, int value, int goal, String unit) {
    final percentage = (value / goal * 100).clamp(0, 100).toInt();
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: spaceLg),
            Row(
              children: [
                Icon(
                  title == 'Steps' ? Icons.directions_walk_rounded :
                  title == 'Calories' ? Icons.local_fire_department_rounded :
                  Icons.favorite_rounded,
                  color: primaryColor,
                  size: 32,
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
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'Today\'s Progress',
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: spaceLg),
            // Progress Circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 8,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'of goal',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailStat('Current', value.toString(), unit),
                _buildDetailStat('Goal', goal.toString(), unit),
                _buildDetailStat('Remaining', (goal - value).clamp(0, goal).toString(), unit),
              ],
            ),
            const SizedBox(height: spaceLg),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: const Color(0xFF1A1A00),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: textSecondary, fontSize: 12),
        ),
        const SizedBox(height: spaceXs),
        Text(
          value,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(color: textTertiary, fontSize: 11),
        ),
      ],
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.watch, color: primaryColor),
            SizedBox(width: 8),
            Text('قريباً'),
          ],
        ),
        content: Text(
          'ميزة $feature قيد التطوير حالياً و ستكون متاحة في التحديث القادم',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A1A00),
            ),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  WORKOUT SHOWCASE — Featured workout card with image
  // ═══════════════════════════════════════════════════════════
  Widget _buildWorkoutShowcase() {
    final workoutAsync = ref.watch(todayWorkoutProvider);

    return workoutAsync.when(
      loading: () => const FitXShimmerCard(height: 200),
      error: (_, __) => _buildErrorChip('Could not load workout'),
      data: (workout) {
        final title = workout?.title ?? 'Full Body Workout';
        final subtitle = workout?.subtitle ?? '24 task';

        return Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusLg),
            color: surfaceColor,
            border: Border.all(color: surfaceBorder, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radiusLg),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient overlay (simulates image overlay)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        surfaceColorLight.withValues(alpha: 0.3),
                        bgColor.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
                // Decorative fitness icon
                Positioned(
                  right: -20,
                  top: -10,
                  child: Icon(
                    Icons.fitness_center,
                    size: 140,
                    color: primaryColor.withValues(alpha: 0.05),
                  ),
                ),
                // Content overlay
                Padding(
                  padding: const EdgeInsets.all(spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: spaceSm,
                          vertical: spaceXs,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(radiusSm),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: primaryColor, size: 16),
                            SizedBox(width: spaceXs),
                            Text(
                              '4.9',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: spaceXs),
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
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(radiusSm),
          border: filled ? null : Border.all(color: surfaceBorder, width: 1),
        ),
        child: Icon(
          icon,
          color: filled ? const Color(0xFF1A1A00) : textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildErrorChip(String message) {
    return FitXCard(
      padding: const EdgeInsets.all(spaceMd),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: errorColor, size: 20),
          const SizedBox(width: spaceSm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: errorColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    const s = 0;
    return '${h}h.${m}m.${s.toString().padLeft(2, '0')}s';
  }
}

// ═══════════════════════════════════════════════════════════════
//  METRIC CARD — Health Metric tile with mini chart
// ═══════════════════════════════════════════════════════════════

enum _ChartType { bar, line, none }

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.chartType,
    this.goal,
    this.onTap,
    this.isComingSoon = false,
    this.comingSoonText,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final _ChartType chartType;
  final int? goal;
  final VoidCallback? onTap;
  final bool isComingSoon;
  final String? comingSoonText;

  @override
  Widget build(BuildContext context) {
    Widget card = FitXCard(
      padding: const EdgeInsets.all(spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isComingSoon && comingSoonText != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          comingSoonText!,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComingSoon
                      ? surfaceColorLight
                      : primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  icon,
                  color: isComingSoon ? textTertiary : primaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),
          // Value + mini chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: grandisExtendedFont,
                        color: isComingSoon ? textTertiary : textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: spaceXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isComingSoon ? surfaceColorLight : primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        unit,
                        style: TextStyle(
                          color: isComingSoon ? textTertiary : const Color(0xFF1A1A00),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Mini chart (only show if not coming soon and has chart type)
              if (!isComingSoon && chartType != _ChartType.none)
                SizedBox(
                  width: 60,
                  height: 36,
                  child: chartType == _ChartType.bar ? _MiniBars() : _MiniLine(),
                ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ── Mini Bar Chart  ──────────────────────────────────────────
class _MiniBars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final values = [0.6, 0.9, 0.4, 0.8, 1.0, 0.7];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((v) {
        return Container(
          width: 6,
          height: 36 * v,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }).toList(),
    );
  }
}

// ── Mini Line Chart ──────────────────────────────────────────
class _MiniLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 36),
      painter: _MiniLinePainter(),
    );
  }
}

class _MiniLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [0.5, 0.3, 0.7, 0.2, 0.6, 0.4, 0.8];
    final dx = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Smooth curve
        final prevX = (i - 1) * dx;
        final prevY = size.height * (1 - points[i - 1]);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
