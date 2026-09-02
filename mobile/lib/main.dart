import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/app_state.dart';
import 'data/app_state_scope.dart';
import 'features/onboarding/splash_screen.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      appState: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          final theme = _appState.highContrast
              ? AppTheme.highContrastTheme
              : AppTheme.lightTheme;

          return MaterialApp(
            title: 'WeatherGPT',
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _appState.highContrast
                ? ThemeMode.dark
                : _appState.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(_appState.textSizeScale),
                ),
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
