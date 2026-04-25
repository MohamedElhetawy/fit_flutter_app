import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';

/// شاشة عرض الكود و QR Code
/// للمدربين والجيمات علشان يشاركوها مع المتدربين
class CodeDisplayScreen extends ConsumerWidget {
  final String title;
  final String subtitle;

  const CodeDisplayScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style:
              const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: primaryColor),
            onPressed: () => _copyCode(context, ref),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: ref
            .read(firestoreProvider)
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final data = snapshot.data?.data() ?? {};
          final code = data['accessCode'] as String? ?? '------';
          final qrData = data['qrData'] as String? ?? '';
          final name = data['name'] ?? data['gymName'] ?? 'بدون اسم';

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  // الكود الكبير
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(spaceLg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withAlpha(77),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.vpn_key,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: spaceMd),
                        const Text(
                          'كود الانضمام',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: spaceSm),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: spaceLg),
                        // الأرقام
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: spaceLg,
                            vertical: spaceMd,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(radiusMd),
                          ),
                          child: Text(
                            code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: spaceLg),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(spaceLg),
                    decoration: BoxDecoration(
                      color: surfaceColorLight,
                      borderRadius: BorderRadius.circular(radiusLg),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'أو امسح QR Code',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: spaceMd),
                        Container(
                          padding: const EdgeInsets.all(spaceMd),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(radiusMd),
                          ),
                          child: QrImageView(
                            data: qrData.isNotEmpty ? qrData : code,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // تعليمات
                  Container(
                    padding: const EdgeInsets.all(spaceMd),
                    decoration: BoxDecoration(
                      color: surfaceColorLight,
                      borderRadius: BorderRadius.circular(radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: primaryColor),
                        const SizedBox(width: spaceSm),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: spaceMd),

                  // زر مسح QR Code
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _scanQrCode(context, ref),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text(
                        'مسح QR Code',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: surfaceColorLight,
                        foregroundColor: textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radiusMd),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: spaceSm),

                  // زر نسخ الكود
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _copyCode(context, ref),
                      icon: const Icon(Icons.copy),
                      label: const Text(
                        'نسخ الكود',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: const Color(0xFF1A1A00),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _copyCode(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final doc = await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};
    final code = data['accessCode'] ?? '';

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

  void _scanQrCode(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _QrScannerScreen(
          onCodeScanned: (code) async {
            // Process scanned code
            await _processScannedCode(context, ref, code);
          },
        ),
      ),
    );
  }

  Future<void> _processScannedCode(
      BuildContext context, WidgetRef ref, String code) async {
    try {
      // Parse QR data format: fitx:userId:accessCode
      if (!code.startsWith('fitx:')) {
        throw Exception('كود غير صالح');
      }

      final parts = code.split(':');
      if (parts.length != 3) {
        throw Exception('تنسيق الكود غير صحيح');
      }

      final scannedUserId = parts[1];
      final scannedCode = parts[2];

      final firestore = ref.read(firestoreProvider);

      // Find user by ID and code
      final userDoc =
          await firestore.collection('users').doc(scannedUserId).get();

      if (!userDoc.exists) {
        throw Exception('المستخدم غير موجود');
      }

      final userData = userDoc.data()!;
      final userCode = userData['accessCode'] as String?;
      final userRole = userData['role'] as String?;

      if (userCode != scannedCode) {
        throw Exception('كود غير صحيح');
      }

      // Navigate to appropriate linking screen based on role
      if (context.mounted) {
        Navigator.pop(context); // Close scanner

        if (userRole == 'trainer') {
          // Navigate to trainer code entry with pre-filled code
          _showLinkingDialog(
              context, ref, 'مدرب', scannedUserId, userData['name'] ?? '');
        } else if (userRole == 'gym') {
          _showLinkingDialog(
              context, ref, 'جيم', scannedUserId, userData['name'] ?? '');
        } else {
          throw Exception('لا يمكن الربط بهذا المستخدم');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  void _showLinkingDialog(BuildContext context, WidgetRef ref, String type,
      String userId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title:
            Text('الربط بـ $type', style: const TextStyle(color: textPrimary)),
        content: Text(
          'هل تريد الانضمام إلى $name؟',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Handle linking logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب الانضمام'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child:
                const Text('تأكيد', style: TextStyle(color: Color(0xFF1A1A00))),
          ),
        ],
      ),
    );
  }
}

/// شاشة مسح QR Code
class _QrScannerScreen extends StatefulWidget {
  final Function(String) onCodeScanned;

  const _QrScannerScreen({required this.onCodeScanned});

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'مسح QR Code',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_hasScanned) return;

          final barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final rawValue = barcode.rawValue;
            if (rawValue != null && rawValue.startsWith('fitx:')) {
              setState(() => _hasScanned = true);
              widget.onCodeScanned(rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}
