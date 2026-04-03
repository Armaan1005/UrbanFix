import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/shadcn_home_screen.dart';
import '../screens/profile/shadcn_profile_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

class AppRouter {
  // Custom slide transition - Fast and snappy
  static CustomTransitionPage<void> _buildSlideTransition({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 200), // Super fast!
      reverseTransitionDuration: const Duration(
        milliseconds: 200,
      ), // Super fast back!
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut; // Snappier curve

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static int _getIndexForLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/profile')) return 1;
    return 0;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder:
            (context, state) =>
                _buildSlideTransition(child: const LoginScreen(), state: state),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder:
            (context, state) => _buildSlideTransition(
              child: const RegisterScreen(),
              state: state,
            ),
      ),

      // Shell route for main screens with bottom nav
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            currentIndex: _getIndexForLocation(state.uri.toString()),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ShadcnHomeScreen()),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ShadcnProfileScreen()),
          ),
        ],
      ),
    ],
  );
}
