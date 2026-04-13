import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/features/home/presentation/home_screen.dart';
import 'package:fitx/src/features/statistics/presentation/statistics_screen.dart';
import 'package:fitx/src/features/workouts/presentation/workouts_screen.dart';
import 'package:fitx/src/features/nutrition/presentation/nutrition_logging_screen.dart';
import 'package:fitx/src/features/tasks/presentation/tasks_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/features/tasks/providers/task_providers.dart';

/// Provider to control the current tab from anywhere in the app
final dashboardTabProvider = StateProvider<int>((ref) => 0);

class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _navAnimController;

  final _pages = const [
    FitXHomeScreen(),
    StatisticsScreen(),
    TasksScreen(),
    WorkoutsScreen(),
    NutritionLoggingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    ref.read(dashboardTabProvider.notifier).state = index;
    _pageController.animateToPage(
      index,
      duration: defaultDuration,
      curve: defaultCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to tab changes from other screens
    final currentIndex = ref.watch(dashboardTabProvider);
    final unreadCount = ref.watch(unreadTaskCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          if (index != currentIndex) {
            ref.read(dashboardTabProvider.notifier).state = index;
          }
        },
      ),
      bottomNavigationBar: _buildBottomNav(currentIndex, unreadCount),
    );
  }

  Widget _buildBottomNav(int currentIndex, int unreadCount) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(parent: _navAnimController, curve: Curves.easeOutCubic)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: surfaceBorder.withOpacity(0.5), width: 0.5)),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: surfaceColor.withOpacity(0.8),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(icon: Icons.home_filled, label: 'الرئيسية', isSelected: currentIndex == 0, onTap: () => _onTabTapped(0)),
                    _NavItem(icon: Icons.bar_chart_rounded, label: 'الإحصائيات', isSelected: currentIndex == 1, onTap: () => _onTabTapped(1)),
                    _NavItem(icon: Icons.assignment_rounded, label: 'المهام', isSelected: currentIndex == 2, onTap: () => _onTabTapped(2), badgeCount: unreadCount),
                    _NavItem(icon: Icons.fitness_center_rounded, label: 'التمارين', isSelected: currentIndex == 3, onTap: () => _onTabTapped(3)),
                    _NavItem(icon: Icons.restaurant_rounded, label: 'التغذية', isSelected: currentIndex == 4, onTap: () => _onTabTapped(4)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: isSelected ? primaryColor : textTertiary, size: 26),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? primaryColor : textTertiary, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
