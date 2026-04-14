import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';

class BodyProgressScreen extends ConsumerWidget {
  const BodyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    if (uid == null) return const SizedBox.shrink();

    final stream = ref
        .watch(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('progress_photos')
        .orderBy('takenAt')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Body Progress')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _capturePhoto(context, ref, uid),
        child: const Icon(Icons.add_a_photo),
      ),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No progress photos yet.'));
          }
          final first = docs.first.data();
          final latest = docs.last.data();
          return ListView(
            padding: const EdgeInsets.all(defaultPadding),
            children: [
              Text('First vs Latest', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(child: _photoCard(first['url']?.toString(), 'First')),
                  const SizedBox(width: 8),
                  Expanded(child: _photoCard(latest['url']?.toString(), 'Latest')),
                ],
              ),
              const SizedBox(height: defaultPadding),
              ...docs.reversed.map((d) => ListTile(
                    leading: const Icon(Icons.photo),
                    title: Text((d.data()['takenAt'] ?? '').toString()),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _photoCard(String? url, String label) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: url == null
              ? const ColoredBox(color: Colors.black12)
              : Image.network(url, fit: BoxFit.cover, cacheWidth: 300),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  Future<void> _capturePhoto(BuildContext context, WidgetRef ref, String uid) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image == null) return;

    final file = File(image.path);
    final path =
        'users/$uid/progress/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final task = await FirebaseStorage.instance.ref(path).putFile(file);
    final url = await task.ref.getDownloadURL();

    await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('progress_photos')
        .add({
      'url': url,
      'takenAt': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
