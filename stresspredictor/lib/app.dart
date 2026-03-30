import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:stresspredictor/core/theme/app_theme.dart';
import 'package:stresspredictor/providers/auth_provider.dart';
import 'package:stresspredictor/providers/profile_provider.dart';
import 'package:stresspredictor/providers/stress_provider.dart';
import 'package:stresspredictor/providers/theme_provider.dart';
import 'package:stresspredictor/router/app_router.dart';

/// App widget - root MaterialApp wrapped with MultiProvider for state management.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider()..init();
    _router = AppRouter.createRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: _authProvider,
        ),
        ChangeNotifierProvider(create: (_) => StressProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Stress Predictor',
            debugShowCheckedModeBanner: false,
            // Highly optimized native rendering (no global composition gradients)
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}