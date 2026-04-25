/// Represents a trainer-trainee link request with full audit trail
class LinkRequest {
  final String id;
  final String traineeId;
  final String traineeName;
  final String traineeEmail;
  final String trainerId;
  final String trainerName;
  final LinkRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? qrNonce; // Track which QR was used
  final String? responseMessage;

  const LinkRequest({
    required this.id,
    required this.traineeId,
    required this.traineeName,
    required this.traineeEmail,
    required this.trainerId,
    required this.trainerName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.qrNonce,
    this.responseMessage,
  });

  factory LinkRequest.fromMap(String id, Map<String, dynamic> map) {
    return LinkRequest(
      id: id,
      traineeId: map['traineeId']?.toString() ?? '',
      traineeName: map['traineeName']?.toString() ?? '',
      traineeEmail: map['traineeEmail']?.toString() ?? '',
      trainerId: map['trainerId']?.toString() ?? '',
      trainerName: map['trainerName']?.toString() ?? '',
      status: _parseStatus(map['status']?.toString()),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      respondedAt: DateTime.tryParse(map['respondedAt']?.toString() ?? ''),
      qrNonce: map['qrNonce']?.toString(),
      responseMessage: map['responseMessage']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'traineeId': traineeId,
        'traineeName': traineeName,
        'traineeEmail': traineeEmail,
        'trainerId': trainerId,
        'trainerName': trainerName,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'respondedAt': respondedAt?.toIso8601String(),
        'qrNonce': qrNonce,
        'responseMessage': responseMessage,
      };

  LinkRequest copyWith({
    LinkRequestStatus? status,
    DateTime? respondedAt,
    String? responseMessage,
  }) {
    return LinkRequest(
      id: id,
      traineeId: traineeId,
      traineeName: traineeName,
      traineeEmail: traineeEmail,
      trainerId: trainerId,
      trainerName: trainerName,
      status: status ?? this.status,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      qrNonce: qrNonce,
      responseMessage: responseMessage ?? this.responseMessage,
    );
  }
}

enum LinkRequestStatus { pending, accepted, declined, cancelled }

extension LinkRequestStatusExtension on LinkRequestStatus {
  String get name {
    switch (this) {
      case LinkRequestStatus.pending:
        return 'pending';
      case LinkRequestStatus.accepted:
        return 'accepted';
      case LinkRequestStatus.declined:
        return 'declined';
      case LinkRequestStatus.cancelled:
        return 'cancelled';
    }
  }
}

LinkRequestStatus _parseStatus(String? value) {
  switch (value) {
    case 'pending':
      return LinkRequestStatus.pending;
    case 'accepted':
      return LinkRequestStatus.accepted;
    case 'declined':
      return LinkRequestStatus.declined;
    case 'cancelled':
      return LinkRequestStatus.cancelled;
    default:
      return LinkRequestStatus.pending;
  }
}
