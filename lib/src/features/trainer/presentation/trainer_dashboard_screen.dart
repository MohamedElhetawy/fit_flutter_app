import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fitx/constants.dart';

import '../../../core/auth/auth_controller.dart';
import '../../tasks/data/task_models.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/link_request.dart';
import '../data/link_request_repository.dart';
import '../providers/link_request_providers.dart';
import '../services/qr_crypto_service.dart';

/// Trainer Dashboard with:
/// - Secure QR with HMAC signature + expiry + one-time use
/// - Link Request governance (Accept/Decline, not direct bind)
/// - Task assignment to trainees
class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final uid = ref.watch(authStateProvider).value?.uid;
    if (uid == null) return const SizedBox.shrink();

    final pendingCount = ref.watch(trainerPendingRequestCountProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: const Text('مركز المدرب', style: TextStyle(color: textPrimary)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: textSecondary),
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
          bottom: TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: textSecondary,
            tabs: [
              const Tab(icon: Icon(Icons.people), text: 'المتدربين'),
              Tab(
                icon: Badge(
                  isLabelVisible: pendingCount.when(
                    data: (c) => c > 0,
                    loading: () => false,
                    error: (_, __) => false,
                  ),
                  label: pendingCount.when(
                    data: (c) => Text('$c', style: const TextStyle(color: Colors.white)),
                    loading: () => null,
                    error: (_, __) => null,
                  ),
                  child: const Icon(Icons.notifications),
                ),
                text: 'الطلبات',
              ),
              const Tab(icon: Icon(Icons.qr_code), text: 'الربط'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TraineesTab(),
            _LinkRequestsTab(),
            _QrTab(user: user, uid: uid),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: List of connected trainees
class _TraineesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    if (uid == null) return const SizedBox.shrink();

    // Watch accepted link requests = connected trainees
    final requestsAsync = ref.watch(trainerIncomingRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        final accepted = requests.where((r) => r.status == LinkRequestStatus.accepted).toList();

        if (accepted.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: textTertiary),
                SizedBox(height: 16),
                Text(
                  'لا يوجد متدربين مرتبطين بعد',
                  style: TextStyle(color: textSecondary, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'شارك QR code عشان تبدأ',
                  style: TextStyle(color: textTertiary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(defaultPadding),
          itemCount: accepted.length,
          itemBuilder: (context, index) {
            final req = accepted[index];
            return _TraineeCard(request: req);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _TraineeCard extends ConsumerWidget {
  final LinkRequest request;

  const _TraineeCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(request.traineeName[0].toUpperCase()),
        ),
        title: Text(request.traineeName),
        subtitle: Text(request.traineeEmail),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAssignNutritionTask(context, ref),
                    icon: const Icon(Icons.restaurant_menu, size: 18),
                    label: const Text('Nutrition'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAssignWorkoutTask(context, ref),
                    icon: const Icon(Icons.fitness_center, size: 18),
                    label: const Text('Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignNutritionTask(BuildContext context, WidgetRef ref) {
    final trainer = ref.read(currentUserProvider).value;
    showDialog(
      context: context,
      builder: (context) => _NutritionTaskDialog(
        traineeId: request.traineeId,
        trainerId: request.trainerId,
        trainerName: trainer?.name ?? 'Trainer',
        onAssign: (taskData) {
          ref.read(taskCreateControllerProvider.notifier).createTask(
            userId: request.traineeId,
            assignedById: request.trainerId,
            assignedByName: trainer?.name ?? 'Trainer',
            type: TaskType.nutrition,
            title: taskData.title,
            description: taskData.description,
            dueDate: taskData.dueDate,
            metadata: taskData.metadata,
          );
        },
      ),
    );
  }

  void _showAssignWorkoutTask(BuildContext context, WidgetRef ref) {
    final trainer = ref.read(currentUserProvider).value;
    showDialog(
      context: context,
      builder: (context) => _WorkoutTaskDialog(
        traineeId: request.traineeId,
        trainerId: request.trainerId,
        trainerName: trainer?.name ?? 'Trainer',
        onAssign: (taskData) {
          ref.read(taskCreateControllerProvider.notifier).createTask(
            userId: request.traineeId,
            assignedById: request.trainerId,
            assignedByName: trainer?.name ?? 'Trainer',
            type: TaskType.workout,
            title: taskData.title,
            description: taskData.description,
            priority: taskData.priority ?? TaskPriority.medium,
            dueDate: taskData.dueDate,
          );
        },
      ),
    );
  }
}

/// Tab 2: Link Requests (Accept/Decline)
class _LinkRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(trainerIncomingRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        final pending = requests.where((r) => r.status == LinkRequestStatus.pending).toList();
        final history = requests.where((r) => r.status != LinkRequestStatus.pending).toList();

        return ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            if (pending.isNotEmpty) ...[
              Text(
                'Pending Requests (${pending.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...pending.map((req) => _PendingRequestCard(request: req)),
              const SizedBox(height: 24),
            ],
            if (history.isNotEmpty) ...[
              Text(
                'History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...history.map((req) => _HistoryRequestCard(request: req)),
            ],
            if (pending.isEmpty && history.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 64),
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'No requests yet',
                      style: TextStyle(color: textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _PendingRequestCard extends ConsumerWidget {
  final LinkRequest request;

  const _PendingRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(linkRequestControllerProvider);
    final isLoading = controller.isLoading;

    return Card(
      color: Colors.orange[50],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(request.traineeName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.traineeName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        request.traineeEmail,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Wants to connect with you as their trainer',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeclineDialog(context, ref),
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => ref
                          .read(linkRequestControllerProvider.notifier)
                          .acceptRequest(request.id),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _DeclineDialog(
        requestId: request.id,
        onDecline: (reason) {
          ref.read(linkRequestControllerProvider.notifier).declineRequest(
            request.id,
            reason: reason,
          );
        },
      ),
    );
  }
}

/// Decline dialog with proper controller disposal
class _DeclineDialog extends StatefulWidget {
  final String requestId;
  final void Function(String? reason) onDecline;

  const _DeclineDialog({
    required this.requestId,
    required this.onDecline,
  });

  @override
  State<_DeclineDialog> createState() => _DeclineDialogState();
}

class _DeclineDialogState extends State<_DeclineDialog> {
  late final TextEditingController reasonCtrl;

  @override
  void initState() {
    super.initState();
    reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decline Request?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Optional: Add a reason for declining'),
          const SizedBox(height: 8),
          TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(hintText: 'Reason (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onDecline(reasonCtrl.text.isEmpty ? null : reasonCtrl.text);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}

/// Task data holder for task dialogs
class _TaskData {
  final String title;
  final String description;
  final DateTime? dueDate;
  final Map<String, dynamic> metadata;
  final TaskPriority? priority;

  _TaskData({
    required this.title,
    required this.description,
    this.dueDate,
    required this.metadata,
    this.priority,
  });
}

/// Nutrition task dialog with proper controller disposal
class _NutritionTaskDialog extends StatefulWidget {
  final String traineeId;
  final String trainerId;
  final String trainerName;
  final void Function(_TaskData taskData) onAssign;

  const _NutritionTaskDialog({
    required this.traineeId,
    required this.trainerId,
    required this.trainerName,
    required this.onAssign,
  });

  @override
  State<_NutritionTaskDialog> createState() => _NutritionTaskDialogState();
}

class _NutritionTaskDialogState extends State<_NutritionTaskDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController calCtrl;
  late final TextEditingController proteinCtrl;
  late final TextEditingController carbsCtrl;
  late final TextEditingController fatCtrl;
  late final TextEditingController dueCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    calCtrl = TextEditingController(text: '500');
    proteinCtrl = TextEditingController(text: '30');
    carbsCtrl = TextEditingController(text: '50');
    fatCtrl = TextEditingController(text: '15');
    dueCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    calCtrl.dispose();
    proteinCtrl.dispose();
    carbsCtrl.dispose();
    fatCtrl.dispose();
    dueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null && mounted) {
      setState(() {
        dueCtrl.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Nutrition Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Meal Name'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: calCtrl,
                    decoration: const InputDecoration(labelText: 'Cal'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: proteinCtrl,
                    decoration: const InputDecoration(labelText: 'Protein'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: carbsCtrl,
                    decoration: const InputDecoration(labelText: 'Carbs'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: fatCtrl,
                    decoration: const InputDecoration(labelText: 'Fat'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TextField(
              controller: dueCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _pickDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            DateTime? dueDate;
            if (dueCtrl.text.isNotEmpty) {
              final parts = dueCtrl.text.split('/');
              if (parts.length == 3) {
                dueDate = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              }
            }

            final taskData = _TaskData(
              title: nameCtrl.text.isEmpty ? 'Nutrition Task' : nameCtrl.text,
              description: '${calCtrl.text} kcal | P:${proteinCtrl.text} C:${carbsCtrl.text} F:${fatCtrl.text}',
              dueDate: dueDate,
              metadata: {
                'calories': int.tryParse(calCtrl.text) ?? 0,
                'protein': int.tryParse(proteinCtrl.text) ?? 0,
                'carbs': int.tryParse(carbsCtrl.text) ?? 0,
                'fat': int.tryParse(fatCtrl.text) ?? 0,
              },
            );

            widget.onAssign(taskData);
            Navigator.pop(context);
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

/// Workout task dialog with proper controller disposal
class _WorkoutTaskDialog extends StatefulWidget {
  final String traineeId;
  final String trainerId;
  final String trainerName;
  final void Function(_TaskData taskData) onAssign;

  const _WorkoutTaskDialog({
    required this.traineeId,
    required this.trainerId,
    required this.trainerName,
    required this.onAssign,
  });

  @override
  State<_WorkoutTaskDialog> createState() => _WorkoutTaskDialogState();
}

class _WorkoutTaskDialogState extends State<_WorkoutTaskDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController notesCtrl;
  late final TextEditingController dueCtrl;
  TaskPriority priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    notesCtrl = TextEditingController();
    dueCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    notesCtrl.dispose();
    dueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null && mounted) {
      setState(() {
        dueCtrl.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Workout Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Workout Name'),
            ),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes / Sets & Reps'),
              maxLines: 2,
            ),
            TextField(
              controller: dueCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Priority: '),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Low'),
                  selected: priority == TaskPriority.low,
                  onSelected: (_) => setState(() => priority = TaskPriority.low),
                ),
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('Medium'),
                  selected: priority == TaskPriority.medium,
                  onSelected: (_) => setState(() => priority = TaskPriority.medium),
                ),
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('High'),
                  selected: priority == TaskPriority.high,
                  onSelected: (_) => setState(() => priority = TaskPriority.high),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            DateTime? dueDate;
            if (dueCtrl.text.isNotEmpty) {
              final parts = dueCtrl.text.split('/');
              if (parts.length == 3) {
                dueDate = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              }
            }

            final taskData = _TaskData(
              title: nameCtrl.text.isEmpty ? 'Workout Task' : nameCtrl.text,
              description: notesCtrl.text,
              dueDate: dueDate,
              priority: priority,
              metadata: const {},
            );

            widget.onAssign(taskData);
            Navigator.pop(context);
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

class _HistoryRequestCard extends StatelessWidget {
  final LinkRequest request;

  const _HistoryRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final colors = {
      LinkRequestStatus.accepted: Colors.green,
      LinkRequestStatus.declined: Colors.red,
      LinkRequestStatus.cancelled: Colors.grey,
      LinkRequestStatus.pending: Colors.orange,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(request.traineeName[0].toUpperCase()),
        ),
        title: Text(request.traineeName),
        subtitle: Text(request.traineeEmail),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors[request.status]?.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.status.name.toUpperCase(),
            style: TextStyle(
              color: colors[request.status],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab 3: QR Code Generation (Secure)
class _QrTab extends StatelessWidget {
  final dynamic user;
  final String uid;

  const _QrTab({required this.user, required this.uid});

  @override
  Widget build(BuildContext context) {
    // Create secure payload
    const crypto = QrCryptoService(secretKey: 'fitx-secure-qr-key-v1-do-not-share');
    final payload = crypto.generatePayload(trainerId: uid);
    final payloadJson = jsonEncode(payload);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: payloadJson,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Trainer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scan to request connection',
                    style: TextStyle(color: textTertiary, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This QR code expires in 10 minutes and can only be used once for security.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showScanQrSheet(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Trainee QR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanQrSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TraineeQrScannerSheet(trainerId: uid),
    );
  }
}

/// QR Scanner for trainees wanting to connect
class _TraineeQrScannerSheet extends ConsumerStatefulWidget {
  final String trainerId;

  const _TraineeQrScannerSheet({required this.trainerId});

  @override
  ConsumerState<_TraineeQrScannerSheet> createState() => _TraineeQrScannerSheetState();
}

class _TraineeQrScannerSheetState extends ConsumerState<_TraineeQrScannerSheet> {
  bool _isProcessing = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            title: const Text('مسح QR المتدرب', style: TextStyle(color: textPrimary)),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: textSecondary),
              ),
            ],
          ),
          if (_error != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(radiusMd),
                border: Border.all(color: errorColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: errorColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : MobileScanner(
                    onDetect: _onDetect,
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'امسح QR code الخاص بالمتدلب لإرسال طلب تواصل',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Parse trainee QR payload
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      
      // Validate payload structure
      if (payload['type'] != 'trainee_qr' || payload['traineeId'] == null) {
        throw Exception('QR code غير صالح');
      }

      final traineeId = payload['traineeId'] as String;
      final traineeName = payload['traineeName'] as String? ?? 'متدرب';
      final traineeEmail = payload['traineeEmail'] as String? ?? '';

      // Get trainer info from provider
      final trainerAsync = ref.read(currentUserProvider);
      final trainer = trainerAsync.value;
      
      if (trainer == null) {
        throw Exception('معلومات المدرب غير متوفرة');
      }

      // Create reverse link request
      final repo = ref.read(linkRequestRepositoryProvider);
      await repo.createRequestByTrainer(
        trainerId: trainer.id,
        trainerName: trainer.name,
        traineeId: traineeId,
        traineeName: traineeName,
        traineeEmail: traineeEmail,
      );

      // Success - close and notify
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلب التواصل بنجاح!'),
            backgroundColor: successColor,
          ),
        );
      }
    } on LinkRequestException catch (e) {
      setState(() {
        _error = e.message;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }
}
