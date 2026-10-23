import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/tenant_model.dart';
import '../../services/auth_service.dart';
import '../../services/tenant_service.dart';
import '../main_navigation_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _programController = TextEditingController(text: 'BS Computer Science');

  List<University> _universities = [];
  University? _selectedUniversity;
  Campus? _selectedCampus;

  bool _isLoadingUniversities = true;
  bool _isSubmitting = false;
  bool _emailExists = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    if (_emailExists || _error != null) {
      setState(() {
        _emailExists = false;
        _error = null;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    setState(() => _isLoadingUniversities = true);
    try {
      final list = await TenantService.getUniversities();
      setState(() {
        _universities = list;
        if (list.isNotEmpty) {
          _selectedUniversity = list.first;
          if (_selectedUniversity!.campuses.isNotEmpty) {
            _selectedCampus = _selectedUniversity!.campuses.first;
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading universities: $e');
    } finally {
      setState(() => _isLoadingUniversities = false);
    }
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final studentId = _studentIdController.text.trim();
    final password = _passwordController.text.trim();
    final program = _programController.text.trim();

    if (name.isEmpty || email.isEmpty || studentId.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please fill out all required fields';
        _emailExists = false;
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _error = 'Please enter a valid email address';
        _emailExists = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters long';
        _emailExists = false;
      });
      return;
    }

    if (_selectedUniversity == null || _selectedCampus == null) {
      setState(() {
        _error = 'Please select your University and Campus';
        _emailExists = false;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
      _emailExists = false;
    });

    // 1. Pre-flight check: verify email uniqueness
    try {
      final emailCheck = await AuthService.checkEmail(email);
      if (emailCheck.data is Map && (emailCheck.data as Map)['exists'] == true) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _emailExists = true;
          _error = 'An account with this email already exists. Please sign in instead.';
        });
        return;
      }
    } catch (_) {
      // Continue if network check fails, server will validate
    }

    // 2. Request 6-digit OTP verification code
    final otpRes = await AuthService.sendOtp(email);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!otpRes.success) {
      if (otpRes.statusCode == 409 || (otpRes.message?.toLowerCase().contains('already exists') ?? false)) {
        setState(() {
          _emailExists = true;
          _error = 'An account with this email already exists. Please sign in instead.';
        });
        return;
      }
      setState(() {
        _error = ApiClient.humanizeError(otpRes.message, otpRes.statusCode);
      });
      return;
    }

    // 3. Prompt user for OTP in a dialog
    if (!mounted) return;
    _showOtpDialog(
      name: name,
      email: email,
      password: password,
      studentId: studentId,
      program: program,
      universityId: _selectedUniversity!.id,
      universityName: _selectedUniversity!.shortName.isNotEmpty
          ? _selectedUniversity!.shortName
          : _selectedUniversity!.name,
      campusId: _selectedCampus!.id,
      campusName: _selectedCampus!.name,
    );
  }

  Future<void> _showOtpDialog({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String program,
    required String universityId,
    required String universityName,
    required String campusId,
    required String campusName,
  }) async {
    final otpController = TextEditingController();
    int resendCooldown = 60;
    Timer? countdownTimer;
    bool isVerifying = false;
    String? otpError;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (resendCooldown > 0) {
                setDialogState(() {
                  resendCooldown--;
                });
              } else {
                timer.cancel();
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.mark_email_read_outlined, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Verify Your Email',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.zinc400
                            : AppColors.zinc600,
                      ),
                      children: [
                        const TextSpan(text: 'We sent a 6-digit verification code to\n'),
                        TextSpan(
                          text: email,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        const TextSpan(text: '. Enter it below to activate your student account.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (otpError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        otpError!,
                        style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8,
                    ),
                    decoration: const InputDecoration(
                      hintText: '000000',
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Didn\'t receive code? ',
                        style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                      ),
                      resendCooldown > 0
                          ? Text(
                              'Resend in ${resendCooldown}s',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.zinc500),
                            )
                          : GestureDetector(
                              onTap: () async {
                                final res = await AuthService.sendOtp(email);
                                setDialogState(() {
                                  if (res.success) {
                                    resendCooldown = 60;
                                    otpError = null;
                                    countdownTimer?.cancel();
                                    countdownTimer = null;
                                  } else {
                                    otpError = ApiClient.humanizeError(res.message, res.statusCode);
                                  }
                                });
                              },
                              child: const Text(
                                'Resend Code',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    countdownTimer?.cancel();
                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          final code = otpController.text.trim();
                          if (code.length != 6) {
                            setDialogState(() {
                              otpError = 'Please enter all 6 digits of the code.';
                            });
                            return;
                          }

                          setDialogState(() {
                            isVerifying = true;
                            otpError = null;
                          });

                          final rootNav = Navigator.of(context);
                          final dialogNav = Navigator.of(dialogCtx);

                          final success = await AuthState.instance.signUp(
                            name: name,
                            email: email,
                            password: password,
                            studentId: studentId,
                            universityId: universityId,
                            universityName: universityName,
                            campusId: campusId,
                            campusName: campusName,
                            program: program,
                            code: code,
                          );

                          if (success) {
                            countdownTimer?.cancel();
                            dialogNav.pop();
                            rootNav.pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                              (route) => false,
                            );
                          } else {
                            final err = ApiClient.humanizeError(AuthState.instance.errorMessage ?? 'Verification failed. Please try again.');
                            if (err.toLowerCase().contains('already exists')) {
                              countdownTimer?.cancel();
                              dialogNav.pop();
                              if (mounted) {
                                setState(() {
                                  _emailExists = true;
                                  _error = 'An account with this email already exists. Please sign in instead.';
                                });
                              }
                            } else {
                              setDialogState(() {
                                isVerifying = false;
                                otpError = err;
                              });
                            }
                          }
                        },
                  child: isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify & Register'),
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
      appBar: AppBar(
        title: const Text('Student Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Join Your Campus Network',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select your University and Campus for instant data isolation and verified student access.',
                style: TextStyle(fontSize: 12, color: AppColors.zinc500),
              ),
              const SizedBox(height: 20),

              // Duplicate Email Alert Banner (OWASP & User Flow enhancement)
              if (_emailExists) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.amber),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Already Exists',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'An account with this email address already exists in CampusStitch. Please sign in to access your profile.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.login, size: 16),
                          label: const Text('Sign in to your account', style: TextStyle(fontWeight: FontWeight.w700)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
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
                ),
                const SizedBox(height: 16),
              ],

              // 1. University Selection
              const Text(
                '1. Select University',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              _isLoadingUniversities
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.zinc900
                            : AppColors.zinc100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.zinc800
                              : AppColors.zinc200,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<University>(
                          isExpanded: true,
                          value: _selectedUniversity,
                          items: _universities.map((uni) {
                            return DropdownMenuItem<University>(
                              value: uni,
                              child: Text(
                                '${uni.name} (${uni.shortName})',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (uni) {
                            if (uni != null) {
                              setState(() {
                                _selectedUniversity = uni;
                                _selectedCampus = uni.campuses.isNotEmpty ? uni.campuses.first : null;
                              });
                            }
                          },
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              // 2. Campus Selection (Cascading from selected university)
              const Text(
                '2. Select Campus',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.zinc900
                      : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.zinc800
                        : AppColors.zinc200,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Campus>(
                    isExpanded: true,
                    value: _selectedCampus,
                    hint: const Text('Select your campus', style: TextStyle(fontSize: 13)),
                    items: (_selectedUniversity?.campuses ?? []).map((camp) {
                      return DropdownMenuItem<Campus>(
                        value: camp,
                        child: Text(
                          camp.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (camp) {
                      if (camp != null) {
                        setState(() => _selectedCampus = camp);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Full Name
              const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Hammad Ismail',
                  prefixIcon: Icon(Icons.person_outline, size: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Student Roll / ID
              const Text('Student ID / Roll No', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _studentIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: '2021-CS-101',
                  prefixIcon: Icon(Icons.badge_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Degree Program
              const Text('Degree Program', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _programController,
                decoration: const InputDecoration(
                  hintText: 'BS Computer Science',
                  prefixIcon: Icon(Icons.school_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              const Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'student@campus.edu.pk',
                  prefixIcon: const Icon(Icons.email_outlined, size: 18),
                  enabledBorder: _emailExists
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.amber, width: 1.5),
                        )
                      : null,
                  focusedBorder: _emailExists
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.amber, width: 2),
                        )
                      : null,
                  helperText: _emailExists ? 'An account already exists with this email' : null,
                  helperStyle: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, size: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSignUp,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Complete Registration'),
              ),
              const SizedBox(height: 16),

              // Consent Footnote
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    const Text(
                      'By registering, you agree to CampuStitch',
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
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
