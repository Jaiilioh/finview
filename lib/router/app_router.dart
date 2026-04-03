import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/insights/month_recap_screen.dart';
import '../screens/shell_screen.dart';

class AppRouter {
  static GoRouter router(AppProvider provider) {
    return GoRouter(
      initialLocation: '/dashboard',
      redirect: (context, state) {
        final onboarded = provider.onboardingCompleted;
        final isOnboarding = state.matchedLocation == '/onboarding';

        if (!onboarded && !isOnboarding) return '/onboarding';
        if (onboarded && isOnboarding) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => ShellScreen(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const DashboardScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            GoRoute(
              path: '/transactions',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const TransactionsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            GoRoute(
              path: '/goals',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GoalsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SettingsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/recap',
          builder: (context, state) => const MonthRecapScreen(),
        ),
      ],
    );
  }
}
