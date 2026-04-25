import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import '../../../shared/widgets/fitx_card.dart';
import '../../../shared/widgets/fitx_shimmer.dart';
import '../providers/workout_session_provider.dart';
import '../providers/knn_providers.dart';
import '../providers/user_repository_providers.dart';

/// Smart Workout Stats Screen
/// Shows workout summary + K-NN insights
class WorkoutStatsScreen extends ConsumerWidget {
  const WorkoutStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final statsAsync = ref.watch(knnStatsBackendProvider);

    if (session == null) {
      return _buildEmptyState(context);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: bgColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'ملخص التمرين',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withAlpha(51),
                      bgColor,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.analytics,
                    size: 64,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(defaultPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 🏆 Main Stats Cards
                _buildMainStatsGrid(session),

                const SizedBox(height: spaceLg),

                // 🧠 K-NN Smart Insights
                _buildKNNInsights(session, ref),

                const SizedBox(height: spaceLg),

                // 📊 Community Stats
                statsAsync.when(
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (stats) => _buildCommunityStats(stats),
                ),

                const SizedBox(height: spaceLg),

                // 🎯 Exercises Breakdown
                _buildExercisesBreakdown(session),

                const SizedBox(height: spaceLg),

                // 💡 Smart Recommendations
                _buildSmartRecommendations(session, ref),

                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, session),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: textSecondary.withAlpha(128),
            ),
            const SizedBox(height: spaceLg),
            const Text(
              'لا يوجد تمرين نشط',
              style: TextStyle(
                color: textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: spaceMd),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة للتمارين'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatsGrid(WorkoutSession session) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: spaceMd,
      crossAxisSpacing: spaceMd,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          icon: Icons.fitness_center,
          value: '${session.totalSets}',
          label: 'المجموعات',
          color: primaryColor,
        ),
        _buildStatCard(
          icon: Icons.local_fire_department,
          value: session.totalVolume.toStringAsFixed(0),
          label: 'الحجم الكلي (كجم)',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.timer,
          value: _formatDuration(session.duration),
          label: 'المدة',
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          value: '${session.totalExercises}',
          label: 'التمارين',
          color: successColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return FitXCard(
      accentGlow: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: spaceSm),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: grandisExtendedFont,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKNNInsights(WorkoutSession session, WidgetRef ref) {
    final percentileAsync = ref.watch(volumePercentileProvider);

    return FitXCard(
      accentGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: primaryColor),
              SizedBox(width: spaceSm),
              Text(
                'تحليل K-NN الذكي',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),

          // Volume Comparison with REAL percentile
          if (session.totalVolume > 0)
            percentileAsync.when(
              data: (percentile) => _buildInsightRow(
                icon: Icons.bar_chart,
                title: 'حجم التمرين',
                subtitle: 'أنت في أعلى $percentile% من المستخدمين المشابهين',
                color: successColor,
              ),
              loading: () => const SizedBox(
                height: 20,
                child: FitXShimmer(height: 20, width: 200),
              ),
              error: (_, __) => _buildInsightRow(
                icon: Icons.bar_chart,
                title: 'حجم التمرين',
                subtitle:
                    'أنت في أعلى ${_calculateVolumePercentile(session)}% من المستخدمين المشابهين',
                color: successColor,
              ),
            ),

          const SizedBox(height: spaceSm),

          // Intensity Analysis
          _buildInsightRow(
            icon: Icons.speed,
            title: 'شدة التمرين',
            subtitle: _getIntensityText(session),
            color: Colors.orange,
          ),

          const SizedBox(height: spaceSm),

          // Progress Indicator
          _buildInsightRow(
            icon: Icons.trending_up,
            title: 'التقدم',
            subtitle:
                'أفضل 1RM: ${session.bestOneRepMax.toStringAsFixed(1)} كجم',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityStats(Map<String, dynamic> stats) {
    final totalUsers = stats['totalUsers'] as int? ?? 0;
    final beginnerCount = stats['beginnerCount'] as int? ?? 0;
    final intermediateCount = stats['intermediateCount'] as int? ?? 0;
    final advancedCount = stats['advancedCount'] as int? ?? 0;

    return FitXCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👥 المجتمع',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: spaceMd),
          Text(
            '$totalUsers مستخدم نشط في K-NN',
            style: const TextStyle(color: textSecondary, fontSize: 13),
          ),
          const SizedBox(height: spaceSm),
          Row(
            children: [
              _buildLevelBadge('مبتدئ', beginnerCount, Colors.green),
              const SizedBox(width: spaceSm),
              _buildLevelBadge('متوسط', intermediateCount, Colors.orange),
              const SizedBox(width: spaceSm),
              _buildLevelBadge('متقدم', advancedCount, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExercisesBreakdown(WorkoutSession session) {
    final exercises = session.setsByExercise;

    if (exercises.isEmpty) {
      return const SizedBox.shrink();
    }

    return FitXCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 تفاصيل التمارين',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: spaceMd),
          ...exercises.entries.map((entry) {
            final sets = entry.value;
            final volume = sets.fold(0.0, (sum, s) => sum + s.volume);
            return _buildExerciseRow(
              name: sets.first.exerciseName,
              sets: sets.length,
              volume: volume,
              avgWeight:
                  sets.fold(0.0, (sum, s) => sum + s.weight) / sets.length,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseRow({
    required String name,
    required int sets,
    required double volume,
    required double avgWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spaceSm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$sets مجموعات',
              style: const TextStyle(color: textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${volume.toStringAsFixed(0)} كجم',
              style: const TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartRecommendations(WorkoutSession session, WidgetRef ref) {
    return FitXCard(
      color: surfaceColorLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: primaryColor),
              SizedBox(width: spaceSm),
              Text(
                '💡 توصيات ذكية',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),
          _buildRecommendationItem(
            'استراحة بين المجموعات: 60-90 ثانية',
            Icons.timer,
          ),
          _buildRecommendationItem(
            'حاول زيادة الوزن 5% في التمرين الجاي',
            Icons.trending_up,
          ),
          _buildRecommendationItem(
            'ركز على النموذج الصحيح قبل زيادة الوزن',
            Icons.fitness_center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spaceSm),
      child: Row(
        children: [
          Icon(icon, color: textSecondary, size: 16),
          const SizedBox(width: spaceSm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, WidgetRef ref, WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(color: surfaceBorder),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (session.isActive) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(workoutSessionProvider.notifier).endWorkout();
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('إنهاء التمرين'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: spaceMd),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('العودة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: surfaceColorLight,
                  foregroundColor: textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const FitXShimmerCard(height: 150);
  }

  // Helper methods
  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _calculateVolumePercentile(WorkoutSession session) {
    // Placeholder - would use actual K-NN comparison
    return '75';
  }

  String _getIntensityText(WorkoutSession session) {
    final avgWeight = session.averageWeight;
    if (avgWeight > 80) return 'عالية جداً 🔥';
    if (avgWeight > 60) return 'عالية 💪';
    if (avgWeight > 40) return 'متوسطة';
    return 'منخفضة';
  }
}
