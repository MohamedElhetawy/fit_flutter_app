import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';

/// زر QR Code صغير للـ Profile/AppBar
/// لما يتضغط عليه يفتح نافذة منبثقة بالـ QR Code
class QrCodeButton extends ConsumerWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const QrCodeButton({
    super.key,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showQrCodeModal(context, ref),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? surfaceColorLight,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Icon(
          Icons.qr_code,
          color: iconColor ?? primaryColor,
          size: size * 0.5,
        ),
      ),
    );
  }

  void _showQrCodeModal(BuildContext context, WidgetRef ref) {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
      ),
      builder: (context) => _QrCodeModal(userId: user.uid),
    );
  }
}

/// نافذة منبثقة بـ QR Code
class _QrCodeModal extends ConsumerWidget {
  final String userId;

  const _QrCodeModal({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: ref.read(firestoreProvider)
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        final data = snapshot.data?.data() ?? {};
        final code = data['accessCode'] as String? ?? '------';
        final qrData = data['qrData'] as String? ?? 'fitx:$userId:$code';
        final name = data['name'] ?? data['gymName'] ?? 'بدون اسم';
        final role = data['role'] as String? ?? 'unknown';

        return Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: const BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: spaceLg),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(radiusMd),
                      ),
                      child: const Icon(Icons.qr_code, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'كود الانضمام',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: spaceLg),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(spaceLg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),

                const SizedBox(height: spaceLg),

                // Code Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
                    ),
                    borderRadius: BorderRadius.circular(radiusMd),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12,
                    ),
                  ),
                ),

                const SizedBox(height: spaceMd),

                // Instructions
                Text(
                  _getInstructionByRole(role),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: spaceLg),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyCode(context, code),
                        icon: const Icon(Icons.copy, size: 20),
                        label: const Text('نسخ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: surfaceColorLight,
                          foregroundColor: textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: spaceMd),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openScanner(context);
                        },
                        icon: const Icon(Icons.qr_code_scanner, size: 20),
                        label: const Text('مسح'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: const Color(0xFF1A1A00),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInstructionByRole(String role) {
    switch (role) {
      case 'trainee':
        return 'أظهر هذا الكود لمدربك أو الجيم للانضمام';
      case 'trainer':
        return 'أظهر هذا الكود للمتدربين للانضمام لك';
      case 'gym':
        return 'أظهر هذا الكود للمدربين والمتدربين للانضمام للجيم';
      default:
        return 'كود الانضمام الخاص بك';
    }
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ الكود'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openScanner(BuildContext context) {
    // Navigate to scanner - you can import CodeDisplayScreen and use its scanner
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: const Text('مسح QR Code', style: TextStyle(color: textPrimary)),
        content: const Text(
          'استخدم زر "مسح QR Code" في شاشة عرض الكود',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}
