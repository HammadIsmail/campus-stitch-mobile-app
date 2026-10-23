import 'package:flutter/material.dart';
import 'core/state/theme_state.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeState.instance.init();
  runApp(const CampusStitchApp());
}

class CampusStitchApp extends StatelessWidget {
  const CampusStitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'CampuStitch',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeState.instance.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
