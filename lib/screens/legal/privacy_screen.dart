import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account & Data', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text(
          'Under Google Play Store policies and privacy laws, you can permanently delete your CampuStitch account, student verification records, photos, and listing data.\n\nTo complete deletion, you can submit a request on our web portal at campus-stitch.com/delete-account or confirm with support.',
          style: TextStyle(fontSize: 12, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 36),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please visit campus-stitch.com/delete-account to finalize request.'),
                ),
              );
            },
            child: const Text('Web Deletion Portal', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Certified Badge Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'GOOGLE PLAY STORE CERTIFIED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Privacy Policy & Data Safety',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Last Updated: October 2026 • Compliant with Google Play Developer Policies & PECA 2016',
                    style: TextStyle(fontSize: 11, color: AppColors.zinc500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              context,
              number: '1',
              title: 'Data Controller & Overview',
              content:
                  'CampuStitch operates as a multi-tenant university platform connecting students within Pakistani campuses. We respect your personal data and adhere strictly to Privacy-by-Design principles. Student records are segregated by campus and never sold to third-party advertising companies.',
            ),

            _buildSection(
              context,
              number: '2',
              title: 'Personal Information We Collect',
              content:
                  'We collect only what is strictly necessary to run the campus platform:\n• Student Profile: Name, university email, roll number, department, university and campus affiliation.\n• Identity Verification Data: Photograph of your student ID card and a live camera snapshot (selfie) for facial verification.\n• Module Activity: Ride requests/offers, marketplace listings, hostel posts, and peer-to-peer messages.',
            ),

            _buildSection(
              context,
              number: '3',
              title: 'Device Permissions (Camera & Media)',
              content:
                  'In compliance with Google Play Developer Policies:\n• Camera Permission (android.permission.CAMERA): Required solely for capturing a live selfie during student identity verification and taking item pictures for marketplace listings.\n• Storage/Media Access: Required solely to allow picking student card photos or item photos from your gallery.\nPermissions are never utilized in the background without explicit user action.',
            ),

            _buildSection(
              context,
              number: '4',
              title: 'Tenant Isolation & Data Protection',
              content:
                  'CampuStitch features strict multi-tenant isolation. All records are keyed to your specific university campus (campus_id). Students and administrators from one campus cannot access or view records of another campus. All data is protected with TLS 1.3 encryption in transit and encrypted storage at rest.',
            ),

            _buildSection(
              context,
              number: '5',
              title: 'Third-Party Processors & No Sale Policy',
              content:
                  'We do NOT sell, rent, or trade student personal data. We utilize trusted sub-processors strictly for infrastructure services:\n• Cloud Database Infrastructure: Encrypted relational data storage.\n• Encrypted Media Storage: Secure image storage for verification documents.',
            ),

            _buildSection(
              context,
              number: '6',
              title: 'Account & Data Deletion (Google Play Mandate)',
              content:
                  'You have the unconditional right to delete your account and all associated personal data permanently:\n• Within App: Profile ➔ Account Settings ➔ Delete Account.\n• Web URL: campus-stitch.com/delete-account.\nUpon request, your credentials, student ID photos, selfie records, listings, and messages are permanently purged from active databases within 30 days.',
            ),

            _buildSection(
              context,
              number: '7',
              title: 'Contact Our Data Protection Officer',
              content:
                  'For privacy inquiries or compliance requests:\nEmail: privacy@campus-stitch.com / ranahammadismail@gmail.com\nLocation: Lahore, Pakistan.',
            ),

            const SizedBox(height: 12),

            // Account Deletion Action Tile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need to delete your account or data?',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.error),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You can submit a deletion request anytime in-app or via our web portal without reinstalling.',
                    style: TextStyle(fontSize: 11, color: AppColors.zinc600),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () => _showDeleteAccountDialog(context),
                    icon: const Icon(Icons.delete_forever, size: 16),
                    label: const Text('Manage Account Deletion', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                'CampuStitch • Secure Student Architecture',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.zinc500 : AppColors.zinc400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String number,
    required String title,
    required String content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.zinc800 : AppColors.zinc200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white : AppColors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      color: isDark ? AppColors.black : AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.zinc600),
          ),
        ],
      ),
    );
  }
}
