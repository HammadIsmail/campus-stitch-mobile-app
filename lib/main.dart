import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/state/theme_state.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/push_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeState.instance.init();
  // Initialize push notification listener & token sync
  PushNotificationService.initialize();
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
          navigatorKey: navigatorKey,
          title: kAppName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
