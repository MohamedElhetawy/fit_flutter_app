import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/config/app_config.dart';
import 'package:fitx/src/core/config/app_config_provider.dart';
import 'package:fitx/src/features/workouts/presentation/super_admin_workout_cms.dart';

class SuperAdminControlScreen extends ConsumerWidget {
  const SuperAdminControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config =
        ref.watch(appConfigProvider).value ?? const AppConfig.defaults();
    final saving = ref.watch(appConfigControllerProvider).isLoading;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Super Admin Studio'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Theming Studio'),
              Tab(text: 'Workout CMS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(defaultPadding),
              children: [
                Text('Primary theme color',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ColorButton(0xFF7B61FF, config, ref),
                    _ColorButton(0xFF1DB954, config, ref),
                    _ColorButton(0xFFFA541C, config, ref),
                    _ColorButton(0xFF0EA5E9, config, ref),
                  ],
                ),
                const SizedBox(height: defaultPadding),
                SwitchListTile(
                  title: const Text('Enable step tracking widgets'),
                  value: config.enableSteps,
                  onChanged: (value) {
                    ref.read(appConfigControllerProvider.notifier).updateConfig(
                          AppConfig(
                            primaryColorValue: config.primaryColorValue,
                            enableSteps: value,
                            enableWorkoutRecommendations:
                                config.enableWorkoutRecommendations,
                            typographyScale: config.typographyScale,
                            spacingScale: config.spacingScale,
                            cardRadius: config.cardRadius,
                            showNutritionSection: config.showNutritionSection,
                          ),
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('Enable workout recommendation widgets'),
                  value: config.enableWorkoutRecommendations,
                  onChanged: (value) {
                    ref.read(appConfigControllerProvider.notifier).updateConfig(
                          AppConfig(
                            primaryColorValue: config.primaryColorValue,
                            enableSteps: config.enableSteps,
                            enableWorkoutRecommendations: value,
                            typographyScale: config.typographyScale,
                            spacingScale: config.spacingScale,
                            cardRadius: config.cardRadius,
                            showNutritionSection: config.showNutritionSection,
                          ),
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('Show nutrition section'),
                  value: config.showNutritionSection,
                  onChanged: (value) {
                    ref.read(appConfigControllerProvider.notifier).updateConfig(
                          AppConfig(
                            primaryColorValue: config.primaryColorValue,
                            enableSteps: config.enableSteps,
                            enableWorkoutRecommendations:
                                config.enableWorkoutRecommendations,
                            typographyScale: config.typographyScale,
                            spacingScale: config.spacingScale,
                            cardRadius: config.cardRadius,
                            showNutritionSection: value,
                          ),
                        );
                  },
                ),
                ListTile(
                  title: const Text('Typography scale'),
                  subtitle: Slider(
                    min: 0.85,
                    max: 1.35,
                    value: config.typographyScale,
                    onChanged: (v) {
                      ref
                          .read(appConfigControllerProvider.notifier)
                          .updateConfig(
                            AppConfig(
                              primaryColorValue: config.primaryColorValue,
                              enableSteps: config.enableSteps,
                              enableWorkoutRecommendations:
                                  config.enableWorkoutRecommendations,
                              typographyScale: v,
                              spacingScale: config.spacingScale,
                              cardRadius: config.cardRadius,
                              showNutritionSection: config.showNutritionSection,
                            ),
                          );
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Card radius'),
                  subtitle: Slider(
                    min: 4,
                    max: 28,
                    value: config.cardRadius,
                    onChanged: (v) {
                      ref
                          .read(appConfigControllerProvider.notifier)
                          .updateConfig(
                            AppConfig(
                              primaryColorValue: config.primaryColorValue,
                              enableSteps: config.enableSteps,
                              enableWorkoutRecommendations:
                                  config.enableWorkoutRecommendations,
                              typographyScale: config.typographyScale,
                              spacingScale: config.spacingScale,
                              cardRadius: v,
                              showNutritionSection: config.showNutritionSection,
                            ),
                          );
                    },
                  ),
                ),
                if (saving) const LinearProgressIndicator(),
              ],
            ),
            const SuperAdminWorkoutCms(),
          ],
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton(this.colorValue, this.config, this.ref);

  final int colorValue;
  final AppConfig config;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ref.read(appConfigControllerProvider.notifier).updateConfig(
              AppConfig(
                primaryColorValue: colorValue,
                enableSteps: config.enableSteps,
                enableWorkoutRecommendations:
                    config.enableWorkoutRecommendations,
                typographyScale: config.typographyScale,
                spacingScale: config.spacingScale,
                cardRadius: config.cardRadius,
                showNutritionSection: config.showNutritionSection,
              ),
            );
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
          border: Border.all(
            color: config.primaryColorValue == colorValue
                ? Colors.black
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
