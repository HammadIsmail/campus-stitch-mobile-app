import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../core/state/auth_state.dart';
import '../core/theme/app_colors.dart';
import 'auth/sign_in_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _initializeApp();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Artificial minimum delay for brand display and session check
    await Future.wait([
      AuthState.instance.init(),
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (!mounted) return;
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Column(
            children: [
              // Center brand area
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rounded logo tile with shadow
                    Container(
                      width: 184,
                      height: 184,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(42),
                        boxShadow: [
                          BoxShadow(
                            color: colors.text.withValues(alpha: 0.18),
                            blurRadius: 32,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(42),
                        child: Image.asset(
                          'assets/images/logo-full.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // App Title
                    Text(
                      kAppName,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.02 * 34,
                        height: 1.1,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tagline
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        AppStrings.appTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: colors.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom loading bar and country tag
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar
                  Container(
                    width: 140,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return Align(
                          alignment: Alignment(-1.0 + (_progressController.value * 2.0), 0),
                          child: FractionallySizedBox(
                            widthFactor: 0.4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Footer
                  Text(
                    AppStrings.madeForUniversities,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
