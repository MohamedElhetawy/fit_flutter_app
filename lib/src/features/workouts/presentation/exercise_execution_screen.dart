import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import '../../../shared/widgets/fitx_card.dart';
import '../data/exercise.dart';
import '../providers/exercise_execution_providers.dart';
import '../providers/knn_providers.dart';
import '../providers/workout_session_provider.dart';
import 'workout_stats_screen.dart';

/// Premium Exercise Execution Screen - Workout Player
/// Features: GIF visualizer, set/rep logging, circular rest timer
class ExerciseExecutionScreen extends ConsumerStatefulWidget {
  const ExerciseExecutionScreen({
    super.key,
    required this.exercise,
  });

  final Exercise exercise;

  @override
  ConsumerState<ExerciseExecutionScreen> createState() =>
      _ExerciseExecutionScreenState();
}

class _ExerciseExecutionScreenState
    extends ConsumerState<ExerciseExecutionScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start workout session if not active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(workoutSessionProvider);
      if (session == null || !session.isActive) {
        ref.read(workoutSessionProvider.notifier).startWorkout(
          muscleGroup: widget.exercise.muscleGroup,
        );
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _logSet() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      _showError('ادخل وزن وعدد تكرارات صحيحة');
      return;
    }

    // Add set using Riverpod
    ref.read(loggedSetsProvider.notifier).addSet(weight, reps);

    // Add to workout session
    ref.read(workoutSessionProvider.notifier).addSet(
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.nameAr,
      weight: weight,
      reps: reps,
    );

    // Clear inputs
    _weightController.clear();
    _repsController.clear();

    // Start rest timer
    ref.read(restTimerProvider.notifier).start(seconds: 60);

    // Show success
    _showSuccess('تم تسجيل المجموعة');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final timerState = ref.watch(restTimerProvider);
    final timerNotifier = ref.read(restTimerProvider.notifier);
    final setsState = ref.watch(loggedSetsProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor.withAlpha(204),
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          // Stats Button
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(230),
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            child: IconButton(
              icon: const Icon(Icons.analytics, color: Colors.black, size: 20),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutStatsScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══════════════════════════════════════════════════════════════
            // TOP SECTION - GIF VISUALIZER (40% of screen)
            // ═══════════════════════════════════════════════════════════════
            SizedBox(
              height: screenHeight * 0.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // GIF Image
                  Image.network(
                    exercise.gifUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 600, // Optimize for exercise GIF
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_off_outlined,
                              size: 48,
                              color: textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'صورة التمرين غير متوفرة',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Gradient Overlay (Black to Transparent)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            bgColor,
                            bgColor.withAlpha(204),
                            bgColor.withAlpha(102),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Exercise Name Overlay
                  Positioned(
                    bottom: defaultPadding,
                    left: defaultPadding,
                    right: defaultPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.displayName,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: spaceXs),
                        Row(
                          children: [
                            _buildSubtitleBadge(exercise.muscleGroup),
                            const SizedBox(width: spaceSm),
                            _buildSubtitleBadge(exercise.equipment),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // INPUT SECTION
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Glassmorphic Input Row
                  Row(
                    children: [
                      // Weight Input
                      Expanded(
                        child: _buildGlassInput(
                          controller: _weightController,
                          label: 'الوزن (كجم)',
                          hint: '0.0',
                          icon: Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: spaceMd),
                      // Reps Input
                      Expanded(
                        child: _buildGlassInput(
                          controller: _repsController,
                          label: 'العدات',
                          hint: '0',
                          icon: Icons.repeat,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: spaceLg),

                  // ═════════════════════════════════════════════════════════
                  // ACTION BUTTON - Neon Yellow
                  // ═════════════════════════════════════════════════════════
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _logSet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: const Color(0xFF1A1A00),
                        elevation: 8,
                        shadowColor: primaryColor.withAlpha(102),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radiusLg),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: spaceMd),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 24),
                          SizedBox(width: spaceSm),
                          Text(
                            'تسجيل المجموعة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: spaceLg),

                  // ═════════════════════════════════════════════════════════
                  // K-NN SMART RECOMMENDATIONS
                  // ═════════════════════════════════════════════════════════
                  _buildKNNRecommendation(),

                  const SizedBox(height: spaceLg),

                  // ═════════════════════════════════════════════════════════
                  // REST TIMER - Circular Progress
                  // ═════════════════════════════════════════════════════════
                  if (timerState.isRunning)
                    FitXCard(
                      accentGlow: true,
                      child: Column(
                        children: [
                          const Text(
                            'وقت الراحة',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: spaceMd),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Circular Timer
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Background Circle
                                    const CircularProgressIndicator(
                                      value: 1,
                                      strokeWidth: 8,
                                      backgroundColor: surfaceBorder,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        surfaceBorder,
                                      ),
                                    ),
                                    // Progress Circle
                                    CircularProgressIndicator(
                                      value: timerState.progress,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.transparent,
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        primaryColor,
                                      ),
                                      strokeCap: StrokeCap.round,
                                    ),
                                    // Timer Text
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            timerState.formattedTime,
                                            style: const TextStyle(
                                              color: textPrimary,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: grandisExtendedFont,
                                            ),
                                          ),
                                          Text(
                                            'ثانية',
                                            style: TextStyle(
                                              color: textSecondary.withAlpha(179),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: spaceMd),
                          // Timer Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Reset Button
                              _buildTimerButton(
                                icon: Icons.refresh,
                                onTap: () => timerNotifier.reset(seconds: 60),
                                label: 'إعادة',
                              ),
                              const SizedBox(width: spaceLg),
                              // Play/Pause Button
                              _buildTimerButton(
                                icon: timerState.isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                onTap: () {
                                  if (timerState.isPaused) {
                                    timerNotifier.resume();
                                  } else {
                                    timerNotifier.pause();
                                  }
                                },
                                label: timerState.isPaused ? 'استئناف' : 'إيقاف',
                                isPrimary: true,
                              ),
                              const SizedBox(width: spaceLg),
                              // Stop Button
                              _buildTimerButton(
                                icon: Icons.stop,
                                onTap: () => timerNotifier.stop(),
                                label: 'إنهاء',
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    // Timer Not Running - Quick Start Options
                    FitXCard(
                      child: Column(
                        children: [
                          const Text(
                            'بدء وقت راحة',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: spaceMd),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickTimerButton(30, timerNotifier),
                              _buildQuickTimerButton(60, timerNotifier),
                              _buildQuickTimerButton(90, timerNotifier),
                              _buildQuickTimerButton(120, timerNotifier),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: spaceXl),

                  // ═════════════════════════════════════════════════════════
                  // HISTORY LIST - Today's Logged Sets
                  // ═════════════════════════════════════════════════════════
                  if (setsState.sets.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'سجل التمارين',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${setsState.sets.length} مجموعات',
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: spaceMd),
                    ...setsState.sets.asMap().entries.map((entry) {
                      return _buildHistoryCard(entry.value, entry.key);
                    }),
                  ],

                  // Session Stats (if sets exist)
                  if (setsState.sets.isNotEmpty) ...[
                    const SizedBox(height: spaceLg),
                    FitXCard(
                      color: surfaceColorLight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                            'الحجم الكلي',
                            '${ref.read(loggedSetsProvider.notifier).totalVolume.toStringAsFixed(0)} كجم',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: surfaceBorder,
                          ),
                          _buildStat(
                            'إجمالي التكرارات',
                            '${ref.read(loggedSetsProvider.notifier).totalReps}',
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: spaceXxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitleBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(51),
        borderRadius: BorderRadius.circular(radiusSm),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: surfaceBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: grandisExtendedFont,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: textSecondary,
            fontSize: 12,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: textTertiary.withAlpha(128),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(icon, color: textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(spaceMd),
        ),
      ),
    );
  }

  Widget _buildTimerButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPrimary
                  ? primaryColor.withAlpha(51)
                  : surfaceColorLight,
              borderRadius: BorderRadius.circular(radiusMd),
              border: Border.all(
                color: isPrimary ? primaryColor : surfaceBorder,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isPrimary ? primaryColor : textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isPrimary ? primaryColor : textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimerButton(int seconds, RestTimerNotifier notifier) {
    return GestureDetector(
      onTap: () => notifier.start(seconds: seconds),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
        decoration: BoxDecoration(
          color: surfaceColorLight,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(color: surfaceBorder),
        ),
        child: Text(
          '$seconds"',
          style: const TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(LoggedSet set, int index) {
    return FitXCard(
      margin: const EdgeInsets.only(bottom: spaceSm),
      color: surfaceColorLight,
      child: Row(
        children: [
          // Set Number Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withAlpha(77),
                  primaryColor.withAlpha(26),
                ],
              ),
              borderRadius: BorderRadius.circular(radiusSm),
              border: Border.all(
                color: primaryColor.withAlpha(77),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                _toArabicNumber(set.setNumber),
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: spaceMd),
          // Set Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_toArabicNumber(set.reps)} عدة × ${_toArabicNumber(set.weight.toInt())} كجم',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الحجم: ${_toArabicNumber((set.weight * set.reps).toInt())} كجم',
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Time
          Text(
            '${set.timestamp.hour.toString().padLeft(2, '0')}:${set.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: spaceSm),
          // Delete button
          GestureDetector(
            onTap: () {
              ref.read(loggedSetsProvider.notifier).removeSet(index);
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: errorColor.withAlpha(26),
                borderRadius: BorderRadius.circular(radiusXs),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: errorColor,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // K-NN SMART RECOMMENDATIONS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildKNNRecommendation() {
    final weightText = _weightController.text;
    final repsText = _repsController.text;
    final weight = double.tryParse(weightText) ?? 0;
    final reps = int.tryParse(repsText) ?? 0;

    // Only show if user has entered some data
    if (weight <= 0 || reps <= 0) {
      return _buildInitialRecommendation();
    }

    return _buildPerformanceComparison(weight, reps);
  }

  /// Show initial recommendation from similar users
  Widget _buildInitialRecommendation() {
    final recommendationAsync = ref.watch(
      exerciseRecommendationBackendProvider(widget.exercise),
    );

    return recommendationAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (recommendation) {
        if (recommendation == null) return const SizedBox.shrink();

        return FitXCard(
          accentGlow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(radiusSm),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: spaceSm),
                  const Expanded(
                    child: Text(
                      'توصية ذكية بناءً على المستخدمين المشابهين',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spaceMd),
              Text(
                'المستخدمون مثل ${recommendation.similarUsers.map((u) => u.name).join('، ')} يبدأون بـ:',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: spaceSm),
              Row(
                children: [
                  _buildRecBadge(
                    '${recommendation.recommendedWeight.toStringAsFixed(1)} كجم',
                    Icons.fitness_center,
                  ),
                  const SizedBox(width: spaceSm),
                  _buildRecBadge(
                    '${recommendation.recommendedReps} عدة',
                    Icons.repeat,
                  ),
                  const SizedBox(width: spaceSm),
                  _buildRecBadge(
                    '${recommendation.recommendedSets} مجموعات',
                    Icons.format_list_numbered,
                  ),
                ],
              ),
              if (recommendation.confidence > 0.5) ...[
                const SizedBox(height: spaceSm),
                Text(
                  'نسبة الثقة: ${(recommendation.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: successColor.withAlpha(204),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Show performance comparison after user logs a set
  Widget _buildPerformanceComparison(double weight, int reps) {
    final comparisonAsync = ref.watch(
      performanceComparisonBackendProvider((widget.exercise, weight, reps)),
    );

    final suggestionAsync = ref.watch(
      weightSuggestionBackendProvider((widget.exercise, weight, reps)),
    );

    return comparisonAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (comparison) {
        if (comparison == null) return const SizedBox.shrink();

        return FitXCard(
          color: comparison.isBetter
              ? successColor.withAlpha(26)
              : surfaceColorLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    comparison.isBetter ? Icons.trending_up : Icons.info_outline,
                    color: comparison.isBetter ? successColor : primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: spaceSm),
                  Expanded(
                    child: Text(
                      comparison.message,
                      style: TextStyle(
                        color: comparison.isBetter ? successColor : textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // Suggestion from similar users
          suggestionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (suggestion) {
              if (suggestion == null || suggestion.confidence <= 0.5) {
                return const SizedBox.shrink();
              }
              
              return Column(
                children: [
                  const SizedBox(height: spaceMd),
                  const Divider(color: surfaceBorder),
                  const SizedBox(height: spaceSm),
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: spaceSm),
                      Expanded(
                        child: Text(
                          '💡 المجموعة الجاية: جرب ${suggestion.suggestedWeight.toStringAsFixed(1)} كجم',
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildRecBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(color: surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primaryColor, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: grandisExtendedFont,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Convert numbers to Arabic numerals
  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      if (index != null && index >= 0 && index <= 9) {
        return arabicDigits[index];
      }
      return digit;
    }).join();
  }
}
