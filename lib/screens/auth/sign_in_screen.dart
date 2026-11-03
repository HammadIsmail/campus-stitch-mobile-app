import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../main_navigation_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
        _errorMessage = ApiClient.humanizeError(
          AuthState.instance.errorMessage ?? 'Sign in failed. Please check your credentials.',
        );
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
        final colors = dialogCtx.colors;

        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              ),
              title: Text(
                AppStrings.forgotPassword,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.text,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your registered campus email and we will dispatch a secure password reset link to your inbox.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      height: 1.45,
                      color: colors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (statusMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSuccess ? colors.primarySoft : colors.dangerSoft,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                        border: Border.all(
                          color: isSuccess ? colors.primary : colors.danger,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusMessage!,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: isSuccess ? colors.textOnSoft : colors.textOnDangerSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  AppTextField(
                    label: AppStrings.email,
                    placeholder: AppStrings.emailPlaceholder,
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(dialogCtx),
                  child: Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: colors.mutedText,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final emailVal = resetEmailController.text.trim();
                          if (emailVal.isEmpty) return;

                          setDialogState(() {
                            isSending = true;
                            statusMessage = null;
                          });

                          try {
                            final res = await AuthService.forgotPassword(emailVal);
                            setDialogState(() {
                              isSending = false;
                              isSuccess = res.success;
                              statusMessage = res.message ??
                                  (res.success
                                      ? 'Reset link sent! Please check your inbox.'
                                      : 'Unable to send reset link.');
                            });
                          } catch (e) {
                            setDialogState(() {
                              isSending = false;
                              isSuccess = false;
                              statusMessage = ApiClient.humanizeError(e);
                            });
                          }
                        },
                  child: isSending
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                          ),
                        )
                      : Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo + Name Brand Row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              kAppName.isNotEmpty ? kAppName[0] : 'C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      kAppName,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.02 * 20,
                        color: colors.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Welcome back header
                Text(
                  AppStrings.welcomeBack,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.02 * 30,
                    height: 1.15,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.loginSubtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    height: 1.45,
                    color: colors.mutedText,
                  ),
                ),
                const SizedBox(height: 26),

                // Error alert box
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.dangerSoft,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                      border: Border.all(color: colors.danger, width: 1),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: colors.textOnDangerSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                AppTextField(
                  label: AppStrings.email,
                  placeholder: AppStrings.emailPlaceholder,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!val.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                AppTextField(
                  label: AppStrings.password,
                  placeholder: AppStrings.passwordPlaceholder,
                  controller: _passwordController,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: _showForgotPasswordDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: AppDimensions.minTouchTarget,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Primary Log in Button
                AppButton(
                  label: AppStrings.logIn,
                  isLoading: _isLoading,
                  onPressed: _handleSignIn,
                ),
                const SizedBox(height: 24),

                // Create account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppStrings.newHere} ',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: colors.mutedText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.createAccount,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
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
