import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/providers/firebase_providers.dart';
import '../data/link_request.dart';
import '../data/link_request_repository.dart';
import '../services/qr_crypto_service.dart';
import '../services/qr_verification_service.dart';

/// Repository provider
final linkRequestRepoProvider = Provider<LinkRequestRepository>((ref) {
  return LinkRequestRepository(firestore: ref.watch(firestoreProvider));
});

/// QR Crypto service provider (needs secret key from config)
final qrCryptoServiceProvider = Provider<QrCryptoService>((ref) {
  // In production, this should come from secure config or environment
  // For now using a derived key approach - in real app use Firebase Remote Config + env
  const secretKey = 'fitx-secure-qr-key-v1-do-not-share';
  return const QrCryptoService(secretKey: secretKey);
});

/// QR Verification service provider
final qrVerificationServiceProvider = Provider<QrVerificationService>((ref) {
  return QrVerificationService(
    firestore: ref.watch(firestoreProvider),
    crypto: ref.watch(qrCryptoServiceProvider),
  );
});

/// Stream of incoming requests for trainer
final trainerIncomingRequestsProvider =
    StreamProvider<List<LinkRequest>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(linkRequestRepoProvider).watchTrainerRequests(uid);
});

/// Stream of outgoing requests for trainee
final traineeOutgoingRequestsProvider =
    StreamProvider<List<LinkRequest>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(linkRequestRepoProvider).watchTraineeRequests(uid);
});

/// Pending request count for trainer badge
final trainerPendingRequestCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(0);
  return ref.watch(linkRequestRepoProvider).watchPendingCount(uid);
});

/// Controller for creating link requests via QR
final linkRequestControllerProvider =
    AsyncNotifierProvider<LinkRequestController, void>(
  LinkRequestController.new,
);

class LinkRequestController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  LinkRequestRepository get _repo => ref.read(linkRequestRepoProvider);
  QrVerificationService get _qrService =>
      ref.read(qrVerificationServiceProvider);

  /// Create a link request after scanning valid QR
  Future<void> createFromQrScan({
    required String traineeId,
    required String traineeName,
    required String traineeEmail,
    required Map<String, dynamic> qrPayload,
  }) async {
    state = const AsyncLoading();

    try {
      // Step 1: Verify QR is valid
      final verification = await _qrService.verify(qrPayload);
      if (verification != QrVerificationResult.valid) {
        throw LinkRequestException(
            'Invalid or expired QR code: ${verification.name}');
      }

      final trainerId = _qrService.extractTrainerId(qrPayload);
      if (trainerId == null) {
        throw LinkRequestException('Invalid QR: missing trainer ID');
      }

      final nonce = qrPayload['n']?.toString();

      // Step 2: Create the request
      await _repo.createRequest(
        traineeId: traineeId,
        traineeName: traineeName,
        traineeEmail: traineeEmail,
        trainerId: trainerId,
        trainerName: 'Trainer', // Will be updated from actual trainer profile
        qrNonce: nonce,
      );

      // Step 3: Mark QR as used (one-time)
      await _qrService.markUsed(
        nonce!,
        usedByUserId: traineeId,
        trainerId: trainerId,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Accept a request (trainer action)
  Future<void> acceptRequest(String requestId, {String? message}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.acceptRequest(requestId: requestId, message: message);
    });
  }

  /// Decline a request (trainer action)
  Future<void> declineRequest(String requestId, {String? reason}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.declineRequest(requestId: requestId, reason: reason);
    });
  }

  /// Cancel own request (trainee action)
  Future<void> cancelRequest(String requestId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.cancelRequest(requestId);
    });
  }
}
