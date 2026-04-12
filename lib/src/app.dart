import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/core/config/app_config_provider.dart';
import 'package:fitx/src/core/routing/app_router.dart';
import 'package:fitx/theme/app_theme.dart';

class FitXApp extends ConsumerWidget {
  const FitXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final config = ref.watch(appConfigProvider).value;

    // Use dark theme as the primary theme
    final baseTheme = AppTheme.darkTheme(context);
    final scaledText = baseTheme.textTheme.apply(
      fontSizeFactor: config?.typographyScale ?? 1.0,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FitX',
      theme: baseTheme.copyWith(
        textTheme: scaledText,
        cardTheme: baseTheme.cardTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config?.cardRadius ?? 12),
          ),
        ),
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: config?.primaryColor ?? baseTheme.colorScheme.primary,
        ),
        primaryColor: config?.primaryColor ?? baseTheme.primaryColor,
      ),
      routerConfig: router,
    );
  }
}
