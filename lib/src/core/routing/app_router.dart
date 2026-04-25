import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/screens/auth/views/login_screen.dart';
import 'package:fitx/screens/auth/views/signup_screen.dart';
import 'package:fitx/screens/auth/views/forgot_password_screen.dart';
import 'package:fitx/src/core/auth/app_role.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/features/auth/presentation/role_selection_screen.dart';
import 'package:fitx/src/features/dashboard/presentation/dashboard_shell.dart';
import 'package:fitx/src/features/dashboard/presentation/super_admin_control_screen.dart';
import 'package:fitx/src/features/trainer/presentation/trainer_dashboard_screen.dart';
import 'package:fitx/src/features/gym/presentation/gym_dashboard_screen.dart';
import 'package:fitx/src/features/profile/presentation/profile_screen_fitx.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);
  final role = ref.watch(currentUserRoleProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    routes: [
      // ────────────────────────────────────────────────────────
      // Auth Routes
      // ────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ────────────────────────────────────────────────────────
      // Role-Based Dashboard Routes
      // ────────────────────────────────────────────────────────

      // Trainee Dashboard (Default)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardShell(),
      ),

      // Trainer Dashboard
      GoRoute(
        path: '/trainer-dashboard',
        name: 'trainerDashboard',
        builder: (context, state) => const TrainerDashboardScreen(),
      ),

      // Gym Dashboard
      GoRoute(
        path: '/gym-dashboard',
        name: 'gymDashboard',
        builder: (context, state) => const GymDashboardScreen(),
      ),

      // Super Admin Control Panel
      GoRoute(
        path: '/admin-control',
        name: 'adminControl',
        builder: (context, state) => const SuperAdminControlScreen(),
      ),

      // ────────────────────────────────────────────────────────
      // Profile Route
      // ────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreenFitX(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = auth.value != null;
      final userRole = role.value;
      final hasRole = userRole != null;
      final location = state.uri.path;

      // ────────────────────────────────────────────────────────
      // NOT LOGGED IN — redirect to login
      // ────────────────────────────────────────────────────────
      if (!isLoggedIn) {
        if (location == '/login' ||
            location == '/signup' ||
            location == '/forgot-password') {
          return null; // Allow access to auth pages
        }
        return '/login';
      }

      // ────────────────────────────────────────────────────────
      // LOGGED IN BUT NO ROLE — redirect to role selection
      // ────────────────────────────────────────────────────────
      if (!hasRole && location != '/role-selection') {
        return '/role-selection';
      }

      // ────────────────────────────────────────────────────────
      // ROLE-BASED REDIRECTS: Send each role to their dashboard
      // ────────────────────────────────────────────────────────
      if (hasRole) {
        final isOnAuthPage = location == '/login' ||
            location == '/signup' ||
            location == '/role-selection';

        // Check if user is on their correct dashboard
        final isOnCorrectDashboard = switch (userRole) {
          AppRole.trainee => location == '/dashboard',
          AppRole.trainer => location == '/trainer-dashboard',
          AppRole.gym => location == '/gym-dashboard',
          AppRole.admin || AppRole.superAdmin => location == '/admin-control',
        };

        // If on auth page or wrong dashboard, redirect to correct one
        if (isOnAuthPage ||
            (location.startsWith('/') &&
                !isOnCorrectDashboard &&
                location != '/profile' &&
                location != '/admin-control')) {
          return switch (userRole) {
            AppRole.trainee => '/dashboard',
            AppRole.trainer => '/trainer-dashboard',
            AppRole.gym => '/gym-dashboard',
            AppRole.admin || AppRole.superAdmin => '/admin-control',
          };
        }
      }

      return null;
    },
  );
});
