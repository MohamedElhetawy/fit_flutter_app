import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import 'package:fitx/src/shared/widgets/fitx_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Gym Dashboard - للمديرين والجيمات
/// إحصائيات الجيم، المدربين، المتدربين، الاشتراكات
class GymDashboardScreen extends ConsumerStatefulWidget {
  const GymDashboardScreen({super.key});

  @override
  ConsumerState<GymDashboardScreen> createState() => _GymDashboardScreenState();
}

class _GymDashboardScreenState extends ConsumerState<GymDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          'لوحة تحكم الجيم',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: textSecondary),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: surfaceBorder,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'الرئيسية'),
            Tab(icon: Icon(Icons.people), text: 'المدربين'),
            Tab(icon: Icon(Icons.fitness_center), text: 'المتدربين'),
            Tab(icon: Icon(Icons.attach_money), text: 'المالية'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _OverviewTab(uid: uid),
          _TrainersTab(uid: uid),
          _TraineesTab(uid: uid),
          _FinanceTab(uid: uid),
        ],
      ),
    );
  }
}

/// تبويبة النظرة العامة
class _OverviewTab extends ConsumerWidget {
  final String uid;
  const _OverviewTab({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // إحصائيات سريعة
          const Text(
            'إحصائيات الجيم',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: spaceMd),
          
          // كارت الإحصائيات
          ref.watch(_gymStatsProvider(uid)).when(
            data: (stats) => _StatsGrid(stats: stats),
            loading: () => const FitXShimmerCard(height: 200),
            error: (_, __) => const _ErrorState(),
          ),
          
          const SizedBox(height: spaceLg),
          
          // آخر النشاطات
          const Text(
            'آخر النشاطات',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: spaceMd),
          
          ref.watch(_recentActivitiesProvider(uid)).when(
            data: (activities) => _ActivitiesList(activities: activities),
            loading: () => const FitXShimmerCard(height: 150),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// شبكة الإحصائيات
class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: spaceMd,
      mainAxisSpacing: spaceMd,
      children: [
        _StatCard(
          title: 'المتدربين',
          value: stats['trainees']?.toString() ?? '0',
          icon: Icons.fitness_center,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'المدربين',
          value: stats['trainers']?.toString() ?? '0',
          icon: Icons.school,
          color: Colors.green,
        ),
        _StatCard(
          title: 'الاشتراكات',
          value: stats['subscriptions']?.toString() ?? '0',
          icon: Icons.card_membership,
          color: primaryColor,
        ),
        _StatCard(
          title: 'الإيرادات',
          value: '${stats['revenue'] ?? 0} ج.م',
          icon: Icons.attach_money,
          color: Colors.orange,
        ),
      ],
    );
  }
}

/// كارت إحصائية
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FitXCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: spaceSm),
          Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// تبويبة المدربين
class _TrainersTab extends ConsumerWidget {
  final String uid;
  const _TrainersTab({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(_gymTrainersProvider(uid)).when(
      data: (trainers) {
        if (trainers.isEmpty) {
          return const _EmptyState(message: 'لا يوجد مدربين مرتبطين بالجيم');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(defaultPadding),
          itemCount: trainers.length,
          itemBuilder: (context, index) {
            final trainer = trainers[index];
            return _UserCard(
              name: trainer['name'] ?? 'بدون اسم',
              email: trainer['email'] ?? '',
              subtitle: '${trainer['trainees'] ?? 0} متدرب',
              icon: Icons.school,
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: 3,
        itemBuilder: (_, __) => const FitXShimmerCard(height: 80),
      ),
      error: (_, __) => const _ErrorState(),
    );
  }
}

/// تبويبة المتدربين
class _TraineesTab extends ConsumerWidget {
  final String uid;
  const _TraineesTab({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(_gymTraineesProvider(uid)).when(
      data: (trainees) {
        if (trainees.isEmpty) {
          return const _EmptyState(message: 'لا يوجد متدربين في الجيم');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(defaultPadding),
          itemCount: trainees.length,
          itemBuilder: (context, index) {
            final trainee = trainees[index];
            return _UserCard(
              name: trainee['name'] ?? 'بدون اسم',
              email: trainee['email'] ?? '',
              subtitle: 'مدرب: ${trainee['trainerName'] ?? 'غير محدد'}',
              icon: Icons.fitness_center,
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: 3,
        itemBuilder: (_, __) => const FitXShimmerCard(height: 80),
      ),
      error: (_, __) => const _ErrorState(),
    );
  }
}

/// تبويبة المالية
class _FinanceTab extends ConsumerWidget {
  final String uid;
  const _FinanceTab({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص المدفوعات',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: spaceMd),
          
          ref.watch(_gymRevenueProvider(uid)).when(
            data: (revenue) => _RevenueCard(revenue: revenue),
            loading: () => const FitXShimmerCard(height: 150),
            error: (_, __) => const _ErrorState(),
          ),
        ],
      ),
    );
  }
}

/// كارت الإيرادات
class _RevenueCard extends StatelessWidget {
  final Map<String, dynamic> revenue;
  
  const _RevenueCard({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return FitXCard(
      child: Column(
        children: [
          _RevenueRow(
            label: 'إجمالي الإيرادات',
            value: '${revenue['total'] ?? 0} ج.م',
            isBold: true,
          ),
          const Divider(color: surfaceBorder),
          _RevenueRow(
            label: 'هذا الشهر',
            value: '${revenue['monthly'] ?? 0} ج.م',
          ),
          _RevenueRow(
            label: 'الاشتراكات النشطة',
            value: '${revenue['activeSubscriptions'] ?? 0}',
          ),
        ],
      ),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _RevenueRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// كارت مستخدم (مدرب/متدرب)
class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String subtitle;
  final IconData icon;

  const _UserCard({
    required this.name,
    required this.email,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FitXCard(
      margin: const EdgeInsets.only(bottom: spaceSm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(color: textSecondary, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// قائمة النشاطات
class _ActivitiesList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const _ActivitiesList({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activities.take(5).map((activity) {
        return FitXCard(
          margin: const EdgeInsets.only(bottom: spaceSm),
          child: Row(
            children: [
              Icon(
                _getActivityIcon(activity['type']),
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: spaceMd),
              Expanded(
                child: Text(
                  activity['message'] ?? '',
                  style: const TextStyle(color: textPrimary, fontSize: 14),
                ),
              ),
              Text(
                _formatTime(activity['timestamp']),
                style: const TextStyle(color: textTertiary, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getActivityIcon(String? type) {
    return switch (type) {
      'new_trainee' => Icons.person_add,
      'new_trainer' => Icons.school,
      'subscription' => Icons.card_membership,
      'payment' => Icons.payment,
      _ => Icons.notifications,
    };
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());
    
    if (diff.inMinutes < 60) return '${diff.inMinutes} د';
    if (diff.inHours < 24) return '${diff.inHours} س';
    return '${diff.inDays} ي';
  }
}

/// حالة فاضية
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: textTertiary),
          const SizedBox(height: spaceMd),
          Text(
            message,
            style: const TextStyle(color: textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// حالة خطأ
class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: errorColor),
          SizedBox(height: spaceMd),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: TextStyle(color: errorColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ─── PROVIDERS ───────────────────────────────────────────────────────────

/// إحصائيات الجيم
final _gymStatsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, gymId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('gyms').doc(gymId).snapshots().map((doc) {
    if (!doc.exists) return {};
    final data = doc.data() ?? {};
    return {
      'trainees': data['traineeCount'] ?? 0,
      'trainers': data['trainerCount'] ?? 0,
      'subscriptions': data['subscriptionCount'] ?? 0,
      'revenue': data['totalRevenue'] ?? 0,
    };
  });
});

/// المدربين
final _gymTrainersProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, gymId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .where('gymId', isEqualTo: gymId)
      .where('role', isEqualTo: 'trainer')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {
            'id': doc.id,
            'name': doc.data()['name'] ?? 'بدون اسم',
            'email': doc.data()['email'] ?? '',
            'trainees': doc.data()['traineeCount'] ?? 0,
          }).toList());
});

/// المتدربين
final _gymTraineesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, gymId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .where('gymId', isEqualTo: gymId)
      .where('role', isEqualTo: 'trainee')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {
            'id': doc.id,
            'name': doc.data()['name'] ?? 'بدون اسم',
            'email': doc.data()['email'] ?? '',
            'trainerName': doc.data()['trainerName'] ?? 'غير محدد',
          }).toList());
});

/// الإيرادات
final _gymRevenueProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, gymId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('gyms').doc(gymId).snapshots().map((doc) {
    if (!doc.exists) return {};
    final data = doc.data() ?? {};
    return {
      'total': data['totalRevenue'] ?? 0,
      'monthly': data['monthlyRevenue'] ?? 0,
      'activeSubscriptions': data['activeSubscriptionCount'] ?? 0,
    };
  });
});

/// آخر النشاطات
final _recentActivitiesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, gymId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('gyms')
      .doc(gymId)
      .collection('activities')
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
