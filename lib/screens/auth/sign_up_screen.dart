import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/tenant_model.dart';
import '../../services/tenant_service.dart';
import '../main_navigation_screen.dart';

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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  @override
  void dispose() {
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
      setState(() => _error = 'Please fill out all required fields');
      return;
    }

    if (_selectedUniversity == null || _selectedCampus == null) {
      setState(() => _error = 'Please select your University and Campus');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final success = await AuthState.instance.signUp(
      name: name,
      email: email,
      password: password,
      studentId: studentId,
      universityId: _selectedUniversity!.id,
      universityName: _selectedUniversity!.shortName.isNotEmpty
          ? _selectedUniversity!.shortName
          : _selectedUniversity!.name,
      campusId: _selectedCampus!.id,
      campusName: _selectedCampus!.name,
      program: program,
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
        _error = AuthState.instance.errorMessage ?? 'Registration failed. Try again.';
      });
    }
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

              // Error Banner
              if (_error != null) ...[
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
                decoration: const InputDecoration(
                  hintText: 'student@uet.edu.pk',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
