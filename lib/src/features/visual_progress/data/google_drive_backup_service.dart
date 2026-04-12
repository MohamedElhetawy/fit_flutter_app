import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../domain/progress_photo.dart';

/// Service for backing up photos to Google Drive
class GoogleDriveBackupService {
  static final GoogleDriveBackupService _instance = GoogleDriveBackupService._internal();
  factory GoogleDriveBackupService() => _instance;
  GoogleDriveBackupService._internal();

  drive.DriveApi? _driveApi;
  String? _folderId;

  static const String _appFolderName = 'FitX Progress Photos';

  /// Check if user is signed in to Google
  bool get isSignedIn => _driveApi != null;

  /// Initialize with Google Sign In
  Future<bool> initialize(GoogleSignIn googleSignIn) async {
    try {
      final authClient = await googleSignIn.authenticatedClient();
      if (authClient == null) return false;

      _driveApi = drive.DriveApi(authClient);
      await _getOrCreateFolder();
      return true;
    } catch (e) {
      // Log error for debugging
      return false;
    }
  }

  /// Get or create the app folder in Google Drive
  Future<String?> _getOrCreateFolder() async {
    if (_driveApi == null) return null;

    try {
      // Search for existing folder
      final response = await _driveApi!.files.list(
        q: "name='$_appFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );

      if (response.files?.isNotEmpty == true) {
        _folderId = response.files!.first.id;
        return _folderId;
      }

      // Create new folder
      final folder = drive.File()
        ..name = _appFolderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final created = await _driveApi!.files.create(folder);
      _folderId = created.id;
      return _folderId;
    } catch (e) {
      // Log error for debugging
      return null;
    }
  }

  /// Upload a photo to Google Drive
  Future<String?> uploadPhoto(ProgressPhoto photo) async {
    if (_driveApi == null || _folderId == null) return null;

    try {
      final file = File(photo.localPath);
      if (!await file.exists()) return null;

      // Check if file already exists
      if (photo.driveFileId != null) {
        // Update existing file
        final media = drive.Media(file.openRead(), file.lengthSync());
        await _driveApi!.files.update(
          drive.File()..name = '${photo.type.name}_${photo.id}.jpg',
          photo.driveFileId!,
          uploadMedia: media,
        );
        return photo.driveFileId;
      } else {
        // Create new file
        final driveFile = drive.File()
          ..name = '${photo.type.name}_${photo.id}.jpg'
          ..parents = [_folderId!];

        final media = drive.Media(file.openRead(), file.lengthSync());
        final uploaded = await _driveApi!.files.create(
          driveFile,
          uploadMedia: media,
        );
        return uploaded.id;
      }
    } catch (e) {
      // Log error for debugging
      return null;
    }
  }

  /// Download a photo from Google Drive
  Future<bool> downloadPhoto(String driveFileId, String localPath) async {
    if (_driveApi == null) return false;

    try {
      final response = await _driveApi!.files.get(
        driveFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final file = File(localPath);
      final sink = file.openWrite();
      await response.stream.pipe(sink);
      await sink.close();

      return true;
    } catch (e) {
      // Log error for debugging
      return false;
    }
  }

  /// Backup all photos that need syncing
  Future<Map<String, String?>> backupPhotos(List<ProgressPhoto> photos) async {
    if (_driveApi == null || _folderId == null) {
      throw Exception('Google Drive not initialized');
    }

    final results = <String, String?>{};

    for (final photo in photos) {
      final fileId = await uploadPhoto(photo);
      results[photo.id] = fileId;
    }

    return results;
  }

  /// Restore photos from Google Drive (download missing files)
  Future<List<ProgressPhoto>> restorePhotos(List<String> driveFileIds) async {
    if (_driveApi == null) return [];

    final restored = <ProgressPhoto>[];

    for (final fileId in driveFileIds) {
      try {
        final file = await _driveApi!.files.get(fileId) as drive.File?;
        if (file == null) continue;

        // TODO: Implement proper restore with metadata
        // For now, just downloading the files
      } catch (e) {
        // Log error for debugging
      }
    }

    return restored;
  }

  /// Delete a photo from Google Drive
  Future<bool> deletePhoto(String driveFileId) async {
    if (_driveApi == null) return false;

    try {
      await _driveApi!.files.delete(driveFileId);
      return true;
    } catch (e) {
      // Log error for debugging
      return false;
    }
  }

  /// Sign out and clear credentials
  Future<void> signOut() async {
    _driveApi = null;
    _folderId = null;
  }
}
