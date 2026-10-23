import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../admin/campus_admin_screen.dart';
import '../notifications/notifications_screen.dart';
import '../messages/messages_screen.dart';
import '../search/campus_search_screen.dart';
import '../voice/voice_search_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: AuthState.instance,
      builder: (context, _) {
        final user = AuthState.instance.user;
        final campusName = AuthState.instance.activeCampusName;
        final universityName = AuthState.instance.activeUniversityName;
        final isCampusAdmin = AuthState.instance.isCampusAdmin;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CampuStitch',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                      ),
                      Text(
                        '$campusName • $universityName',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.zinc500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Search Action
              IconButton(
                icon: const Icon(Icons.search, size: 21),
                tooltip: 'Search Campus',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CampusSearchScreen()),
                  );
                },
              ),
              // Voice Assistant Action
              IconButton(
                icon: const Icon(Icons.mic_none, size: 21),
                tooltip: 'Voice Search & AI Assistant',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VoiceSearchScreen()),
                  );
                },
              ),
              // Messages Action with Unread Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    tooltip: 'Campus Messages',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MessagesScreen()),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white : AppColors.black,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkCard : AppColors.white,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Notifications Action with Unread Badge
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 22),
                    tooltip: 'Notifications',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white : AppColors.black,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkCard : AppColors.white,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Search Bar with Voice Tap Target
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CampusSearchScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: AppColors.zinc500),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Search rides, gear, discussions...',
                            style: TextStyle(fontSize: 13, color: AppColors.zinc500, fontWeight: FontWeight.w500),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VoiceSearchScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.mic, size: 16, color: AppColors.zinc500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Tenant Isolation Indicator Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.zinc800.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.zinc800.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are viewing $campusName. All feeds and records are isolated to your campus.',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Campus Admin Student Verification Shortcut
                if (isCampusAdmin) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CampusAdminScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Campus Verification Portal',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Review student cards vs live selfie photos for $campusName',
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Quick Services Grid
                const Text(
                  'Campus Modules',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _buildModuleCard(
                      context: context,
                      title: 'Commute & Pool',
                      subtitle: 'Rides & Cycle Rentals',
                      icon: Icons.directions_car_outlined,
                      onTap: () => onNavigateTab?.call(1),
                    ),
                    _buildModuleCard(
                      context: context,
                      title: 'Marketplace',
                      subtitle: 'Textbooks & Gadgets',
                      icon: Icons.sell_outlined,
                      onTap: () => onNavigateTab?.call(2),
                    ),
                    _buildModuleCard(
                      context: context,
                      title: 'Hostel Match',
                      subtitle: 'Find Roommates',
                      icon: Icons.hotel_outlined,
                      onTap: () => onNavigateTab?.call(1),
                    ),
                    _buildModuleCard(
                      context: context,
                      title: 'Community Feed',
                      subtitle: 'Societies & Reddit Feed',
                      icon: Icons.forum_outlined,
                      onTap: () => onNavigateTab?.call(3),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Student Identity Quick Snippet
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isDark ? AppColors.white : AppColors.black,
                          child: Text(
                            (user?.name.isNotEmpty == true ? user!.name[0] : 'S').toUpperCase(),
                            style: TextStyle(
                              color: isDark ? AppColors.black : AppColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Student',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              Text(
                                '${user?.studentId ?? "ID"} • ${user?.campusName ?? campusName}',
                                style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: user?.isVerified == true
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user?.isVerified == true ? 'Verified' : 'Unverified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: user?.isVerified == true ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.zinc500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
