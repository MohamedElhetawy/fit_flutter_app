import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/shared/widgets/fitx_shimmer.dart';
import '../data/exercise.dart';
import '../providers/exercise_providers.dart';
import 'muscle_angles_screen.dart';

/// Workouts Screen - Level 1: Muscle Groups
/// Shows muscle group cards with network images
class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muscleGroupsAsync = ref.watch(muscleGroupsWithImagesProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  defaultPadding, spaceMd, defaultPadding, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مجموعات العضلات',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: spaceSm),
                    Text(
                      'اختر مجموعة العضلات لعرض التمارين',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Muscle Groups Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding, spaceLg, defaultPadding, spaceMd),
              sliver: muscleGroupsAsync.when(
                loading: () => SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: spaceMd,
                    mainAxisSpacing: spaceMd,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const FitXShimmerCard(height: 180),
                    childCount: 6,
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
                data: (muscleGroups) {
                  if (muscleGroups.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: _EmptyState(),
                    );
                  }

                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: spaceMd,
                      mainAxisSpacing: spaceMd,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final group = muscleGroups[index];
                        return _MuscleGroupCard(
                          muscleGroup: group,
                          onTap: () => _navigateToMuscleAngles(context, group),
                        );
                      },
                      childCount: muscleGroups.length,
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
      ),
    );
  }

  void _navigateToMuscleAngles(BuildContext context, MuscleGroup muscleGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuscleAnglesScreen(muscleGroup: muscleGroup),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MUSCLE GROUP CARD
// ═══════════════════════════════════════════════════════════════
class _MuscleGroupCard extends StatelessWidget {
  const _MuscleGroupCard({
    required this.muscleGroup,
    required this.onTap,
  });

  final MuscleGroup muscleGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Muscle Group Image
              Image.network(
                muscleGroup.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: surfaceColor,
                    child: const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: surfaceColor,
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: textSecondary,
                    ),
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      bgColor.withValues(alpha: 0.7),
                      bgColor.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        muscleGroup.nameAr,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(radiusXs),
                            ),
                            child: Text(
                              '${muscleGroup.exerciseCount} تمرين',
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow Icon
              Positioned(
                top: spaceMd,
                right: spaceMd,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(radiusFull),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: textPrimary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: spaceXxl * 2),
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
              'لا توجد مجموعات عضلات',
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
