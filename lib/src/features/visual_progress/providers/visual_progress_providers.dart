import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/progress_photo.dart';
import '../data/progress_photo_service.dart';
import '../data/google_drive_backup_service.dart';

/// Provider for the progress photo service
final progressPhotoServiceProvider = Provider<ProgressPhotoService>((ref) {
  return ProgressPhotoService();
});

/// Provider for the Google Drive backup service
final googleDriveServiceProvider = Provider<GoogleDriveBackupService>((ref) {
  return GoogleDriveBackupService();
});

/// Provider for all progress photos
final progressPhotosProvider = FutureProvider<List<ProgressPhoto>>((ref) async {
  final service = ref.watch(progressPhotoServiceProvider);
  return await service.getPhotos();
});

/// Provider for comparison photos (first and last)
final comparisonPhotosProvider =
    FutureProvider<List<ProgressPhoto>>((ref) async {
  final service = ref.watch(progressPhotoServiceProvider);
  return await service.getComparisonPhotos();
});

/// Notifier for managing photos
class PhotosNotifier extends StateNotifier<AsyncValue<List<ProgressPhoto>>> {
  final ProgressPhotoService _service;

  PhotosNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    try {
      final photos = await _service.getPhotos();
      state = AsyncValue.data(photos);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addPhoto({
    required XFile imageFile,
    String? notes,
    PhotoType type = PhotoType.front,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.addPhoto(
        imageFile: imageFile,
        notes: notes,
        type: type,
      );
      await loadPhotos();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deletePhoto(String id) async {
    try {
      await _service.deletePhoto(id);
      await loadPhotos();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    await loadPhotos();
  }
}

/// State notifier provider for photos
final photosNotifierProvider =
    StateNotifierProvider<PhotosNotifier, AsyncValue<List<ProgressPhoto>>>(
        (ref) {
  final service = ref.watch(progressPhotoServiceProvider);
  return PhotosNotifier(service);
});

/// Provider for backup status
final backupStatusProvider = StateProvider<String?>((ref) => null);

/// Provider to perform Google Drive backup
final backupToDriveProvider =
    FutureProvider.family<Map<String, String?>, GoogleSignIn>(
        (ref, googleSignIn) async {
  final driveService = ref.watch(googleDriveServiceProvider);
  final photoService = ref.watch(progressPhotoServiceProvider);

  // Update status
  ref.read(backupStatusProvider.notifier).state =
      'جاري الاتصال بـ Google Drive...';

  // Initialize Google Drive
  final initialized = await driveService.initialize(googleSignIn);
  if (!initialized) {
    throw Exception('فشل الاتصال بـ Google Drive');
  }

  // Get photos needing backup
  ref.read(backupStatusProvider.notifier).state = 'جاري البحث عن صور جديدة...';
  final photosToBackup = await photoService.getPhotosNeedingBackup();

  if (photosToBackup.isEmpty) {
    ref.read(backupStatusProvider.notifier).state =
        'لا توجد صور جديدة للنسخ الاحتياطي';
    return {};
  }

  // Backup photos
  ref.read(backupStatusProvider.notifier).state =
      'جاري نسخ ${photosToBackup.length} صورة احتياطياً...';
  final results = await driveService.backupPhotos(photosToBackup);

  // Update sync status for successfully uploaded photos
  int successCount = 0;
  for (final entry in results.entries) {
    if (entry.value != null) {
      await photoService.updatePhotoSyncStatus(entry.key, entry.value!);
      successCount++;
    }
  }

  ref.read(backupStatusProvider.notifier).state =
      'تم نسخ $successCount من ${photosToBackup.length} صورة';

  // Refresh photos list
  await ref.read(photosNotifierProvider.notifier).refresh();

  return results;
});

/// Provider for selected photo type filter
final photoTypeFilterProvider = StateProvider<PhotoType?>((ref) => null);

/// Provider for filtered photos
final filteredPhotosProvider = Provider<AsyncValue<List<ProgressPhoto>>>((ref) {
  final photosAsync = ref.watch(photosNotifierProvider);
  final filter = ref.watch(photoTypeFilterProvider);

  return photosAsync.when(
    data: (photos) {
      if (filter == null) return AsyncValue.data(photos);
      final filtered = photos.where((p) => p.type == filter).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
