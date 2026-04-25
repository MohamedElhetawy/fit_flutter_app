import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/progress_photo.dart';

/// Service for managing progress photos locally
class ProgressPhotoService {
  static final ProgressPhotoService _instance =
      ProgressPhotoService._internal();
  factory ProgressPhotoService() => _instance;
  ProgressPhotoService._internal();

  static const String _photosKey = 'progress_photos';
  static const String _photosDir = 'progress_photos';

  /// Get the directory for storing photos
  Future<Directory> _getPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/$_photosDir');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  /// Get all saved progress photos
  Future<List<ProgressPhoto>> getPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = prefs.getStringList(_photosKey) ?? [];
    return photosJson.map((json) => ProgressPhoto.fromJson(json)).toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
  }

  /// Get photos for comparison (first and last)
  Future<List<ProgressPhoto>> getComparisonPhotos() async {
    final photos = await getPhotos();
    if (photos.length < 2) return photos;
    return [photos.last, photos.first]; // [oldest, newest]
  }

  /// Add a new progress photo
  Future<ProgressPhoto> addPhoto({
    required XFile imageFile,
    String? notes,
    PhotoType type = PhotoType.front,
  }) async {
    final photosDir = await _getPhotosDirectory();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final fileName = 'progress_${type.name}_$id.jpg';
    final localPath = '${photosDir.path}/$fileName';

    // Copy image to app directory
    await File(imageFile.path).copy(localPath);

    // Create photo record
    final photo = ProgressPhoto(
      id: id,
      localPath: localPath,
      dateTaken: DateTime.now(),
      notes: notes,
      type: type,
    );

    // Save to preferences
    await _savePhoto(photo);

    return photo;
  }

  /// Delete a progress photo
  Future<void> deletePhoto(String id) async {
    final photos = await getPhotos();
    final photo = photos.firstWhere((p) => p.id == id);

    // Delete file
    final file = File(photo.localPath);
    if (await file.exists()) {
      await file.delete();
    }

    // Remove from preferences
    photos.removeWhere((p) => p.id == id);
    await _savePhotosList(photos);
  }

  /// Save a single photo to preferences
  Future<void> _savePhoto(ProgressPhoto photo) async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = prefs.getStringList(_photosKey) ?? [];
    photosJson.add(photo.toJson());
    await prefs.setStringList(_photosKey, photosJson);
  }

  /// Save the entire photos list
  Future<void> _savePhotosList(List<ProgressPhoto> photos) async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = photos.map((p) => p.toJson()).toList();
    await prefs.setStringList(_photosKey, photosJson);
  }

  /// Update photo after Google Drive sync
  Future<void> updatePhotoSyncStatus(String id, String driveFileId) async {
    final photos = await getPhotos();
    final index = photos.indexWhere((p) => p.id == id);
    if (index != -1) {
      photos[index] = photos[index].copyWith(
        driveFileId: driveFileId,
        syncedAt: DateTime.now(),
      );
      await _savePhotosList(photos);
    }
  }

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    return await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
  }

  /// Get photos that need backup (not synced or modified since last sync)
  Future<List<ProgressPhoto>> getPhotosNeedingBackup() async {
    final photos = await getPhotos();
    return photos.where((p) {
      if (p.driveFileId == null) return true;
      if (p.syncedAt == null) return true;
      return false;
    }).toList();
  }

  /// Clear all photos (use with caution)
  Future<void> clearAllPhotos() async {
    final photos = await getPhotos();

    // Delete all files
    for (final photo in photos) {
      final file = File(photo.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Clear preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_photosKey);
  }
}
