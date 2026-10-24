import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
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
                      'STUDENT USER AGREEMENT',
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
                    'CampuStitch Terms & Conditions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Last Updated: October 2026 • Applicable to all Pakistani University Campuses',
                    style: TextStyle(fontSize: 11, color: AppColors.zinc500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Terms Sections
            _buildSection(
              context,
              number: '1',
              title: 'Acceptance of Terms',
              content:
                  'By registering, signing in, or using the CampuStitch mobile application, you agree to comply with and be legally bound by these Terms and Conditions and our Privacy Policy. If you do not agree, you must immediately cease using the application.',
            ),

            _buildSection(
              context,
              number: '2',
              title: 'Student Identity Verification & Campus Affiliation',
              content:
                  'CampuStitch is restricted to authentic, verified university students, faculty, and campus staff in Pakistan. All users are required to undergo student verification by providing a clear photograph of their official campus identification card and a live camera face selfie. Submitting forged, borrowed, or altered credentials results in an immediate permanent ban and referral to campus authorities.',
            ),

            _buildSection(
              context,
              number: '3',
              title: 'Student Peer Marketplace',
              content:
                  'The CampuStitch marketplace facilitates peer-to-peer exchanges of textbooks, calculators, lab gear, and study supplies between students. CampuStitch acts as an introductory directory, not a retailer or payment escrow. In-person product inspections and cash handoffs must strictly occur within daylight hours inside campus public locations (e.g. university library or main cafeteria). Listing prohibited items, weapons, drugs, or exam leak materials is strictly barred.',
            ),

            _buildSection(
              context,
              number: '4',
              title: 'Campus Commute & Non-Commercial Carpooling',
              content:
                  'Rides shared via CampuStitch are strictly non-commercial carpools intended for fuel cost-sharing between university peers. CampuStitch is not a commercial taxi operator or transport dispatch. Drivers must possess a valid Pakistani driving license and roadworthy vehicle. Drivers and passengers agree to treat each other with dignity and punctuality.',
            ),

            _buildSection(
              context,
              number: '5',
              title: 'Hostels & Roommate Listings',
              content:
                  'Hostel notices and flatmate requests must reflect truthful descriptions and genuine rent figures. CampuStitch does not broker tenancy agreements. Any agreements, deposits, or rental arrangements are formed independently between students and property owners.',
            ),

            _buildSection(
              context,
              number: '6',
              title: 'Community Code of Conduct',
              content:
                  'We maintain a zero-tolerance policy against cyberbullying, harassment, stalking, hate speech, sectarian discrimination, or defamation. Campus Administrators have the right to delete content, issue warnings, or revoke access for any conduct undermining campus safety.',
            ),

            _buildSection(
              context,
              number: '7',
              title: 'Limitation of Liability',
              content:
                  'To the maximum extent permitted under Pakistani law, CampuStitch and its developers are not liable for private offline transactions, vehicle accidents, delays, or losses arising from peer-to-peer interactions between students.',
            ),

            _buildSection(
              context,
              number: '8',
              title: 'Account Termination & Deletion',
              content:
                  'You may terminate your account at any time via Profile ➔ Delete Account or via our web deletion portal at https://campus-stitch.vercel.app/delete-account. Violations of university policy may lead to administrative suspension.',
            ),

            _buildSection(
              context,
              number: '9',
              title: 'Governing Law',
              content:
                  'These Terms are governed by the laws of the Islamic Republic of Pakistan, including the Prevention of Electronic Crimes Act (PECA 2016). Courts located in Lahore or Islamabad have exclusive jurisdiction.',
            ),

            _buildSection(
              context,
              number: '10',
              title: 'Contact Information',
              content:
                  'Inquiries regarding these terms may be directed to support@campus-stitch.com or ranahammadismail@gmail.com.',
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                'CampuStitch • Multi-Tenant University Network',
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
