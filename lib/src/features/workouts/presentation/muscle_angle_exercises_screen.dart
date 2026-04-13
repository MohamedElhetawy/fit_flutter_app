import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import '../../../shared/widgets/fitx_card.dart';
import '../../../shared/widgets/fitx_shimmer.dart';
import '../data/exercise.dart';
import '../providers/exercise_providers.dart';
import 'exercise_execution_screen.dart';

/// Muscle Angle Exercises Screen (Level 3)
/// Shows exercises for a specific muscle angle
class MuscleAngleExercisesScreen extends ConsumerWidget {
  const MuscleAngleExercisesScreen({
    super.key,
    required this.muscleGroup,
    required this.muscleAngle,
  });

  final MuscleGroup muscleGroup;
  final MuscleAngle muscleAngle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(
      exercisesByGroupAndAngleProvider((
        muscleGroup: muscleGroup.nameEn,
        muscleAngle: muscleAngle.nameEn,
      )),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              muscleGroup.nameAr,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              muscleAngle.nameAr,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: exercisesAsync.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(defaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: spaceMd,
            mainAxisSpacing: spaceMd,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => const FitXShimmerCard(height: 200),
        ),
        error: (_, __) => const Center(
          child: Text(
            'فشل تحميل التمارين',
            style: TextStyle(color: errorColor),
          ),
        ),
        data: (exercises) {
          if (exercises.isEmpty) {
            return const _EmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: spaceMd,
              mainAxisSpacing: spaceMd,
            ),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return _ExerciseCard(
                exercise: exercise,
                onTap: () => _navigateToExecution(context, exercise),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToExecution(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseExecutionScreen(exercise: exercise),
      ),
    );
  }
}

/// Exercise Card
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FitXCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise GIF
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(radiusLg),
              ),
              child: Image.network(
                exercise.gifUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: surfaceColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: surfaceColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_off_outlined,
                        color: textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.nameAr.substring(0, exercise.nameAr.length > 15 ? 15 : exercise.nameAr.length),
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Exercise Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exercise.displayName,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      _buildBadge(exercise.equipment, primaryColor),
                      const SizedBox(width: 4),
                      _buildBadge(exercise.difficulty, successColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Empty State
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            color: textTertiary,
            size: 56,
          ),
          SizedBox(height: spaceMd),
          Text(
            'لا توجد تمارين',
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
