import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import '../domain/progress_photo.dart';
import '../providers/visual_progress_providers.dart';

/// Visual Progress screen with photo comparison
class VisualProgressScreen extends ConsumerWidget {
  const VisualProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosNotifierProvider);
    final comparisonAsync = ref.watch(comparisonPhotosProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding, spaceMd, defaultPadding, 0),
              sliver: SliverToBoxAdapter(
                child: _buildAppBar(context, ref),
              ),
            ),
            // Photo Comparison Card
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding, spaceLg, defaultPadding, 0),
              sliver: SliverToBoxAdapter(
                child: comparisonAsync.when(
                  data: (photos) => _buildComparisonCard(context, photos),
                  loading: () => const FitXShimmerCard(height: 300),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
            // Photo Gallery Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding, spaceLg, defaultPadding, spaceSm),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Photo Gallery',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _buildTypeFilter(ref),
                  ],
                ),
              ),
            ),
            // Photo Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              sliver: photosAsync.when(
                data: (photos) => _buildPhotoGrid(context, ref, photos),
                loading: () => SliverToBoxAdapter(
                  child: Wrap(
                    spacing: spaceSm,
                    runSpacing: spaceSm,
                    children: List.generate(
                      4,
                      (_) => const SizedBox(
                        width: 150,
                        height: 150,
                        child: FitXShimmerCard(height: 150),
                      ),
                    ),
                  ),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Text('Error: $err', style: const TextStyle(color: errorColor)),
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: spaceXxl)),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, ref),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: textPrimary),
        ),
        const Expanded(
          child: Text(
            'Visual Progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Backup button
        IconButton(
          onPressed: () => _showBackupDialog(context, ref),
          icon: const Icon(Icons.backup_rounded, color: primaryColor),
          tooltip: 'Google Drive Backup',
        ),
      ],
    );
  }

  Widget _buildComparisonCard(BuildContext context, List<ProgressPhoto> photos) {
    if (photos.length < 2) {
      return const FitXCard(
        padding: EdgeInsets.all(spaceLg),
        child: Column(
          children: [
            Icon(Icons.compare_rounded, color: textTertiary, size: 48),
            SizedBox(height: spaceMd),
            Text(
              'Add at least 2 photos to see comparison',
              style: TextStyle(color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final before = photos.first;
    final after = photos.last;

    return FitXCard(
      padding: const EdgeInsets.all(spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Before & After',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_formatDate(before.dateTaken)} - ${_formatDate(after.dateTaken)}',
                style: const TextStyle(color: textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildPhotoComparison(
                  context,
                  before,
                  'Before',
                  textTertiary,
                ),
              ),
              const SizedBox(width: spaceSm),
              const Icon(Icons.arrow_forward_rounded, color: primaryColor, size: 24),
              const SizedBox(width: spaceSm),
              Expanded(
                child: _buildPhotoComparison(
                  context,
                  after,
                  'After',
                  successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),
          // Progress indicator
          _buildProgressIndicator(before.dateTaken, after.dateTaken),
        ],
      ),
    );
  }

  Widget _buildPhotoComparison(
    BuildContext context,
    ProgressPhoto photo,
    String label,
    Color labelColor,
  ) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radiusMd),
          child: Image.file(
            File(photo.localPath),
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 120,
              color: surfaceColorLight,
              child: const Icon(Icons.image_not_supported, color: textTertiary),
            ),
          ),
        ),
        const SizedBox(height: spaceXs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: labelColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(DateTime before, DateTime after) {
    final daysDiff = after.difference(before).inDays;
    
    return Container(
      padding: const EdgeInsets.all(spaceMd),
      decoration: BoxDecoration(
        color: surfaceColorLight,
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: primaryColor, size: 20),
          const SizedBox(width: spaceSm),
          Expanded(
            child: Text(
              '$daysDiff days of progress',
              style: const TextStyle(color: textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Keep Going!',
              style: TextStyle(
                color: successColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(WidgetRef ref) {
    return PopupMenuButton<PhotoType?>(
      icon: const Icon(Icons.filter_list_rounded, color: textSecondary),
      onSelected: (type) {
        ref.read(photoTypeFilterProvider.notifier).state = type;
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Types'),
        ),
        ...PhotoType.values.map((type) => PopupMenuItem(
          value: type,
          child: Text(_getPhotoTypeName(type)),
        )),
      ],
    );
  }

  Widget _buildPhotoGrid(BuildContext context, WidgetRef ref, List<ProgressPhoto> photos) {
    if (photos.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.photo_library_outlined, color: textTertiary, size: 64),
              SizedBox(height: spaceMd),
              Text(
                'No photos yet',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: spaceSm,
        crossAxisSpacing: spaceSm,
        childAspectRatio: 1,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final photo = photos[index];
          return _buildPhotoCard(context, ref, photo);
        },
        childCount: photos.length,
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, WidgetRef ref, ProgressPhoto photo) {
    return GestureDetector(
      onTap: () => _showPhotoDetail(context, ref, photo),
      child: FitXCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(radiusMd),
                ),
                child: Image.file(
                  File(photo.localPath),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: surfaceColorLight,
                    child: const Icon(Icons.image_not_supported, color: textTertiary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(spaceSm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getPhotoTypeName(photo.type),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (photo.driveFileId != null)
                    const Icon(Icons.cloud_done_rounded, color: successColor, size: 16)
                  else
                    const Icon(Icons.cloud_off_rounded, color: textTertiary, size: 16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(spaceSm, 0, spaceSm, spaceSm),
              child: Text(
                _formatDate(photo.dateTaken),
                style: const TextStyle(color: textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddPhotoOptions(context, ref),
      backgroundColor: primaryColor,
      foregroundColor: const Color(0xFF1A1A00),
      icon: const Icon(Icons.camera_alt_rounded),
      label: const Text('Add Photo'),
    );
  }

  void _showAddPhotoOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: spaceLg),
              const Text(
                'Add Progress Photo',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: spaceLg),
              _buildPhotoOption(
                context,
                ref,
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                source: ImageSource.camera,
              ),
              const SizedBox(height: spaceMd),
              _buildPhotoOption(
                context,
                ref,
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                source: ImageSource.gallery,
              ),
              const SizedBox(height: spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withValues(alpha: 0.2),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(label, style: const TextStyle(color: textPrimary)),
      onTap: () async {
        Navigator.pop(context);
        final service = ref.read(progressPhotoServiceProvider);
        final image = await service.pickImage(source: source);
        if (image != null && context.mounted) {
          _showPhotoTypeDialog(context, ref, image);
        }
      },
    );
  }

  void _showPhotoTypeDialog(BuildContext context, WidgetRef ref, XFile image) {
    PhotoType selectedType = PhotoType.front;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: surfaceColor,
          title: const Text('Photo Details', style: TextStyle(color: textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo type selector
              SegmentedButton<PhotoType>(
                segments: PhotoType.values.map((type) => ButtonSegment(
                  value: type,
                  label: Text(_getPhotoTypeName(type)),
                )).toList(),
                selected: {selectedType},
                onSelectionChanged: (selection) {
                  setState(() => selectedType = selection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return primaryColor;
                    }
                    return surfaceColorLight;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF1A1A00);
                    }
                    return textPrimary;
                  }),
                ),
              ),
              const SizedBox(height: spaceMd),
              // Notes field
              TextField(
                controller: notesController,
                style: const TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Notes (optional)',
                  hintStyle: const TextStyle(color: textTertiary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radiusMd),
                    borderSide: const BorderSide(color: surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radiusMd),
                    borderSide: const BorderSide(color: primaryColor),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(photosNotifierProvider.notifier).addPhoto(
                  imageFile: image,
                  type: selectedType,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: const Color(0xFF1A1A00),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, WidgetRef ref, ProgressPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: surfaceColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Image.file(
                  File(photo.localPath),
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getPhotoTypeName(photo.type),
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(photo.dateTaken),
                        style: const TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                  if (photo.notes != null) ...[
                    const SizedBox(height: spaceSm),
                    Text(
                      photo.notes!,
                      style: const TextStyle(color: textPrimary),
                    ),
                  ],
                  const SizedBox(height: spaceMd),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmDelete(context, ref, photo);
                          },
                          icon: const Icon(Icons.delete_outline, color: errorColor),
                          label: const Text('Delete', style: TextStyle(color: errorColor)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: errorColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ProgressPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text('Delete Photo?', style: TextStyle(color: textPrimary)),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(photosNotifierProvider.notifier).deletePhoto(photo.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.cloud_upload_rounded, color: primaryColor),
            SizedBox(width: 8),
            Text('Google Drive Backup', style: TextStyle(color: textPrimary)),
          ],
        ),
        content: const Text(
          'Backup your progress photos to Google Drive for safe keeping.\n\n'
          'You need to be signed in with Google to use this feature.',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performBackup(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A1A00),
            ),
            child: const Text('Backup Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _performBackup(BuildContext context, WidgetRef ref) async {
    // Note: In production, you'd use the existing GoogleSignIn from auth
    // For now, showing a coming soon dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text('قريباً', style: TextStyle(color: textPrimary)),
        content: const Text(
          'Google Drive backup requires Google Sign In integration. '
          'This feature will be fully functional after authentication setup.',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A1A00),
            ),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  String _getPhotoTypeName(PhotoType type) {
    switch (type) {
      case PhotoType.front:
        return 'Front';
      case PhotoType.side:
        return 'Side';
      case PhotoType.back:
        return 'Back';
      case PhotoType.other:
        return 'Other';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Simple shimmer card for loading state
class FitXShimmerCard extends StatelessWidget {
  final double height;
  const FitXShimmerCard({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: surfaceColorLight,
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    );
  }
}
