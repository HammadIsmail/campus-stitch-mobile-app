import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../main_navigation_screen.dart';
import 'sign_up_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both your campus email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await AuthState.instance.signIn(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      setState(() {
        _error = ApiClient.humanizeError(AuthState.instance.errorMessage ?? 'Sign in failed. Please check your credentials.');
      });
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    bool isSending = false;
    String? statusMessage;
    bool isSuccess = false;

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter your registered campus email and we will dispatch a secure password reset link to your inbox.',
                    style: TextStyle(fontSize: 13, color: AppColors.zinc500),
                  ),
                  const SizedBox(height: 16),
                  if (statusMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        statusMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSuccess ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!isSuccess)
                    TextField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'student@campus.edu.pk',
                        prefixIcon: Icon(Icons.mail_outline, size: 18),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(isSuccess ? 'Close' : 'Cancel'),
                ),
                if (!isSuccess)
                  ElevatedButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            final email = resetEmailController.text.trim();
                            if (email.isEmpty || !email.contains('@')) {
                              setDialogState(() {
                                statusMessage = 'Please enter a valid email address';
                                isSuccess = false;
                              });
                              return;
                            }
                            setDialogState(() {
                              isSending = true;
                              statusMessage = null;
                            });
                            final res = await AuthService.forgotPassword(email);
                            setDialogState(() {
                              isSending = false;
                              if (res.success) {
                                isSuccess = true;
                                statusMessage = 'Reset instructions sent! Please check your email inbox.';
                              } else {
                                isSuccess = false;
                                statusMessage = ApiClient.humanizeError(res.message, res.statusCode);
                              }
                            });
                          },
                    child: isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Send Reset Link'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to CampuStitch',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Multi-tenant campus life, commute & verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.zinc500,
                  ),
                ),
                const SizedBox(height: 12),

                // Error Banner
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_error!.toLowerCase().contains('invalid') ||
                            _error!.toLowerCase().contains('credential') ||
                            _error!.toLowerCase().contains('not found')) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_forward, size: 13, color: AppColors.error),
                                SizedBox(width: 4),
                                Text(
                                  'Don\'t have an account? Register here',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                const Text(
                  'Email Address',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'student@campus.edu.pk',
                    prefixIcon: Icon(Icons.mail_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    GestureDetector(
                      onTap: _showForgotPasswordDialog,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In to Campus'),
                ),
                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account? ',
                      style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Register Student',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Terms & Privacy Footnote
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    const Text(
                      'By continuing, you agree to our',
                      style: TextStyle(fontSize: 11, color: AppColors.zinc500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TermsScreen()),
                        );
                      },
                      child: const Text(
                        'Terms',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(
                      '&',
                      style: TextStyle(fontSize: 11, color: AppColors.zinc500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                        );
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
