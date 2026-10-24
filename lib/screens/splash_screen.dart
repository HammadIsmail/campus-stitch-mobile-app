import 'package:flutter/material.dart';
import '../core/state/auth_state.dart';
import '../core/theme/app_theme.dart';
import '../services/app_update_service.dart';
import 'auth/sign_in_screen.dart';
import 'main_navigation_screen.dart';
import 'update/update_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Initialize auth session and check for in-app self updates concurrently
    final results = await Future.wait([
      AuthState.instance.init(),
      AppUpdateService.checkForUpdate(),
    ]);

    if (!mounted) return;

    final updateResult = results[1] as UpdateCheckResult;

    // 2. If a new update is published by admin:
    if (updateResult.hasUpdate && updateResult.versionInfo != null) {
      if (updateResult.isForceUpdate) {
        // Enforce mandatory blocking update screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UpdateScreen(
              versionInfo: updateResult.versionInfo!,
              isForce: true,
            ),
          ),
        );
        return;
      } else {
        // Optional update: show update screen with "Maybe Later" callback
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UpdateScreen(
              versionInfo: updateResult.versionInfo!,
              isForce: false,
              onDismiss: () => _navigateToNextScreen(),
            ),
          ),
        );
        return;
      }
    }

    // 3. No update needed -> Proceed to user dashboard or login
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    if (AuthState.instance.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.zinc800, width: 2),
              ),
              child: const Center(
                child: Text(
                  'CS',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'CampuStitch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pakistan Multi-Tenant Campus SuperApp',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.zinc500,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
