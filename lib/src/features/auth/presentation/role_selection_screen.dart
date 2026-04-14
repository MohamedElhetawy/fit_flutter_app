import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/app_role.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modern Role Selection Screen with secure gym code verification
/// Super Admin is auto-detected by email
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  AppRole? _selectedRole;
  String? _selectedGymId;
  String? _selectedGymName;
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Check if current user is super admin by email
  bool _isSuperAdmin(String? email) {
    // TODO: Move to environment variable or secure config
    const superAdminEmails = ['superadmin@fitx.com', 'owner@fitx.com'];
    return email != null && superAdminEmails.contains(email.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;
    final user = ref.watch(authStateProvider).value;
    
    // Auto-detect super admin
    if (_isSuperAdmin(user?.email)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _saveRole(AppRole.superAdmin);
      });
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(defaultPadding, spaceLg, defaultPadding, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FitX',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spaceSm),
                    Text(
                      'أهلاً بيك! اختار نوع حسابك',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: spaceSm),
                    Text(
                      'اختار دورك علشان نخصصلك تجربة مثالية',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Role Cards
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _RoleCard(
                      title: 'متدرب',
                      subtitle: 'تابع تمارينك وتقدمك مع مدربك',
                      icon: Icons.fitness_center,
                      gradient: const [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
                      isSelected: _selectedRole == AppRole.trainee,
                      onTap: () => setState(() => _selectedRole = AppRole.trainee),
                    ),
                    const SizedBox(height: spaceMd),
                    _RoleCard(
                      title: 'مدرب',
                      subtitle: 'إدارة المتدربين ومتابعة تقدمهم',
                      icon: Icons.school,
                      gradient: const [Color(0xFF4A5568), Color(0xFF718096)],
                      isSelected: _selectedRole == AppRole.trainer,
                      onTap: () => setState(() => _selectedRole = AppRole.trainer),
                    ),
                  ],
                ),
              ),
            ),

            // Gym Selection (if role selected)
            if (_selectedRole != null) ...[
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(defaultPadding, 0, defaultPadding, spaceSm),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'اختر الجيم',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                sliver: _GymList(
                  selectedGymId: _selectedGymId,
                  onSelect: (id, name) => setState(() {
                    _selectedGymId = id;
                    _selectedGymName = name;
                    _errorMessage = null;
                  }),
                ),
              ),
            ],

            // Gym Code Input (if gym selected)
            if (_selectedGymId != null) ...[
              SliverPadding(
                padding: const EdgeInsets.all(defaultPadding),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'كود $_selectedGymName',
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: spaceSm),
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 24,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLength: 6,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: surfaceColorLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          hintText: '------',
                          hintStyle: const TextStyle(
                            color: textTertiary,
                            fontSize: 24,
                            letterSpacing: 8,
                          ),
                          counterText: '',
                          errorText: _errorMessage,
                        ),
                        onChanged: (_) => setState(() => _errorMessage = null),
                      ),
                      const SizedBox(height: spaceXs),
                      const Text(
                        'ادخل الكود اللي حصلت عليه من الجيم',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Continue Button
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: ElevatedButton(
                  onPressed: _canProceed() && !loading ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: const Color(0xFF1A1A00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusMd),
                    ),
                  ),
                  child: loading || _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A1A00),
                          ),
                        )
                      : const Text(
                          'استمرار',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_selectedRole == null) return false;
    if (_selectedGymId == null) return false;
    if (_codeController.text.length < 4) return false;
    return true;
  }

  Future<void> _onContinue() async {
    if (!_canProceed()) return;

    setState(() => _isVerifying = true);

    try {
      // Verify gym code
      final isValid = await _verifyGymCode(_selectedGymId!, _codeController.text.trim());
      
      if (!isValid) {
        setState(() {
          _errorMessage = 'الكود غير صحيح. حاول تاني.';
          _isVerifying = false;
        });
        return;
      }

      // Save role with gym info
      await _saveRoleWithGym(_selectedRole!, _selectedGymId!, _selectedGymName!);
      
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ. حاول تاني.';
        _isVerifying = false;
      });
    }
  }

  Future<bool> _verifyGymCode(String gymId, String code) async {
    final firestore = ref.read(firestoreProvider);
    final doc = await firestore.collection('gyms').doc(gymId).get();
    
    if (!doc.exists) return false;
    
    final data = doc.data();
    final validCode = data?['accessCode'] as String?;
    
    return validCode != null && validCode.toUpperCase() == code.toUpperCase();
  }

  Future<void> _saveRole(AppRole role) async {
    await ref.read(authControllerProvider.notifier).saveRole(role);
    if (mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _saveRoleWithGym(AppRole role, String gymId, String gymName) async {
    await ref.read(authControllerProvider.notifier).saveRole(role);
    
    // Save gym association
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(firestoreProvider).collection('users').doc(user.uid).update({
        'gymId': gymId,
        'gymName': gymName,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    }
    
    if (mounted) {
      context.go('/dashboard');
    }
  }
}

/// Modern Role Selection Card
class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(spaceMd),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected ? gradient : [surfaceColorLight, surfaceColorLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radiusLg),
          border: Border.all(
            color: isSelected ? gradient[0] : surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(radiusMd),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : gradient[0],
                size: 32,
              ),
            ),
            const SizedBox(width: spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.9) : textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.white : textTertiary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

/// Gym List Stream Builder
class _GymList extends ConsumerWidget {
  final String? selectedGymId;
  final Function(String id, String name) onSelect;

  const _GymList({
    required this.selectedGymId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymsAsync = ref.watch(_gymsProvider);

    return gymsAsync.when(
      data: (gyms) {
        if (gyms.isEmpty) {
          return const _EmptyGymsState();
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final gym = gyms[index];
              final isSelected = selectedGymId == gym['id'];

              return Padding(
                padding: const EdgeInsets.only(bottom: spaceSm),
                child: _GymTile(
                  name: gym['name'] ?? 'بدون اسم',
                  location: gym['location'] ?? 'موقع غير محدد',
                  isSelected: isSelected,
                  onTap: () => onSelect(gym['id']!, gym['name'] ?? 'بدون اسم'),
                ),
              );
            },
            childCount: gyms.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(spaceMd),
            child: CircularProgressIndicator(color: primaryColor),
          ),
        ),
      ),
      error: (_, __) => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(spaceMd),
            child: Text(
              'فشل تحميل الجيمات',
              style: TextStyle(color: errorColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gym Tile Widget
class _GymTile extends StatelessWidget {
  final String name;
  final String location;
  final bool isSelected;
  final VoidCallback onTap;

  const _GymTile({
    required this.name,
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(spaceMd),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : surfaceColorLight,
          borderRadius: BorderRadius.circular(radiusMd),
          border: Border.all(
            color: isSelected ? primaryColor : surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withOpacity(0.2) : surfaceColor,
                borderRadius: BorderRadius.circular(radiusSm),
              ),
              child: Icon(
                Icons.location_on,
                color: isSelected ? primaryColor : textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? primaryColor : textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty Gyms State
class _EmptyGymsState extends StatelessWidget {
  const _EmptyGymsState();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(spaceLg),
        decoration: BoxDecoration(
          color: surfaceColorLight,
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        child: const Column(
          children: [
            Icon(Icons.business, size: 48, color: textTertiary),
            SizedBox(height: spaceMd),
            Text(
              'لا يوجد جيمات متاحة حالياً',
              style: TextStyle(color: textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider for gyms list
final _gymsProvider = StreamProvider<List<Map<String, String>>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('gyms')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {
            'id': doc.id,
            'name': doc.data()['name']?.toString() ?? 'بدون اسم',
            'location': doc.data()['location']?.toString() ?? 'موقع غير محدد',
          }).toList());
});
