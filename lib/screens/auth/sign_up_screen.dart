import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../models/tenant_model.dart';
import '../../services/tenant_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../main_navigation_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  List<University> _universities = [];
  University? _selectedUniversity;
  Campus? _selectedCampus;

  bool _isLoadingUniversities = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    setState(() => _isLoadingUniversities = true);
    try {
      final list = await TenantService.getUniversities();
      if (!mounted) return;
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
      if (mounted) setState(() => _isLoadingUniversities = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUniversity == null || _selectedCampus == null) {
      setState(() => _errorMessage = 'Please select your university and campus.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await AuthState.instance.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      universityId: _selectedUniversity!.id,
      universityName: _selectedUniversity!.shortName,
      campusId: _selectedCampus!.id,
      campusName: _selectedCampus!.name,
      program: 'BS Student',
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = ApiClient.humanizeError(
          AuthState.instance.errorMessage ?? 'Registration failed. Please try again.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + App Name Header
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
                const SizedBox(height: 22),

                // Title & Subtitle
                Text(
                  AppStrings.createCampusAccount,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.02 * 28,
                    height: 1.15,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.registerSubtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    height: 1.45,
                    color: colors.mutedText,
                  ),
                ),
                const SizedBox(height: 20),

                // Error Message Box
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

                // Full Name
                AppTextField(
                  label: AppStrings.fullName,
                  placeholder: AppStrings.fullNamePlaceholder,
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // University Dropdown
                Text(
                  AppStrings.university,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 6),
                _isLoadingUniversities
                    ? Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                          border: Border.all(color: colors.inputBorder),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'Loading universities...',
                          style: TextStyle(color: colors.mutedText, fontSize: 14),
                        ),
                      )
                    : Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                          border: Border.all(color: colors.inputBorder, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<University>(
                            value: _selectedUniversity,
                            isExpanded: true,
                            dropdownColor: colors.surface,
                            icon: Icon(Icons.arrow_drop_down, color: colors.text),
                            items: _universities.map((uni) {
                              return DropdownMenuItem<University>(
                                value: uni,
                                child: Text(
                                  uni.name,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    color: colors.text,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (uni) {
                              if (uni == null) return;
                              setState(() {
                                _selectedUniversity = uni;
                                _selectedCampus = uni.campuses.isNotEmpty ? uni.campuses.first : null;
                              });
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 14),

                // Campus Dropdown
                Text(
                  AppStrings.campus,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: colors.inputBorder, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Campus>(
                      value: _selectedCampus,
                      isExpanded: true,
                      dropdownColor: colors.surface,
                      icon: Icon(Icons.arrow_drop_down, color: colors.text),
                      items: (_selectedUniversity?.campuses ?? []).map((camp) {
                        return DropdownMenuItem<Campus>(
                          value: camp,
                          child: Text(
                            camp.name,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              color: colors.text,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (camp) {
                        if (camp == null) return;
                        setState(() => _selectedCampus = camp);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Email
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
                const SizedBox(height: 14),

                // Password
                AppTextField(
                  label: AppStrings.password,
                  placeholder: AppStrings.passwordMinLength,
                  controller: _passwordController,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                // Submit button
                AppButton(
                  label: AppStrings.submitCreateAccount,
                  isLoading: _isSubmitting,
                  onPressed: _handleSignUp,
                ),
                const SizedBox(height: 18),

                // Footer login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${AppStrings.alreadyRegistered} ',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: colors.mutedText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          AppStrings.logIn,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
