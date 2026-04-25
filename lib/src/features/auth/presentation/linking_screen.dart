import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/app_role.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/// Linking Screen - بعد اختيار الدور
/// بيسأل: هل انت تابع لـ؟ (جيم / مدرب / بنفسك)
class LinkingScreen extends ConsumerStatefulWidget {
  final AppRole selectedRole;

  const LinkingScreen({super.key, required this.selectedRole});

  @override
  ConsumerState<LinkingScreen> createState() => _LinkingScreenState();
}

class _LinkingScreenState extends ConsumerState<LinkingScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ربط الحساب',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختار طريقة الربط',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: spaceSm),
                  const Text(
                    'هل انت تابع لجيم معين أو مدرب؟',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: spaceLg),

                  // 3 Cards for linking options
                  _LinkingCard(
                    title: 'تابع لجيم',
                    subtitle: 'ادخل كود الجيم للانضمام',
                    icon: Icons.business,
                    gradient: const [Color(0xFF4A5568), Color(0xFF718096)],
                    onTap:
                        _isLoading ? () {} : () => _navigateToGymCode(context),
                  ),
                  const SizedBox(height: spaceMd),

                  _LinkingCard(
                    title: 'تابع لمدرب',
                    subtitle: 'ادخل كود المدرب مباشرة',
                    icon: Icons.school,
                    gradient: const [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
                    onTap: _isLoading
                        ? () {}
                        : () => _navigateToTrainerCode(context, null),
                  ),
                  const SizedBox(height: spaceMd),

                  _LinkingCard(
                    title: 'مستقل (بدون)',
                    subtitle: 'استخدم التطبيق بشكل مستقل',
                    icon: Icons.person_outline,
                    gradient: const [Color(0xFF805AD5), Color(0xFFB794F6)],
                    onTap: _isLoading
                        ? () {}
                        : () => _completeAsIndependent(context),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: bgColor.withAlpha(179),
              child: const Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToGymCode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GymCodeScreen(
          selectedRole: widget.selectedRole,
          onGymLinked: (gymId, gymName) {
            // بعد ربط الجيم، اسأل عن المدرب
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TrainerQuestionScreen(
                  gymId: gymId,
                  gymName: gymName,
                  selectedRole: widget.selectedRole,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToTrainerCode(BuildContext context, String? gymId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TrainerCodeScreen(
          gymId: gymId,
          selectedRole: widget.selectedRole,
        ),
      ),
    );
  }

  Future<void> _completeAsIndependent(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .saveRole(widget.selectedRole);

      // Generate code for this user (independent trainers/gyms get codes too)
      final user = ref.read(authStateProvider).value;
      if (user != null &&
          (widget.selectedRole == AppRole.trainer ||
              widget.selectedRole == AppRole.gym)) {
        await _generateUserCode(user.uid, widget.selectedRole);
      }

      if (context.mounted) {
        _navigateToDashboard(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: errorColor),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateUserCode(String uid, AppRole role) async {
    final firestore = ref.read(firestoreProvider);
    final code = _generate6DigitCode();

    await firestore.collection('users').doc(uid).update({
      'accessCode': code,
      'qrData': 'fitx:${role.name}:$code',
    });
  }

  String _generate6DigitCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  void _navigateToDashboard(BuildContext context) {
    switch (widget.selectedRole) {
      case AppRole.trainee:
        context.go('/dashboard');
      case AppRole.trainer:
        context.go('/trainer-dashboard');
      case AppRole.gym:
        context.go('/gym-dashboard');
      default:
        context.go('/dashboard');
    }
  }
}

/// كارت اختيار طريقة الربط
class _LinkingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _LinkingCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(spaceLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radiusLg),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withAlpha(77),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(radiusMd),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// شاشة إدخال كود الجيم
// ─────────────────────────────────────────────────────────────────────────────

class GymCodeScreen extends ConsumerStatefulWidget {
  final AppRole selectedRole;
  final Function(String gymId, String gymName) onGymLinked;

  const GymCodeScreen({
    super.key,
    required this.selectedRole,
    required this.onGymLinked,
  });

  @override
  ConsumerState<GymCodeScreen> createState() => _GymCodeScreenState();
}

class _GymCodeScreenState extends ConsumerState<GymCodeScreen> {
  final _codeController = TextEditingController();
  String? _errorMessage;
  bool _isVerifying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'كود الجيم',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: spaceLg),
              const Icon(
                Icons.business,
                size: 80,
                color: primaryColor,
              ),
              const SizedBox(height: spaceLg),
              const Text(
                'ادخل كود الجيم',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: spaceSm),
              const Text(
                'اطلب الكود من إدارة الجيم',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: spaceLg),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 32,
                  letterSpacing: 12,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceColorLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '000000',
                  hintStyle: const TextStyle(
                    color: textTertiary,
                    fontSize: 32,
                    letterSpacing: 12,
                  ),
                  errorText: _errorMessage,
                  counterText: '',
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: spaceLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyGymCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: const Color(0xFF1A1A00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusMd),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A1A00),
                          ),
                        )
                      : const Text(
                          'تحقق',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyGymCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'الكود لازم يكون 6 أرقام');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final firestore = ref.read(firestoreProvider);

      // البحث عن الجيم بالكود
      final query = await firestore
          .collection('gyms')
          .where('accessCode', isEqualTo: code)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _errorMessage = 'كود الجيم غير صحيح');
        return;
      }

      final gymDoc = query.docs.first;
      final gymId = gymDoc.id;
      final gymName = gymDoc.data()['name'] ?? 'بدون اسم';

      // حفظ البيانات في الـ User
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).update({
          'gymId': gymId,
          'gymName': gymName,
          'linkedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        widget.onGymLinked(gymId, gymName);
      }
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ. حاول تاني.');
    } finally {
      setState(() => _isVerifying = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// شاشة السؤال عن المدرب (بعد ربط الجيم)
// ─────────────────────────────────────────────────────────────────────────────

class TrainerQuestionScreen extends StatelessWidget {
  final String gymId;
  final String gymName;
  final AppRole selectedRole;

  const TrainerQuestionScreen({
    super.key,
    required this.gymId,
    required this.gymName,
    required this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'المدرب',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'متصل بـ: $gymName',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: spaceLg),
              const Text(
                'هل معاك مدرب في الجيم؟',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: spaceSm),
              const Text(
                'ممكن تدخل كود المدرب دلوقتي أو تضيفه بعدين',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: spaceLg),
              _OptionCard(
                title: 'نعم، معايا كود مدرب',
                icon: Icons.check_circle,
                color: Colors.green,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => TrainerCodeScreen(
                        gymId: gymId,
                        selectedRole: selectedRole,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: spaceMd),
              _OptionCard(
                title: 'لا، بدون مدرب',
                icon: Icons.cancel,
                color: Colors.orange,
                onTap: () {
                  // اكتمال بدون مدرب
                  _completeWithoutTrainer(context, selectedRole);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeWithoutTrainer(
      BuildContext context, AppRole role) async {
    // Navigate to dashboard directly
    if (context.mounted) {
      context.go('/dashboard');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// شاشة إدخال كود المدرب
// ─────────────────────────────────────────────────────────────────────────────

class TrainerCodeScreen extends ConsumerStatefulWidget {
  final String? gymId;
  final AppRole selectedRole;

  const TrainerCodeScreen({
    super.key,
    this.gymId,
    required this.selectedRole,
  });

  @override
  ConsumerState<TrainerCodeScreen> createState() => _TrainerCodeScreenState();
}

class _TrainerCodeScreenState extends ConsumerState<TrainerCodeScreen> {
  final _codeController = TextEditingController();
  String? _errorMessage;
  bool _isVerifying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'كود المدرب',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: spaceLg),
              const Icon(
                Icons.school,
                size: 80,
                color: primaryColor,
              ),
              const SizedBox(height: spaceLg),
              const Text(
                'ادخل كود المدرب',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: spaceSm),
              const Text(
                'اطلب الكود من المدرب بتاعك',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: spaceLg),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 32,
                  letterSpacing: 12,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceColorLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '000000',
                  hintStyle: const TextStyle(
                    color: textTertiary,
                    fontSize: 32,
                    letterSpacing: 12,
                  ),
                  errorText: _errorMessage,
                  counterText: '',
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: spaceLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyTrainerCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: const Color(0xFF1A1A00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusMd),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A1A00),
                          ),
                        )
                      : const Text(
                          'تحقق',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyTrainerCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'الكود لازم يكون 6 أرقام');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final firestore = ref.read(firestoreProvider);

      // البحث عن المدرب بالكود
      final query = await firestore
          .collection('users')
          .where('accessCode', isEqualTo: code)
          .where('role', isEqualTo: 'trainer')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _errorMessage = 'كود المدرب غير صحيح');
        return;
      }

      final trainerDoc = query.docs.first;
      final trainerId = trainerDoc.id;
      final trainerName = trainerDoc.data()['name'] ?? 'بدون اسم';
      final trainerGymId = trainerDoc.data()['gymId'];

      // لو المدرب في جيم مختلف، نحذر المستخدم
      if (widget.gymId != null &&
          trainerGymId != null &&
          trainerGymId != widget.gymId) {
        setState(() => _errorMessage = 'المدرب ده مش في نفس الجيم');
        return;
      }

      // حفظ البيانات
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final updates = <String, dynamic>{
          'trainerId': trainerId,
          'trainerName': trainerName,
          'linkedToTrainerAt': FieldValue.serverTimestamp(),
        };

        // لو في جيم، نضيفه
        if (widget.gymId == null && trainerGymId != null) {
          updates['gymId'] = trainerGymId;
          updates['gymName'] = trainerDoc.data()['gymName'] ?? 'بدون اسم';
        }

        await firestore.collection('users').doc(user.uid).update(updates);

        // إضافة المتدرب لقائمة المدرب
        await firestore
            .collection('users')
            .doc(trainerId)
            .collection('trainees')
            .doc(user.uid)
            .set({
          'linkedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });
      }

      if (mounted) {
        // اكتمال التسجيل
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ. حاول تاني.');
    } finally {
      setState(() => _isVerifying = false);
    }
  }
}

/// كارت اختيار
class _OptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(spaceLg),
        decoration: BoxDecoration(
          color: surfaceColorLight,
          borderRadius: BorderRadius.circular(radiusLg),
          border: Border.all(color: color.withAlpha(77), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(radiusMd),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: spaceMd),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
