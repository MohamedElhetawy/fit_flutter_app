import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitx/screens/auth/views/login_screen.dart';
import 'package:fitx/screens/auth/views/signup_screen.dart';
import 'package:fitx/screens/auth/views/forgot_password_screen.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/features/auth/presentation/role_selection_screen.dart';
import 'package:fitx/src/features/dashboard/presentation/dashboard_shell.dart';
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
      // Dashboard Routes (Main App with Bottom Navigation)
      // ────────────────────────────────────────────────────────
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardShell(),
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
      final hasRole = role.value != null;
      final location = state.uri.path;

      // ────────────────────────────────────────────────────────
      // NOT LOGGED IN — redirect to login
      // ────────────────────────────────────────────────────────
      if (!isLoggedIn) {
        if (location == '/login' || location == '/signup' || location == '/forgot-password') {
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
      // LOGGED IN WITH ROLE — redirect to dashboard from auth
      // ────────────────────────────────────────────────────────
      if (hasRole &&
          (location == '/login' ||
              location == '/signup' ||
              location == '/role-selection')) {
        return '/dashboard';
      }

      return null;
    },
  );
});
