import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'qr_crypto_service.dart';

/// Result of QR code verification
enum QrVerificationResult {
  valid,
  invalidSignature,
  expired,
  alreadyUsed,
  malformed,
}

/// Handles secure QR verification including one-time use tracking
class QrVerificationService {
  final FirebaseFirestore _firestore;
  final QrCryptoService _crypto;

  const QrVerificationService({
    required FirebaseFirestore firestore,
    required QrCryptoService crypto,
  })  : _firestore = firestore,
        _crypto = crypto;

  /// Verifies a QR payload completely:
  /// 1. Validates signature
  /// 2. Checks expiry
  /// 3. Checks if already used (one-time)
  Future<QrVerificationResult> verify(Map<String, dynamic> payload) async {
    // Step 1: Verify signature
    if (!_crypto.verifySignature(payload)) {
      return QrVerificationResult.invalidSignature;
    }

    // Step 2: Check expiry
    if (_crypto.isExpired(payload)) {
      return QrVerificationResult.expired;
    }

    // Step 3: Check one-time use (nonce)
    final nonce = payload['n']?.toString();
    if (nonce == null) {
      return QrVerificationResult.malformed;
    }

    final alreadyUsed = await _isNonceUsed(nonce);
    if (alreadyUsed) {
      return QrVerificationResult.alreadyUsed;
    }

    return QrVerificationResult.valid;
  }

  /// Marks a nonce as used (call this after successful verification and link request creation)
  Future<void> markUsed(
    String nonce, {
    required String usedByUserId,
    required String trainerId,
  }) async {
    await _firestore.collection('used_qr_tokens').doc(nonce).set({
      'usedAt': DateTime.now().toIso8601String(),
      'usedBy': usedByUserId,
      'trainerId': trainerId,
      'expiresAt': DateTime.now()
          .add(const Duration(days: 30))
          .toIso8601String(), // Keep for 30 days then delete
    });
  }

  Future<bool> _isNonceUsed(String nonce) async {
    final doc = await _firestore.collection('used_qr_tokens').doc(nonce).get();
    return doc.exists;
  }

  /// Extracts trainer ID from valid payload
  String? extractTrainerId(Map<String, dynamic> payload) {
    return payload['tid']?.toString();
  }
}

/// Riverpod provider for the verification service
final qrVerificationServiceProvider = Provider<QrVerificationService>((ref) {
  throw UnimplementedError('Override this provider with actual instances');
});
