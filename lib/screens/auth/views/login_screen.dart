import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/theme/app_theme.dart';
import 'components/login_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ─── Ambient Glow Background ───────────────────
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ─── Main Content ──────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.08),

                  // ─── Animated Logo/Branding ───────────────
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0, 0.4),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
                      )),
                      child: Column(
                        children: [
                          Text(
                            'FitX',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: primaryColor,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 8),
                                  blurRadius: 16,
                                  color: primaryColor.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unleash Your Potential with Nerva X',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // ─── Welcome Text ──────────────────────────
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
                    )),
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log in to continue your fitness journey',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ─── Form Container with Glassmorphism ────
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.2, 0.7),
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1).animate(
                        CurvedAnimation(
                          parent: _animController,
                          curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: AppTheme.buildGlassmorphicContainer(
                        backgroundColor: surfaceColor,
                        opacity: 0.4,
                        borderRadius: BorderRadius.circular(radiusLg),
                        padding: const EdgeInsets.all(spaceLg),
                        child: LogInForm(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: spaceMd),

                  // ─── Forgot Password Link ──────────────────
                  Align(
                    child: TextButton(
                      onPressed: () => context.go('/forgot-password'),
                      child: Text(
                        'Forgot password?',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: spaceMd),

                  // ─── Continue Button ──────────────────────
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1).animate(
                      CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          if (_formKey.currentState!.validate()) {
                            await ref.read(authControllerProvider.notifier).signInWithEmail(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            final current = ref.read(authControllerProvider);
                            if (current.hasError) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(current.error.toString())),
                              );
                            } else {
                              if (!context.mounted) return;
                              context.go('/dashboard');
                            }
                          }
                        },
                        child: auth.isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1A1A00),
                            ),
                          ),
                        )
                            : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: spaceLg),

                  // ─── Divider ───────────────────────────────
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: surfaceBorder,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: spaceSm),
                        child: Text(
                          'or',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: surfaceBorder,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: spaceLg),

                  // ─── Social Login Buttons ──────────────────
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1).animate(
                      CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSocialLoginButton(
                          iconWidget: SvgPicture.asset(
                            'assets/icons/google_logo.svg',
                            width: 24,
                            height: 24,
                          ),
                          label: 'Continue with Google',
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final router = GoRouter.of(context);
                            await ref
                                .read(authControllerProvider.notifier)
                                .signInWithGoogle();
                            if (!mounted) return;
                            final current = ref.read(authControllerProvider);
                            if (current.hasError) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(current.error.toString()),
                                ),
                              );
                            } else {
                              router.go('/dashboard');
                            }
                          },
                        ),
                        if (!kIsWeb &&
                            (defaultTargetPlatform == TargetPlatform.android ||
                                defaultTargetPlatform == TargetPlatform.iOS))
                          const SizedBox(height: spaceSm),
                        if (!kIsWeb &&
                            (defaultTargetPlatform == TargetPlatform.android ||
                                defaultTargetPlatform == TargetPlatform.iOS))
                          _buildSocialLoginButton(
                            icon: '🍎',
                            label: 'Continue with Apple',
                            badge: 'قريباً',
                            onPressed: () {
                              // Apple Sign-In coming soon - show dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: surfaceColor,
                                  title: const Row(
                                    children: [
                                      Icon(Icons.apple, color: textPrimary),
                                      SizedBox(width: 8),
                                      Text('Apple Sign-In'),
                                    ],
                                  ),
                                  content: const Text(
                                    'ميزة تسجيل الدخول بـ Apple قيد التطوير حالياً و ستكون متاحة في التحديث القادم',
                                    style: TextStyle(color: textSecondary),
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
                            },
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ─── Sign Up Link ──────────────────────────
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.6, 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: Text(
                            'Sign up',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build social login buttons with consistent styling
  Widget _buildSocialLoginButton({
    String? icon,
    Widget? iconWidget,
    required String label,
    required VoidCallback? onPressed,
    String? badge,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: surfaceBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          backgroundColor: surfaceColor.withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null)
              iconWidget
            else if (icon != null)
              Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF1A1A00),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
