import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Secure QR Payload Structure:
/// {
///   'trainerId': string,
///   'timestamp': int (milliseconds since epoch),
///   'nonce': string (random 16 chars),
///   'signature': string (HMAC-SHA256)
/// }
///
/// Security Features:
/// 1. Signature: HMAC-SHA256 of (trainerId + timestamp + nonce)
/// 2. Expiry: 10 minutes from generation
/// 3. One-time: nonce tracked in Firestore used_tokens collection

class QrCryptoService {
  final String _secretKey;

  const QrCryptoService({required String secretKey}) : _secretKey = secretKey;

  /// Generates a signed QR payload with expiry
  Map<String, dynamic> generatePayload({
    required String trainerId,
    Duration expiry = const Duration(minutes: 10),
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final expiryTimestamp = timestamp + expiry.inMilliseconds;
    final nonce = _generateNonce();

    final signature = _createSignature(
      trainerId: trainerId,
      timestamp: timestamp,
      nonce: nonce,
    );

    return {
      'v': '1', // version for future compatibility
      'tid': trainerId,
      'ts': timestamp,
      'exp': expiryTimestamp,
      'n': nonce,
      'sig': signature,
    };
  }

  /// Verifies payload signature without checking expiry or one-time use
  /// (those are checked separately via Firestore)
  bool verifySignature(Map<String, dynamic> payload) {
    try {
      final version = payload['v']?.toString();
      if (version != '1') return false;

      final trainerId = payload['tid']?.toString();
      final timestamp = payload['ts'] as int?;
      final nonce = payload['n']?.toString();
      final signature = payload['sig']?.toString();

      if (trainerId == null ||
          timestamp == null ||
          nonce == null ||
          signature == null) {
        return false;
      }

      final expectedSignature = _createSignature(
        trainerId: trainerId,
        timestamp: timestamp,
        nonce: nonce,
      );

      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }

  /// Checks if payload has expired
  bool isExpired(Map<String, dynamic> payload) {
    final expiry = payload['exp'] as int?;
    if (expiry == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now > expiry;
  }

  String _createSignature({
    required String trainerId,
    required int timestamp,
    required String nonce,
  }) {
    final data = '$trainerId:$timestamp:$nonce';
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64Url.encode(digest.bytes);
  }

  String _generateNonce() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
