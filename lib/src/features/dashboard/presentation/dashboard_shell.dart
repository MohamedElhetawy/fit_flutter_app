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

/// Premium glass-morphic bottom navigation shell.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
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

    // immersive status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: bgColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: defaultDuration,
      curve: defaultCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final unreadCount = ref.watch(unreadTaskCountProvider);
        return _buildScaffold(unreadCount);
      },
    );
  }

  Widget _buildScaffold(AsyncValue<int> unreadCount) {
    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: Stack(
        children: [
          // ── Background ambient glow ────────────────
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Pages ──────────────────────────────────
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(unreadCount),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  BOTTOM NAV — Modern Frosted Glass with Glassmorphism
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomNav(AsyncValue<int> unreadCount) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _navAnimController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: surfaceBorder.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.4),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                height: 72 + MediaQuery.of(context).padding.bottom,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: _currentIndex == 0,
                      onTap: () => _onTabTapped(0),
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Stats',
                      isSelected: _currentIndex == 1,
                      onTap: () => _onTabTapped(1),
                    ),
                    _NavItem(
                      icon: Icons.task_alt_rounded,
                      label: 'Tasks',
                      isSelected: _currentIndex == 2,
                      onTap: () => _onTabTapped(2),
                      badgeCount: unreadCount.valueOrNull ?? 0,
                    ),
                    _NavItem(
                      icon: Icons.fitness_center_rounded,
                      label: 'Workout',
                      isSelected: _currentIndex == 3,
                      onTap: () => _onTabTapped(3),
                    ),
                    _NavItem(
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Nutrition',
                      isSelected: _currentIndex == 4,
                      onTap: () => _onTabTapped(4),
                    ),
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

// ═══════════════════════════════════════════════════════════════
//  NAV ITEM — Modern animated navigation tab with ripple effect
// ═══════════════════════════════════════════════════════════════
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected && widget.isSelected) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.15).animate(
                CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? primaryColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected ? primaryColor : textTertiary,
                      size: widget.isSelected ? 26 : 24,
                    ),
                  ),
                  // Badge
                  if (widget.badgeCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            widget.badgeCount > 9
                                ? '9+'
                                : widget.badgeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: widget.isSelected ? primaryColor : textTertiary,
                fontSize: 11,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: widget.isSelected ? 0.3 : 0,
              ),
              child: Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
