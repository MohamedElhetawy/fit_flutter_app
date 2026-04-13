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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: textTertiary),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد متدربين مرتبطين بعد',
                  style: const TextStyle(color: textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'شارك QR code عشان تبدأ',
                  style: const TextStyle(color: textTertiary, fontSize: 14),
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
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController(text: '500');
    final proteinCtrl = TextEditingController(text: '30');
    final carbsCtrl = TextEditingController(text: '50');
    final fatCtrl = TextEditingController(text: '15');
    final dueCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    dueCtrl.text = '${date.day}/${date.month}/${date.year}';
                  }
                },
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
            onPressed: () async {
              final trainer = ref.read(currentUserProvider).value;
              
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

              await ref.read(taskCreateControllerProvider.notifier).createTask(
                userId: request.traineeId,
                assignedById: request.trainerId,
                assignedByName: trainer?.name ?? 'Trainer',
                type: TaskType.nutrition,
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

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showAssignWorkoutTask(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final dueCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      dueCtrl.text = '${date.day}/${date.month}/${date.year}';
                    }
                  },
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
              onPressed: () async {
                final trainer = ref.read(currentUserProvider).value;
                
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

                await ref.read(taskCreateControllerProvider.notifier).createTask(
                  userId: request.traineeId,
                  assignedById: request.trainerId,
                  assignedByName: trainer?.name ?? 'Trainer',
                  type: TaskType.workout,
                  title: nameCtrl.text.isEmpty ? 'Workout Task' : nameCtrl.text,
                  description: notesCtrl.text,
                  priority: priority,
                  dueDate: dueDate,
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Assign'),
            ),
          ],
        ),
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
                    Text(
                      'No requests yet',
                      style: const TextStyle(color: textSecondary, fontSize: 16),
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
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              ref.read(linkRequestControllerProvider.notifier).declineRequest(
                request.id,
                reason: reasonCtrl.text.isEmpty ? null : reasonCtrl.text,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
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
                  Text(
                    'Scan to request connection',
                    style: const TextStyle(color: textTertiary, fontSize: 14),
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
            title: const Text('Scan Trainee QR'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (_error != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : MobileScanner(
                    onDetect: _onDetect,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Scan a trainee\'s QR code to send them a connection request',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
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
      // final payload = jsonDecode(raw) as Map<String, dynamic>;

      // This would be for scanning trainee QR (reverse flow)
      // For now, show coming soon
      setState(() {
        _error = 'This feature is coming in the next update';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid QR code';
        _isProcessing = false;
      });
    }
  }
}
