import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import '../../../shared/widgets/fitx_card.dart';
import '../../../shared/widgets/fitx_shimmer.dart';
import '../data/exercise.dart';
import '../providers/exercise_providers.dart';
import 'muscle_angle_exercises_screen.dart';

/// Muscle Angles Screen (Level 2)
/// Shows muscle angles for a selected muscle group
class MuscleAnglesScreen extends ConsumerWidget {
  const MuscleAnglesScreen({
    super.key,
    required this.muscleGroup,
  });

  final MuscleGroup muscleGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muscleAnglesAsync = ref.watch(muscleAnglesForGroupProvider(muscleGroup.nameEn));

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Image Section
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Muscle Group Image
                Image.network(
                  muscleGroup.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: surfaceColor,
                      child: const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: surfaceColor,
                    child: const Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          bgColor,
                          bgColor.withOpacity(0.8),
                          bgColor.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Title
                Positioned(
                  bottom: defaultPadding,
                  left: defaultPadding,
                  right: defaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        muscleGroup.nameAr,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: spaceXs),
                      Text(
                        '${muscleGroup.exerciseCount} تمرين متاح',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Muscle Angles Grid
          SliverPadding(
            padding: const EdgeInsets.all(defaultPadding),
            sliver: muscleAnglesAsync.when(
              loading: () => SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: spaceMd,
                  mainAxisSpacing: spaceMd,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const FitXShimmerCard(height: 150),
                  childCount: 4,
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    'فشل تحميل البيانات',
                    style: TextStyle(color: errorColor),
                  ),
                ),
              ),
              data: (muscleAngles) {
                if (muscleAngles.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: _EmptyState(),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: spaceMd,
                    mainAxisSpacing: spaceMd,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final angle = muscleAngles[index];
                      return _MuscleAngleCard(
                        muscleAngle: angle,
                        onTap: () => _navigateToExercises(context, angle),
                      );
                    },
                    childCount: muscleAngles.length,
                  ),
                );
              },
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
          ),
        ],
      ),
    );
  }

  void _navigateToExercises(BuildContext context, MuscleAngle muscleAngle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuscleAngleExercisesScreen(
          muscleGroup: muscleGroup,
          muscleAngle: muscleAngle,
        ),
      ),
    );
  }
}

/// Muscle Angle Card
class _MuscleAngleCard extends StatelessWidget {
  const _MuscleAngleCard({
    required this.muscleAngle,
    required this.onTap,
  });

  final MuscleAngle muscleAngle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FitXCard(
      onTap: onTap,
      padding: const EdgeInsets.all(spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.3),
                  primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: primaryColor,
              size: 24,
            ),
          ),
          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                muscleAngle.nameAr,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${muscleAngle.exerciseCount} تمرين',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Empty State
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: spaceXxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              color: textTertiary,
              size: 56,
            ),
            SizedBox(height: spaceMd),
            Text(
              'لا توجد زوايا متاحة',
              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
