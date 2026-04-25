import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import '../../visual_progress/presentation/visual_progress_screen.dart';

/// Premium Profile screen — Apple Settings inspired.
class ProfileScreenFitX extends ConsumerWidget {
  const ProfileScreenFitX({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final displayName = user?.displayName ?? 'FitX User';
    final email = user?.email ?? 'user@fitx.com';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              defaultPadding, spaceMd, defaultPadding, 100),
          children: [
            // ── Header ───────────────────────────────────
            const Text(
              'Profile',
              style: TextStyle(
                color: textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: spaceLg),

            // ── User Card ────────────────────────────────
            FitXCard(
              onTap: () => _showEditProfileDialog(context, ref, displayName),
              padding: const EdgeInsets.all(spaceMd + 4),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withAlpha(38),
                      border: Border.all(
                        color: primaryColor.withAlpha(102),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: spaceXs),
                        Text(
                          email,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radiusSm),
                      color: surfaceColorLight,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: spaceMd),

            // ── Visual Progress Card ───────────────────
            FitXCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VisualProgressScreen()),
              ),
              padding: const EdgeInsets.all(spaceMd),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: successColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(radiusSm),
                    ),
                    child: const Icon(
                      Icons.compare_rounded,
                      color: successColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visual Progress',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: spaceXs),
                        Text(
                          'Compare your transformation',
                          style: TextStyle(
                            color: textSecondary.withAlpha(204),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: textTertiary,
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: spaceLg),

            // ── Settings Groups ──────────────────────────
            _buildSettingsGroup(
              context,
              ref,
              items: [
                _SettingsItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  onTap: () =>
                      _showEditProfileDialog(context, ref, displayName),
                ),
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _showNotificationsDialog(context),
                ),
                _SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy',
                  onTap: () => _showPrivacyDialog(context),
                ),
              ],
            ),
            const SizedBox(height: spaceMd),

            _buildSettingsGroup(
              context,
              ref,
              items: [
                _SettingsItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () => _showHelpDialog(context),
                ),
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: spaceLg),

            // ── Logout ───────────────────────────────────
            FitXCard(
              onTap: () => _showLogoutConfirmation(context, ref),
              padding: const EdgeInsets.all(spaceMd),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: errorColor, size: 20),
                  SizedBox(width: spaceSm),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      color: errorColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    WidgetRef ref, {
    required List<_SettingsItem> items,
  }) {
    return FitXCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: spaceMd, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: surfaceColorLight,
                          borderRadius: BorderRadius.circular(radiusXs),
                        ),
                        child: Icon(item.icon, color: textSecondary, size: 20),
                      ),
                      const SizedBox(width: spaceSm + spaceXs),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(left: 64),
                  child: Divider(
                    height: 0.5,
                    color: surfaceBorder,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, WidgetRef ref, String currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text('Edit Profile', style: TextStyle(color: textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: textPrimary),
              decoration: InputDecoration(
                labelText: 'Display Name',
                labelStyle: const TextStyle(color: textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radiusMd),
                  borderSide: const BorderSide(color: surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radiusMd),
                  borderSide: const BorderSide(color: primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update profile in Firebase
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A1A00),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.notifications_outlined, color: primaryColor),
            SizedBox(width: 8),
            Text('Notifications', style: TextStyle(color: textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationToggle('Workout Reminders', true),
            _buildNotificationToggle('Progress Updates', true),
            _buildNotificationToggle('Tips & Advice', false),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A1A00),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(String title, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) => SwitchListTile(
        title: Text(title, style: const TextStyle(color: textPrimary)),
        value: initialValue,
        onChanged: (value) => setState(() {}),
        activeThumbColor: primaryColor,
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text('Privacy', style: TextStyle(color: textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Settings',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: spaceSm),
            Text(
              '• Profile is visible to friends only\n'
              '• Workout data is private\n'
              '• Photos are stored locally',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A1A00),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title:
            const Text('Help & Support', style: TextStyle(color: textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpOption(context, 'FAQ', Icons.help_outline_rounded),
            _buildHelpOption(context, 'Contact Support', Icons.email_outlined),
            _buildHelpOption(
                context, 'Report a Bug', Icons.bug_report_outlined),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: const TextStyle(color: textPrimary)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title - Coming soon!')),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text('About FitX', style: TextStyle(color: textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo/Fit_X_Logo.png',
              height: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: spaceXs),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: textSecondary),
            ),
            const SizedBox(height: spaceMd),
            const Text(
              'Your ultimate fitness companion for tracking workouts, nutrition, and progress.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A1A00),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text('Log Out?', style: TextStyle(color: textPrimary)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
}
