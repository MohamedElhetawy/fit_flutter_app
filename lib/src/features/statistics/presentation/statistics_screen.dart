import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/features/dashboard/data/home_providers.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import 'package:fitx/src/shared/widgets/section_header.dart';
import 'package:fitx/src/shared/widgets/fitx_shimmer.dart';
import '../providers/pedometer_provider.dart';

/// Statistics / Daily Report screen matching reference image 2.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _selectedDate = 3; // "Today 15, Jan" index
  int _selectedTab = 0; // Week / Day / Month

  final _chartTabs = const ['Week', 'Day', 'Month'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding, spaceMd, defaultPadding, 0),
              sliver: SliverToBoxAdapter(
                child: _buildAppBar(),
              ),
            ),
            // ── Date Selector ────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.only(top: spaceLg),
              sliver: SliverToBoxAdapter(
                child: _buildDateSelector(),
              ),
            ),
            // ── Body ─────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding, spaceLg, defaultPadding, spaceXxl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHealthGrade(),
                  const SizedBox(height: spaceLg),
                  const SectionHeader(
                    title: 'Health Metrics',
                    actionText: 'See all',
                  ),
                  const SizedBox(height: spaceSm),
                  _buildMetricsGrid(),
                  const SizedBox(height: spaceLg),
                  _buildWorkoutChart(),
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
  //  APP BAR — Back, Title, Calendar
  // ═══════════════════════════════════════════════════════════
  Widget _buildAppBar() {
    return Row(
      children: [
        _buildIconBtn(Icons.arrow_back_rounded),
        const Expanded(
          child: Text(
            'Daily Report',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildIconBtn(Icons.calendar_month_rounded, filled: true),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  DATE SELECTOR — Horizontal date scroll
  // ═══════════════════════════════════════════════════════════
  Widget _buildDateSelector() {
    final now = DateTime.now();
    final dates = List.generate(8, (i) => now.subtract(Duration(days: 3 - i)));

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: defaultPadding),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: spaceSm),
        itemBuilder: (context, index) {
          final d = dates[index];
          final isSelected = index == _selectedDate;
          final isToday = d.day == now.day && d.month == now.month;

          String label;
          if (isToday) {
            final months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            label = 'Today ${d.day}, ${months[d.month - 1]}';
          } else {
            label = '${d.day}';
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = index),
            child: AnimatedContainer(
              duration: fastDuration,
              padding: EdgeInsets.symmetric(
                horizontal: isToday ? 16 : 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(radiusFull),
                border: isSelected
                    ? null
                    : Border.all(
                        color: surfaceBorder,
                        width: 1,
                      ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF1A1A00)
                        : textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HEALTH GRADE — Circular progress card
  // ═══════════════════════════════════════════════════════════
  Widget _buildHealthGrade() {
    final progressAsync = ref.watch(userProgressProvider);

    return progressAsync.when(
      loading: () => const FitXShimmerCard(height: 100),
      error: (_, __) => const SizedBox.shrink(),
      data: (progress) {
        final ratio = progress?.progressRatio ?? 0.18;
        final percent = (ratio * 100).round();

        return FitXCard(
          color: surfaceColorLight,
          padding: const EdgeInsets.all(spaceMd + 4),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Grade',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: spaceSm),
                    Text(
                      'Perfect progress dude, keep\ngoing to apply your fitness activity',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular Progress
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 5,
                        backgroundColor: surfaceBorder,
                        valueColor:
                            const AlwaysStoppedAnimation(primaryColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontFamily: grandisExtendedFont,
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  METRICS GRID — 2x2 health metric cards (Steps, Calories, Heart Rate, Sleep)
  // ═══════════════════════════════════════════════════════════
  Widget _buildMetricsGrid() {
    final stepsAsync = ref.watch(stepsStreamProvider);
    final userAsync = ref.watch(currentUserProfileProvider);

    return stepsAsync.when(
      loading: () => const Column(
        children: [
          Row(children: [
            Expanded(child: FitXShimmerCard(height: 120)),
            SizedBox(width: spaceSm),
            Expanded(child: FitXShimmerCard(height: 120)),
          ]),
          SizedBox(height: spaceSm),
          Row(children: [
            Expanded(child: FitXShimmerCard(height: 120)),
            SizedBox(width: spaceSm),
            Expanded(child: FitXShimmerCard(height: 120)),
          ]),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (steps) {
        return userAsync.when(
          loading: () => const Column(
            children: [
              Row(children: [
                Expanded(child: FitXShimmerCard(height: 120)),
                SizedBox(width: spaceSm),
                Expanded(child: FitXShimmerCard(height: 120)),
              ]),
              SizedBox(height: spaceSm),
              Row(children: [
                Expanded(child: FitXShimmerCard(height: 120)),
                SizedBox(width: spaceSm),
                Expanded(child: FitXShimmerCard(height: 120)),
              ]),
            ],
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (user) {
            // Calculate calories from steps based on user weight
            final weight = user?.weight ?? 70.0;
            final calories = (steps * 0.04 * (weight / 70)).round();

            return Column(
              children: [
                Row(children: [
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Steps',
                      value: steps.toString(),
                      unit: 'steps',
                      icon: Icons.directions_walk_rounded,
                      hasBarChart: true,
                      onTap: () => _showStepsBottomSheet(context, steps),
                    ),
                  ),
                  const SizedBox(width: spaceSm),
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Calories',
                      value: calories.toString(),
                      unit: 'kcal',
                      icon: Icons.local_fire_department_rounded,
                      hasBarChart: false,
                      onTap: () => _showCaloriesBottomSheet(context, calories),
                    ),
                  ),
                ]),
                const SizedBox(height: spaceSm),
                Row(children: [
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Heart Rate',
                      value: '--',
                      unit: 'bpm',
                      icon: Icons.favorite_rounded,
                      hasBarChart: false,
                      showChart: false,
                      showSmartWatchBadge: true,
                      isDisabled: true,
                      onTap: () => _showComingSoonDialog(context, 'Smart Watch'),
                    ),
                  ),
                  const SizedBox(width: spaceSm),
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Sleep',
                      value: '--',
                      unit: 'hrs',
                      icon: Icons.bedtime_rounded,
                      hasBarChart: false,
                      showChart: false,
                      showSmartWatchBadge: true,
                      isDisabled: true,
                      onTap: () => _showComingSoonDialog(context, 'Smart Watch'),
                    ),
                  ),
                ]),
              ],
            );
          },
        );
      },
    );
  }

  void _showStepsBottomSheet(BuildContext context, int steps) {
    final goal = ref.read(stepsGoalProvider);
    final percentage = (steps / goal * 100).clamp(0, 100).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: spaceLg),
                // Header
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.2),
                      ),
                      child: const Icon(Icons.directions_walk_rounded, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: spaceMd),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Steps',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Today\'s Progress',
                            style: TextStyle(color: textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: spaceLg),
                // Progress Ring
                _buildProgressRing(percentage, steps.toString(), goal.toString()),
                const SizedBox(height: spaceLg),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Current', steps.toString(), 'steps'),
                    _buildStatColumn('Goal', goal.toString(), 'steps'),
                    _buildStatColumn('Remaining', (goal - steps).clamp(0, goal).toString(), 'steps'),
                  ],
                ),
                const SizedBox(height: spaceLg),
                // Manual Entry Button
                ElevatedButton.icon(
                  onPressed: () => _showManualStepsDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة خطوات يدوياً'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: const Color(0xFF1A1A00),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
                const SizedBox(height: spaceMd),
                // Close button
                OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: surfaceBorder),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('إغلاق', style: TextStyle(color: textPrimary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCaloriesBottomSheet(BuildContext context, int calories) {
    const goal = 500; // Default calorie goal
    final percentage = (calories / goal * 100).clamp(0, 100).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.2),
                      ),
                      child: const Icon(Icons.local_fire_department_rounded, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: spaceMd),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calories',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Burned Today',
                            style: TextStyle(color: textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: spaceLg),
                _buildProgressRing(percentage, calories.toString(), '$goal kcal'),
                const SizedBox(height: spaceLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Burned', calories.toString(), 'kcal'),
                    _buildStatColumn('Goal', goal.toString(), 'kcal'),
                    _buildStatColumn('Remaining', (goal - calories).clamp(0, goal).toString(), 'kcal'),
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
        ),
      ),
    );
  }

  Widget _buildProgressRing(int percentage, String value, String label) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: surfaceColorLight,
                width: 12,
              ),
            ),
          ),
          // Progress arc
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 12,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          // Center text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: textSecondary, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit) {
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
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(color: textTertiary, fontSize: 12),
        ),
      ],
    );
  }

  void _showManualStepsDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text('إضافة خطوات', style: TextStyle(color: textPrimary)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'عدد الخطوات',
            hintStyle: const TextStyle(color: textTertiary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusMd),
              borderSide: const BorderSide(color: surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusMd),
              borderSide: const BorderSide(color: surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusMd),
              borderSide: const BorderSide(color: primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(controller.text) ?? 0;
              if (steps > 0) {
                ref.read(manualStepsProvider.notifier).addSteps(steps);
              }
              context.pop();
              context.pop(); // Close bottom sheet too
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A1A00),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
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
            Text('قريباً', style: TextStyle(color: textPrimary)),
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
  //  WORKOUT CHART
  // ═══════════════════════════════════════════════════════════
  Widget _buildWorkoutChart() {
    return FitXCard(
      padding: const EdgeInsets.all(spaceMd),
      child: Column(
        children: [
          // Header + tabs
          Row(
            children: [
              const Text(
                'Workout',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ...List.generate(_chartTabs.length, (i) {
                final isSelected = i == _selectedTab;
                return Padding(
                  padding: const EdgeInsets.only(left: spaceXs),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: fastDuration,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(radiusFull),
                        border: isSelected
                            ? null
                            : Border.all(color: surfaceBorder, width: 1),
                      ),
                      child: Text(
                        _chartTabs[i],
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF1A1A00)
                              : textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: spaceMd),
          // Chart area
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _WorkoutChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget _buildIconBtn(IconData icon, {bool filled = false}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: filled ? primaryColor : surfaceColor,
        borderRadius: BorderRadius.circular(radiusSm),
        border: filled
            ? null
            : Border.all(color: surfaceBorder, width: 1),
      ),
      child: Icon(
        icon,
        color: filled ? const Color(0xFF1A1A00) : textSecondary,
        size: 20,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SMALL METRIC CARD (for Statistics 2x2 grid)
// ═══════════════════════════════════════════════════════════════
class _SmallMetricCard extends StatelessWidget {
  const _SmallMetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.hasBarChart = true,
    this.showChart = true,
    this.showSmartWatchBadge = false,
    this.isDisabled = false,
    this.onTap,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final bool hasBarChart;
  final bool showChart;
  final bool showSmartWatchBadge;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget card = FitXCard(
      padding: const EdgeInsets.all(spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    if (showSmartWatchBadge)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.watch,
                              color: primaryColor,
                              size: 8,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'قريباً',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                  color: isDisabled
                      ? surfaceColorLight
                      : primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  icon,
                  color: isDisabled ? textTertiary : primaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: spaceSm + spaceXs),
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
                        color: isDisabled ? textTertiary : textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: spaceXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDisabled ? surfaceColorLight : primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        unit,
                        style: TextStyle(
                          color: isDisabled ? textTertiary : const Color(0xFF1A1A00),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showChart && !isDisabled)
                SizedBox(
                  width: 60,
                  height: 36,
                  child: hasBarChart ? _SmallBars() : _SmallLine(),
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

class _SmallBars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final v = [0.5, 0.8, 0.3, 0.9, 1.0, 0.6];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: v
          .map((h) => Container(
                width: 5,
                height: 32 * h,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ))
          .toList(),
    );
  }
}

class _SmallLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(55, 32),
      painter: _SmallLinePainter(),
    );
  }
}

class _SmallLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = [0.4, 0.7, 0.3, 0.6, 0.2, 0.5, 0.7];
    final dx = size.width / (points.length - 1);
    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
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

// ═══════════════════════════════════════════════════════════════
//  WORKOUT CHART PAINTER — Smooth dual-line chart
// ═══════════════════════════════════════════════════════════════
class _WorkoutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = surfaceBorder
      ..strokeWidth = 0.5;

    for (var i = 0; i < 4; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint..style = PaintingStyle.stroke,
      );
    }

    // Line paint
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Data
    final data = [0.3, 0.6, 0.4, 0.8, 0.9, 0.5, 0.7, 0.6];
    final dx = size.width / (data.length - 1);
    final path = Path();

    for (var i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height * (1 - data[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * dx;
        final prevY = size.height * (1 - data[i - 1]);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Fill gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withValues(alpha: 0.15),
        primaryColor.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(fillPath, fillPaint);

    // Accent dot on peak
    final dotIndex = data.indexOf(data.reduce((a, b) => a > b ? a : b));
    final dotX = dotIndex * dx;
    final dotY = size.height * (1 - data[dotIndex]);

    canvas.drawCircle(
      Offset(dotX, dotY),
      5,
      Paint()..color = primaryColor,
    );
    canvas.drawCircle(
      Offset(dotX, dotY),
      3,
      Paint()..color = bgColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
