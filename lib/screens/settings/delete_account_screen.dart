import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/api/api_constants.dart';
import '../../core/storage/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../services/bike_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/sub_header.dart';
import '../auth/sign_in_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = true;
  bool _isDeleting = false;
  int _activeRentalsCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkActiveRentals();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkActiveRentals() async {
    setState(() => _isLoading = true);
    try {
      final reqs = await BikeService.getRequests();
      final active = reqs.where((r) => r.isBooked).length;
      if (mounted) {
        setState(() {
          _activeRentalsCount = active;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password to confirm');
      return;
    }

    if (_activeRentalsCount > 0) {
      setState(() => _errorMessage = 'Cannot delete account with an active rental');
      return;
    }

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    final user = await SessionStore.getUser();
    final token = SessionStore.token;

    try {
      final res = await http.delete(
        Uri.parse(ApiConstants.profile),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': user?.id,
          'email': user?.email,
          'password': password,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        await SessionStore.clearSession();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isDeleting = false;
            _errorMessage = data['error'] ?? 'Could not delete account. Check password.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _errorMessage = 'Network error while requesting deletion.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Delete account',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Danger Warning Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.triangleAlert, size: 22, color: colors.danger),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 14, height: 1.45, color: colors.textPrimary),
                                children: const [
                                  TextSpan(
                                    text: 'This cannot be undone. ',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  TextSpan(
                                    text: 'Your account and everything you posted will be removed.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "What will be deleted" Section
                    Text(
                      'What will be deleted',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        children: [
                          _buildDeletedRow('Your profile, ratings and reviews', colors, showDivider: true),
                          _buildDeletedRow('All services, roommate posts, and bikes', colors, showDivider: true),
                          _buildDeletedRow('Marketplace listings and buy requests', colors, showDivider: true),
                          _buildDeletedRow('All chats and voice messages', colors, showDivider: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active Rental Notice (Rule 8)
                    if (_activeRentalsCount > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.amberAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.amberAccent.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.info, size: 18, color: colors.amberAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'You have $_activeRentalsCount active bike rental. Finish or cancel it before deleting.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.danger,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Password input field
                    AppTextField(
                      label: 'Enter your password to confirm',
                      hintText: 'Your password',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Column(
                children: [
                  AppButton(
                    text: 'Delete my account forever',
                    variant: AppButtonVariant.destructive,
                    isLoading: _isDeleting,
                    onPressed: (_activeRentalsCount > 0 || _isLoading)
                        ? null
                        : _handleDeleteAccount,
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    text: 'Keep my account',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedRow(String title, AppColorsExtension colors, {required bool showDivider}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.centerLeft,
      decoration: showDivider
          ? BoxDecoration(border: Border(bottom: BorderSide(color: colors.divider)))
          : null,
      child: Row(
        children: [
          Icon(LucideIcons.trash2, size: 16, color: colors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
