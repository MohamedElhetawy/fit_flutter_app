import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/theme/app_theme.dart';

import '../../../constants.dart';

/// Premium Sign Up Screen - Dark theme matching Login design
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى الموافقة على شروط الخدمة')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    await ref.read(authControllerProvider.notifier).signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    
    final current = ref.read(authControllerProvider);
    if (current.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(current.error.toString())),
      );
    } else {
      if (!mounted) return;
      context.go('/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ─── Ambient Glow Background ───────────────────
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withAlpha(20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withAlpha(15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ─── Main Content ──────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.04),

                    // ─── Back Button & Logo ──────────────────
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0, 0.4),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(radiusSm),
                                border: Border.all(color: surfaceBorder, width: 1),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: textSecondary,
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Image.asset(
                                'assets/logo/Fit_X_Logo.png',
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 44), // Balance
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // ─── Welcome Text ──────────────────────────
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0.1, 0.5),
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animController,
                          curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
                        )),
                        child: Column(
                          children: [
                            const Text(
                              'إنشاء حساب جديد',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'انضم إلى FitX وابدأ رحلتك اللياقة البدنية',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // ─── Form Container ──────────────────────
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0.2, 0.6),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1).animate(
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Full Name
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'الاسم الكامل',
                                  hint: 'محمد أحمد',
                                  icon: Icons.person_outline,
                                  validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال الاسم' : null,
                                ),
                                const SizedBox(height: spaceMd),

                                // Email
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'البريد الإلكتروني',
                                  hint: 'example@email.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v?.isEmpty ?? true) return 'يرجى إدخال البريد الإلكتروني';
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v!)) {
                                      return 'يرجى إدخال بريد صالح';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: spaceMd),

                                // Password
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'كلمة المرور',
                                  hint: '********',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: textSecondary,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v?.isEmpty ?? true) return 'يرجى إدخال كلمة المرور';
                                    if (v!.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: spaceMd),

                                // Confirm Password
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: 'تأكيد كلمة المرور',
                                  hint: '********',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscureConfirmPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      color: textSecondary,
                                    ),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                  validator: (v) {
                                    if (v != _passwordController.text) {
                                      return 'كلمات المرور غير متطابقة';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: spaceMd),

                    // ─── Terms Checkbox ──────────────────────
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0.4, 0.8),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                            activeColor: primaryColor,
                            checkColor: const Color(0xFF1A1A00),
                            side: const BorderSide(color: surfaceBorder),
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'أوافق على ',
                                style: const TextStyle(color: textSecondary, fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: 'شروط الخدمة',
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _showComingSoonDialog('الشروط والأحكام'),
                                  ),
                                  const TextSpan(
                                    text: ' و ',
                                    style: TextStyle(color: textSecondary),
                                  ),
                                  TextSpan(
                                    text: 'سياسة الخصوصية',
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _showComingSoonDialog('سياسة الخصوصية'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: spaceMd),

                    // ─── Sign Up Button ────────────────────────
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1).animate(
                        CurvedAnimation(
                          parent: _animController,
                          curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: const Color(0xFF1A1A00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radiusMd),
                            ),
                            elevation: 0,
                          ),
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
                                  'إنشاء الحساب',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: spaceLg),

                    // ─── Social Sign Up ────────────────────────
                    if (!kIsWeb &&
                        (defaultTargetPlatform == TargetPlatform.android ||
                            defaultTargetPlatform == TargetPlatform.iOS))
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _animController,
                          curve: const Interval(0.6, 1),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Expanded(child: Divider(color: surfaceBorder)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: spaceSm),
                                  child: Text(
                                    'أو',
                                    style: TextStyle(color: textTertiary, fontSize: 13),
                                  ),
                                ),
                                Expanded(child: Divider(color: surfaceBorder)),
                              ],
                            ),
                            const SizedBox(height: spaceLg),
                            _buildSocialButton(
                              icon: '🔵',
                              label: 'التسجيل بـ Google',
                              onPressed: auth.isLoading
                                  ? null
                                  : () async {
                                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                                      final router = GoRouter.of(context);
                                      await ref.read(authControllerProvider.notifier).signInWithGoogleMobile();
                                      if (!mounted) return;
                                      final current = ref.read(authControllerProvider);
                                      if (current.hasError) {
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(content: Text(current.error.toString())),
                                        );
                                      } else {
                                        router.go('/dashboard');
                                      }
                                    },
                            ),
                            const SizedBox(height: spaceSm),
                            _buildSocialButton(
                              icon: '🍎',
                              label: 'التسجيل بـ Apple',
                              badge: 'قريباً',
                              onPressed: () => _showComingSoonDialog('Apple Sign-In'),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: spaceLg),

                    // ─── Login Link ────────────────────────────
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0.7, 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'لديك حساب بالفعل؟',
                            style: TextStyle(color: textSecondary),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(color: textTertiary),
        filled: true,
        fillColor: surfaceColorLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: errorColor),
        ),
        prefixIcon: Icon(icon, color: textSecondary),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceMd),
      ),
      validator: validator,
    );
  }

  Widget _buildSocialButton({
    required String icon,
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
          backgroundColor: surfaceColor.withAlpha(128),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.construction, color: primaryColor),
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
}
