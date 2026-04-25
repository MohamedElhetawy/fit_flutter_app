import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import 'package:fitx/src/shared/widgets/fitx_shimmer.dart';
// Firestore provider is used in the data layer; presentation consumes typed providers.
import 'package:fitx/src/features/gym/data/gym_providers.dart';
import 'package:fitx/src/features/gym/data/gym_models.dart';

/// Gym Dashboard - للمديرين والجيمات
/// إحصائيات الجيم، المدربين، المتدربين، الاشتراكات
class GymDashboardScreen extends ConsumerStatefulWidget {
  const GymDashboardScreen({super.key});

  @override
  ConsumerState<GymDashboardScreen> createState() => _GymDashboardScreenState();
}

class _GymDashboardScreenState extends ConsumerState<GymDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late final TabController _tabController;
  final List<bool> _loadedTabs = [true, false, false, false];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final index = _tabController.index;
      if (!_loadedTabs[index]) {
        setState(() => _loadedTabs[index] = true);
      }
      setState(() => _selectedTab = index);
    }
  }

  void _onTabTapped(int index) {
    if (!_loadedTabs[index]) {
      setState(() => _loadedTabs[index] = true);
    }
    setState(() => _selectedTab = index);
    _tabController.animateTo(index);
  }

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
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: surfaceBorder,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          onTap: _onTabTapped,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'الرئيسية'),
            Tab(icon: Icon(Icons.people), text: 'المدربين'),
            Tab(icon: Icon(Icons.fitness_center), text: 'المتدربين'),
            Tab(icon: Icon(Icons.attach_money), text: 'المالية'),
          ],
        ),
      ),
      body: _buildLazyTabBody(uid),
    );
  }

  Widget _buildLazyTabBody(String uid) {
    // Lazy loading: only build tabs that have been loaded
    final tabs = [
      _loadedTabs[0] ? _OverviewTab(uid: uid) : const SizedBox.shrink(),
      _loadedTabs[1] ? _TrainersTab(uid: uid) : const SizedBox.shrink(),
      _loadedTabs[2] ? _TraineesTab(uid: uid) : const SizedBox.shrink(),
      _loadedTabs[3] ? _FinanceTab(uid: uid) : const SizedBox.shrink(),
    ];

    return IndexedStack(
      index: _selectedTab,
      children: tabs,
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
          ref.watch(gymOverviewProvider(uid)).when(
                data: (overview) => _StatsGrid(stats: overview.stats),
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

          ref.watch(gymActivitiesProvider(uid)).when(
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
  final GymStats stats;

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
          value: stats.trainees.toString(),
          icon: Icons.fitness_center,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'المدربين',
          value: stats.trainers.toString(),
          icon: Icons.school,
          color: Colors.green,
        ),
        _StatCard(
          title: 'الاشتراكات',
          value: stats.subscriptions.toString(),
          icon: Icons.card_membership,
          color: primaryColor,
        ),
        _StatCard(
          title: 'الإيرادات',
          value: '${stats.revenue} ج.م',
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
    return ref.watch(gymTrainersProvider(uid)).when(
          data: (trainers) {
            if (trainers.isEmpty) {
              return const _EmptyState(
                  message: 'لا يوجد مدربين مرتبطين بالجيم');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: trainers.length,
              itemBuilder: (context, index) {
                final trainer = trainers[index];
                return _UserCard(
                  name: trainer.name,
                  email: trainer.email,
                  subtitle: '${trainer.traineeCount} متدرب',
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
    return ref.watch(gymTraineesProvider(uid)).when(
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
                  name: trainee.name,
                  email: trainee.email,
                  subtitle: 'مدرب: ${trainee.trainerName}',
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
          ref.watch(gymOverviewProvider(uid)).when(
                data: (overview) => _RevenueCard(revenue: overview.revenue),
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
  final GymRevenue revenue;

  const _RevenueCard({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return FitXCard(
      child: Column(
        children: [
          _RevenueRow(
            label: 'إجمالي الإيرادات',
            value: '${revenue.total} ج.م',
            isBold: true,
          ),
          const Divider(color: surfaceBorder),
          _RevenueRow(
            label: 'هذا الشهر',
            value: '${revenue.monthly} ج.م',
          ),
          _RevenueRow(
            label: 'الاشتراكات النشطة',
            value: '${revenue.activeSubscriptions}',
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
              color: primaryColor.withAlpha(26),
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
  final List<GymActivity> activities;

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
                _getActivityIcon(activity.type),
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: spaceMd),
              Expanded(
                child: Text(
                  activity.message,
                  style: const TextStyle(color: textPrimary, fontSize: 14),
                ),
              ),
              Text(
                _formatTime(activity.timestamp),
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

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

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

// Providers moved to data layer: lib/src/features/gym/data/gym_providers.dart
