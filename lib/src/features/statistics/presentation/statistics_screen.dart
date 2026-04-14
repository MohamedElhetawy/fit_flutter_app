import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/features/dashboard/data/home_providers.dart';
import 'package:fitx/src/shared/widgets/fitx_card.dart';
import 'package:fitx/src/shared/widgets/section_header.dart';
import 'package:fitx/src/shared/widgets/fitx_shimmer.dart';

// ─── STATISTICS SCREEN (CLEAN VERSION) ────────────────────

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(dailyHealthProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _StatsAppBar(),
            _DateSelectorRow(),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _HealthScoreCard(),
                  const SizedBox(height: spaceLg),
                  const SectionHeader(title: 'تفصيل العناصر الغذائية', actionText: 'السجل'),
                  const SizedBox(height: spaceSm),
                  _NutrientsGrid(healthAsync),
                  const SizedBox(height: spaceLg),
                  _ActivityAnalysisCard(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SUB-WIDGETS (MODULAR) ────────────────────────────────

class _StatsAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SliverPadding(
      padding: EdgeInsets.fromLTRB(defaultPadding, spaceMd, defaultPadding, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            _CircleActionBtn(icon: Icons.calendar_month_rounded, filled: true),
            Expanded(child: Text('الأداء', textAlign: TextAlign.center, style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(width: 44), // Balance the row
          ],
        ),
      ),
    );
  }
}

class _DateSelectorRow extends StatefulWidget {
  @override
  State<_DateSelectorRow> createState() => _DateSelectorRowState();
}

class _DateSelectorRowState extends State<_DateSelectorRow> {
  int _selectedIndex = 3;
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: spaceLg),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            itemCount: 7,
            itemBuilder: (context, i) => _DateChip(
              index: i,
              isSelected: i == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthScoreCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(dailyHealthProvider).valueOrNull;
    return FitXCard(
      color: surfaceColorLight,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('النتيجة الإجمالية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(health != null && health.steps > 5000 ? 'نشيط وصحي! 🔥' : 'وقت الحركة!', style: const TextStyle(color: textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const CircularProgressIndicator(value: 0.75, strokeWidth: 5, backgroundColor: surfaceBorder, valueColor: AlwaysStoppedAnimation(primaryColor)),
        ],
      ),
    );
  }
}

class _NutrientsGrid extends StatelessWidget {
  final AsyncValue<DailyHealthMetrics> healthAsync;
  const _NutrientsGrid(this.healthAsync);

  @override
  Widget build(BuildContext context) {
    return healthAsync.when(
      data: (health) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: spaceSm,
        crossAxisSpacing: spaceSm,
        childAspectRatio: 1.3,
        children: [
          _StatTile(label: 'بروتين', value: '${health.protein}g', icon: Icons.egg, color: Colors.blue),
          _StatTile(label: 'كارب', value: '${health.carbs}g', icon: Icons.bakery_dining, color: Colors.orange),
          _StatTile(label: 'دهون', value: '${health.fat}g', icon: Icons.opacity, color: Colors.red),
          _StatTile(label: 'الهدف', value: '${health.caloriesConsumed}', icon: Icons.flag, color: primaryColor),
        ],
      ),
      loading: () => const FitXShimmerCard(height: 200),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ActivityAnalysisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FitXCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الأسبوع', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(color: surfaceColorLight.withOpacity(0.3), borderRadius: BorderRadius.circular(radiusMd)),
            child: const Center(child: Icon(Icons.show_chart, color: primaryColor, size: 40)),
          ),
        ],
      ),
    );
  }
}

// ─── SHARED MINI COMPONENTS ───────────────────────────────

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;
  // ignore: unused_element_parameter
  const _CircleActionBtn({required this.icon, this.filled = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: filled ? primaryColor : surfaceColor, borderRadius: BorderRadius.circular(radiusSm), border: filled ? null : Border.all(color: surfaceBorder)),
      child: Icon(icon, color: filled ? const Color(0xFF1A1A00) : textSecondary, size: 20),
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: child) : child;
  }
}

class _DateChip extends StatelessWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  const _DateChip({required this.index, required this.isSelected, required this.onTap});

  String _formatDate(DateTime date) {
    final days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: isSelected ? primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(radiusFull), border: isSelected ? null : Border.all(color: surfaceBorder)),
        child: Center(child: Text(index == 3 ? 'اليوم' : _formatDate(DateTime.now().subtract(Duration(days: 3 - index))), style: TextStyle(color: isSelected ? Colors.black : textSecondary, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return FitXCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: grandisExtendedFont)),
          Text(label, style: const TextStyle(color: textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
