import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/features/workouts/data/workouts_backend_providers.dart';
import 'package:fitx/src/features/workouts/data/workout.dart';

class SuperAdminWorkoutCms extends ConsumerWidget {
  const SuperAdminWorkoutCms({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutsBackendStreamProvider);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Row(
            children: [
              Text('Workout CMS',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openEditor(context, ref, null),
                icon: const Icon(Icons.add),
                label: const Text('Add Workout'),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          workouts.when(
            data: (items) {
              if (items.isEmpty) return const Text('No workouts found');
              return Column(
                children: items
                    .map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.coach),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _openEditor(context, ref, item),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: errorColor),
                                onPressed: () async {
                                  await ref
                                      .read(workoutsBackendRepositoryProvider)
                                      .deleteWorkout(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Failed to load workouts: $e'),
          )
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, [
    Workout? data,
  ]) async {
    final title = TextEditingController(text: data?.title ?? '');
    final coach = TextEditingController(text: data?.coach ?? '');
    final price = TextEditingController(text: data?.price.toString() ?? '0');
    final image = TextEditingController(text: data?.image ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data == null ? 'Add workout' : 'Edit workout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title')),
              TextField(
                  controller: coach,
                  decoration: const InputDecoration(labelText: 'Coach')),
              TextField(
                  controller: price,
                  decoration: const InputDecoration(labelText: 'Price')),
              TextField(
                  controller: image,
                  decoration: const InputDecoration(labelText: 'Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                'title': title.text.trim(),
                'coach': coach.text.trim(),
                'price': double.tryParse(price.text.trim()) ?? 0,
                'image': image.text.trim(),
                'updatedAt': DateTime.now().toIso8601String(),
              };
              if (data == null) {
                await ref
                    .read(workoutsBackendRepositoryProvider)
                    .addWorkout(payload);
              } else {
                await ref
                    .read(workoutsBackendRepositoryProvider)
                    .updateWorkout(data.id, payload);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
