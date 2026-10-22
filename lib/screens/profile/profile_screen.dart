import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../admin/campus_admin_screen.dart';
import '../auth/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthState.instance,
      builder: (context, _) {
        final user = AuthState.instance.user;
        final isCampusAdmin = AuthState.instance.isCampusAdmin;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Student Identity & Account'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, size: 20),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await AuthState.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
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
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.white
                              : AppColors.black,
                          child: Text(
                            (user?.name.isNotEmpty == true ? user!.name[0] : 'S').toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.black
                                  : AppColors.white,
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
                                user?.isVerified == true ? 'KYC VERIFIED' : 'KYC PENDING',
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
                        _buildDetailRow(Icons.school, 'University', user?.universityName ?? 'UET Lahore'),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.location_city, 'Campus', user?.campusName ?? 'Main Campus (Lahore)'),
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
                    label: const Text('Open Campus KYC Verification Console'),
                  ),
                  const SizedBox(height: 16),
                ],

                // Sign Out Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await AuthState.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Sign Out of Campus'),
                ),
              ],
            ),
          ),
        );
      },
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
}
