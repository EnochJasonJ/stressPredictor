import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stresspredictor/core/constants/app_constants.dart';
import 'package:stresspredictor/providers/auth_provider.dart';
import 'package:stresspredictor/screens/auth/login_screen.dart';
import 'package:stresspredictor/screens/auth/signup_screen.dart';
import 'package:stresspredictor/screens/home/home_screen.dart';
import 'package:stresspredictor/screens/intro/intro_screen.dart';
import 'package:stresspredictor/screens/predict/predict_screen.dart';
import 'package:stresspredictor/screens/profile/appearance_screen.dart';
import 'package:stresspredictor/screens/profile/help_screen.dart';
import 'package:stresspredictor/screens/profile/privacy_screen.dart';
import 'package:stresspredictor/screens/profile/profile_screen.dart';
import 'package:stresspredictor/screens/workout/workout_detail_screen.dart';
import 'package:stresspredictor/screens/workout/workout_screen.dart';

/// App router configuration using go_router.
/// Defines all navigation routes for the Stress Predictor app.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppConstants.introPath,
      debugLogDiagnostics: true,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final location = state.uri.toString();

        final onAuthRoute = location == AppConstants.loginPath ||
            location == AppConstants.signupPath;
        final onIntro = location == AppConstants.introPath;

        // While checking auth state, don't redirect.
        if (authProvider.isLoading) {
          return null;
        }

        // If user is not logged in and not on a public route, redirect to login.
        if (!isLoggedIn && !onAuthRoute && !onIntro) {
          return AppConstants.loginPath;
        }

        // If user is logged in and on login/signup/intro, redirect to home.
        if (isLoggedIn && (onAuthRoute || onIntro)) {
          return AppConstants.homePath;
        }

        return null; // No redirect.
      },
      routes: [
        // Public routes
        GoRoute(
          path: AppConstants.introPath,
          name: 'intro',
          builder: (context, state) => const IntroScreen(),
        ),
        GoRoute(
          path: AppConstants.loginPath,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppConstants.signupPath,
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // Manual predict screen – shown above the shell (full screen)
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppConstants.predictPath,
          name: 'predict',
          builder: (context, state) => const PredictScreen(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppConstants.workoutDetailPath,
          name: 'workoutDetail',
          builder: (context, state) {
            final extra = state.extra as Map<String, String>;
            return WorkoutDetailScreen(
              name: extra['name']!,
              duration: extra['duration']!,
              difficulty: extra['difficulty']!,
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppConstants.appearancePath,
          name: 'appearance',
          builder: (context, state) => const AppearanceScreen(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppConstants.privacyPath,
          name: 'privacy',
          builder: (context, state) => const PrivacyScreen(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppConstants.helpPath,
          name: 'help',
          builder: (context, state) => const HelpScreen(),
        ),

        // Shell route for bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(
              path: AppConstants.homePath,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: AppConstants.workoutPath,
              name: 'workout',
              builder: (context, state) => const WorkoutScreen(),
            ),
            GoRoute(
              path: AppConstants.profilePath,
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shell widget containing the persistent bottom navigation bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(AppConstants.homePath);
        break;
      case 1:
        context.go(AppConstants.workoutPath);
        break;
      case 2:
        context.go(AppConstants.profilePath);
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppConstants.homePath)) return 0;
    if (location.startsWith(AppConstants.workoutPath)) return 1;
    if (location.startsWith(AppConstants.profilePath)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _calculateSelectedIndex(context);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
