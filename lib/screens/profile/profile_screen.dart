import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/state/theme_state.dart';
import '../../core/theme/app_theme.dart';
import '../admin/campus_admin_screen.dart';
import '../auth/sign_in_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: Listenable.merge([AuthState.instance, ThemeState.instance]),
      builder: (context, _) {
        final user = AuthState.instance.user;
        final isCampusAdmin = AuthState.instance.isCampusAdmin;
        final currentThemeMode = ThemeState.instance.themeMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Student Profile & Settings'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, size: 20),
                tooltip: 'Sign Out',
                onPressed: () => _confirmSignOut(context),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.badge_outlined, size: 18),
                  text: 'Identity Card',
                ),
                Tab(
                  icon: Icon(Icons.settings_outlined, size: 18),
                  text: 'Settings',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // ==========================================
              // TAB 1: IDENTITY CARD
              // ==========================================
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Identity Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: isDark ? AppColors.white : AppColors.black,
                              child: Text(
                                (user?.name.isNotEmpty == true ? user!.name[0] : 'S').toUpperCase(),
                                style: TextStyle(
                                  color: isDark ? AppColors.black : AppColors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user?.name ?? 'Student',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.zinc500),
                            ),
                            const SizedBox(height: 12),

                            // Role & Verification Tags
                            Wrap(
                              spacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCampusAdmin
                                        ? AppColors.campusAdmin.withValues(alpha: 0.1)
                                        : AppColors.zinc800.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCampusAdmin
                                          ? AppColors.campusAdmin.withValues(alpha: 0.3)
                                          : AppColors.zinc400.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    isCampusAdmin ? 'CAMPUS ADMIN' : 'STUDENT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: isCampusAdmin ? AppColors.campusAdmin : null,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: user?.isVerified == true
                                        ? AppColors.success.withValues(alpha: 0.1)
                                        : AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: user?.isVerified == true
                                          ? AppColors.success.withValues(alpha: 0.3)
                                          : AppColors.warning.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    user?.isVerified == true ? 'VERIFIED STUDENT' : 'VERIFICATION PENDING',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: user?.isVerified == true ? AppColors.success : AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tenant Details List
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CAMPUS AFFILIATION',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.zinc500, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.school, 'University', user?.universityName ?? 'University of Engineering and Technology'),
                            const Divider(height: 16),
                            _buildDetailRow(Icons.location_city, 'Campus', user?.campusName ?? 'Main Campus'),
                            const Divider(height: 16),
                            _buildDetailRow(Icons.badge, 'Student ID', user?.studentId ?? 'N/A'),
                            const Divider(height: 16),
                            _buildDetailRow(Icons.menu_book, 'Degree Program', user?.program ?? 'BS Computer Science'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (isCampusAdmin) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.campusAdmin,
                          side: const BorderSide(color: AppColors.campusAdmin),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CampusAdminScreen()),
                          );
                        },
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Open Campus Verification Console'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),

              // ==========================================
              // TAB 2: SETTINGS & PREFERENCES
              // ==========================================
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Appearance & Theme Mode Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDark ? Icons.dark_mode : Icons.light_mode,
                                  size: 18,
                                  color: isDark ? AppColors.white : AppColors.black,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'APPEARANCE & THEME',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.zinc500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Choose your theme preference. Defaults to your device operating system setting.',
                              style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                            ),
                            const SizedBox(height: 14),

                            // Option 1: System Default
                            _buildThemeOption(
                              context: context,
                              mode: ThemeMode.system,
                              title: 'System Default',
                              subtitle: 'Automatically adapts to device light or dark mode',
                              icon: Icons.brightness_auto,
                              isSelected: currentThemeMode == ThemeMode.system,
                              badgeText: isDark ? 'System: Dark' : 'System: Light',
                              onTap: () {
                                ThemeState.instance.setThemeMode(ThemeMode.system);
                              },
                            ),
                            const SizedBox(height: 8),

                            // Option 2: Light Mode
                            _buildThemeOption(
                              context: context,
                              mode: ThemeMode.light,
                              title: 'Light Mode',
                              subtitle: 'Crisp monochrome light interface',
                              icon: Icons.light_mode_outlined,
                              isSelected: currentThemeMode == ThemeMode.light,
                              onTap: () {
                                ThemeState.instance.setThemeMode(ThemeMode.light);
                              },
                            ),
                            const SizedBox(height: 8),

                            // Option 3: Dark Mode
                            _buildThemeOption(
                              context: context,
                              mode: ThemeMode.dark,
                              title: 'Dark Mode',
                              subtitle: 'OLED high-contrast dark card interface',
                              icon: Icons.dark_mode_outlined,
                              isSelected: currentThemeMode == ThemeMode.dark,
                              onTap: () {
                                ThemeState.instance.setThemeMode(ThemeMode.dark);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campus Tenant Scope Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.security, size: 18, color: AppColors.success),
                                SizedBox(width: 8),
                                Text(
                                  'TENANT DATA ISOLATION',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.zinc500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Active Scope: ${AuthState.instance.activeCampusName}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Your carpools, peer listings, and discussion threads are strictly isolated to your registered campus tenant. No cross-tenant data leakage is permitted.',
                              style: TextStyle(fontSize: 11, color: AppColors.zinc500, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legal & Policies Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LEGAL & POLICIES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.zinc500,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(Icons.description_outlined, size: 20),
                              title: const Text('Terms of Service', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              subtitle: const Text('Platform rules & student responsibilities', style: TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.chevron_right, size: 18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                                );
                              },
                            ),
                            const Divider(height: 8),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(Icons.shield_outlined, size: 20, color: AppColors.success),
                              title: const Text('Privacy Policy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              subtitle: const Text('Google Play compliant data safety & storage', style: TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.chevron_right, size: 18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                                );
                              },
                            ),
                            const Divider(height: 8),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                              title: const Text('Account & Data Deletion', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
                              subtitle: const Text('Request permanent removal of student data', style: TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.chevron_right, size: 18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App Information & Version
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'APPLICATION INFORMATION',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.zinc500, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Version', style: TextStyle(fontSize: 12, color: AppColors.zinc500)),
                                Text('1.0.0 (Production Release)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Engine', style: TextStyle(fontSize: 12, color: AppColors.zinc500)),
                                Text('Flutter 3.47 • Dart 3.13', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Security Hardening', style: TextStyle(fontSize: 12, color: AppColors.zinc500)),
                                Text('OWASP M1-M7 Enforced', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign Out Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _confirmSignOut(context),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Sign Out of Campus'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.zinc800 : AppColors.zinc100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.white : AppColors.black)
                : (isDark ? AppColors.zinc800 : AppColors.zinc200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (isDark ? AppColors.white : AppColors.black)
                  : AppColors.zinc500,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.zinc900 : AppColors.zinc200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.zinc500),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 20,
                color: isDark ? AppColors.white : AppColors.black,
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                size: 20,
                color: AppColors.zinc400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.zinc500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.zinc500, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your campus account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await AuthState.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      }
    }
  }
}
