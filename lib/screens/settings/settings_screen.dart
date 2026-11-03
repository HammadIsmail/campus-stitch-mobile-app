import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/sub_header.dart';
import '../auth/sign_in_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'delete_account_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _newMessagesNotif = true;
  bool _requestsNotif = true;
  bool _ratingsNotif = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Settings',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notifications Section
                    Text(
                      'Notifications',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        children: [
                          _SwitchRow(
                            title: 'New messages',
                            value: _newMessagesNotif,
                            onChanged: (val) => setState(() => _newMessagesNotif = val),
                            colors: colors,
                            hasDivider: true,
                          ),
                          _SwitchRow(
                            title: 'Rental and buy requests',
                            value: _requestsNotif,
                            onChanged: (val) => setState(() => _requestsNotif = val),
                            colors: colors,
                            hasDivider: true,
                          ),
                          _SwitchRow(
                            title: 'Ratings',
                            value: _ratingsNotif,
                            onChanged: (val) => setState(() => _ratingsNotif = val),
                            colors: colors,
                            hasDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account Section
                    Text(
                      'Account',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                              );
                            },
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: colors.divider)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Edit profile',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                                  ),
                                  Icon(LucideIcons.chevronRight, size: 18, color: colors.textMuted),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final nav = Navigator.of(context);
                              await AuthService.signOut();
                              AuthState.instance.logout();
                              if (!mounted) return;
                              nav.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const SignInScreen()),
                                (route) => false,
                              );
                            },
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: colors.divider)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Log out',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
                            ),
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Delete my account',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.danger),
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
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppColorsExtension colors;
  final bool hasDivider;

  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.hasDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: hasDivider ? Border(bottom: BorderSide(color: colors.divider)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
          Switch(
            value: value,
            activeThumbColor: colors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
