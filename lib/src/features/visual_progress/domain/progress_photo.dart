import 'dart:convert';

/// Model for progress photos
class ProgressPhoto {
  final String id;
  final String localPath;
  final String? driveFileId;
  final DateTime dateTaken;
  final String? notes;
  final PhotoType type;
  final DateTime? syncedAt;

  const ProgressPhoto({
    required this.id,
    required this.localPath,
    this.driveFileId,
    required this.dateTaken,
    this.notes,
    this.type = PhotoType.front,
    this.syncedAt,
  });

  factory ProgressPhoto.fromMap(Map<String, dynamic> map) {
    return ProgressPhoto(
      id: map['id'] ?? '',
      localPath: map['localPath'] ?? '',
      driveFileId: map['driveFileId'],
      dateTaken: DateTime.parse(map['dateTaken']),
      notes: map['notes'],
      type: PhotoType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PhotoType.front,
      ),
      syncedAt:
          map['syncedAt'] != null ? DateTime.parse(map['syncedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'localPath': localPath,
      'driveFileId': driveFileId,
      'dateTaken': dateTaken.toIso8601String(),
      'notes': notes,
      'type': type.name,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());
  factory ProgressPhoto.fromJson(String source) =>
      ProgressPhoto.fromMap(json.decode(source));

  ProgressPhoto copyWith({
    String? id,
    String? localPath,
    String? driveFileId,
    DateTime? dateTaken,
    String? notes,
    PhotoType? type,
    DateTime? syncedAt,
  }) {
    return ProgressPhoto(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      driveFileId: driveFileId ?? this.driveFileId,
      dateTaken: dateTaken ?? this.dateTaken,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

enum PhotoType {
  front,
  side,
  back,
  other,
}
