import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/registration_success_screen.dart';
import '../screens/home/shadcn_home_screen.dart';
import '../screens/report/shadcn_report_issue_screen.dart';
import '../screens/report/shadcn_report_details_screen.dart';
import '../screens/report/report_submitted_screen.dart';
import '../screens/feed/shadcn_community_feed_screen.dart';
import '../screens/profile/shadcn_profile_screen.dart';
import '../screens/profile/shadcn_leaderboard_screen.dart';
import '../screens/profile/my_reports_screen.dart';
import '../screens/profile/saved_reports_screen.dart';
import '../screens/profile/help_support_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';
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
      reverseTransitionDuration:
          const Duration(milliseconds: 200), // Super fast back!
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut; // Snappier curve

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static int _getIndexForLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/report')) return 1;
    if (location.startsWith('/feed')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildSlideTransition(
          child: const LoginScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => _buildSlideTransition(
          child: const RegisterScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/registration-success',
        name: 'registration-success',
        pageBuilder: (context, state) => _buildSlideTransition(
          child: const RegistrationSuccessScreen(),
          state: state,
        ),
      ),

      // Shell route for main screens with bottom nav
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            currentIndex: _getIndexForLocation(state.matchedLocation),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ShadcnHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/report',
            name: 'report',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ShadcnReportIssueScreen(),
            ),
          ),
          GoRoute(
            path: '/feed',
            name: 'feed',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ShadcnCommunityFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ShadcnProfileScreen(),
            ),
          ),
        ],
      ),

      // Routes without bottom nav - with slide transitions
      GoRoute(
        path: '/report/:id',
        name: 'report-details',
        pageBuilder: (context, state) {
          final reportId = state.pathParameters['id']!;
          return _buildSlideTransition(
            child: ShadcnReportDetailsScreen(reportId: reportId),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/report-submitted/:id',
        name: 'report-submitted',
        pageBuilder: (context, state) {
          final reportId = state.pathParameters['id']!;
          return _buildSlideTransition(
            child: ReportSubmittedScreen(
              reportId: reportId,
              issueNumber: '#${reportId.substring(0, 8).toUpperCase()}',
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        pageBuilder: (context, state) => _buildSlideTransition(
          child: const ShadcnLeaderboardScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => _buildSlideTransition(
          child: const NotificationsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/my-reports',
        name: 'my-reports',
        pageBuilder: (context, state) => _buildSlideTransition(
          child: const MyReportsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/saved-reports',
        name: 'saved-reports',
        pageBuilder: (context, state) => _buildSlideTransition(
          child: const SavedReportsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/user/:userId',
        name: 'user-profile',
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return _buildSlideTransition(
            child: UserProfileScreen(userId: userId),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/help-support',
        name: 'help-support',
        pageBuilder: (context, state) => _buildSlideTransition(
          child: const HelpSupportScreen(),
          state: state,
        ),
      ),
    ],
  );
}
