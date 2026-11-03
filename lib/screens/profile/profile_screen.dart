import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';
import '../bikes/bike_requests_screen.dart';
import '../bikes/my_bikes_screen.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';
import 'user_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const ProfileScreen({super.key, this.onSwitchTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = AuthState.instance.currentUser;
    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Student';
    final initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'S';
    final campusName = user?.campusName ?? 'Faisalabad Campus';
    final uniName = user?.university ?? 'UET Lahore';

    final rows = [
      {
        'label': 'My services',
        'count': '',
        'onTap': () => widget.onSwitchTab?.call(0),
      },
      {
        'label': 'My roommate posts',
        'count': '',
        'onTap': () => widget.onSwitchTab?.call(1),
      },
      {
        'label': 'My bikes',
        'count': '',
        'onTap': () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyBikesScreen()),
            ),
      },
      {
        'label': 'Rental requests',
        'count': 'Review',
        'onTap': () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BikeRequestsScreen()),
            ),
      },
      {
        'label': 'My market items',
        'count': '',
        'onTap': () => widget.onSwitchTab?.call(3),
      },
      {
        'label': 'Ratings and reviews',
        'count': '',
        'onTap': () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(
                  userName: userName,
                  subtitle: '$uniName, $campusName',
                ),
              ),
            ),
      },
      {
        'label': 'Settings',
        'count': '',
        'onTap': () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
      },
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: AppStrings.tabProfile,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  children: [
                    // Profile user card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    user.avatarUrl!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$uniName, $campusName',
                                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => UserProfileScreen(
                                          userName: userName,
                                          subtitle: '$uniName, $campusName',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'View public profile',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 14),

                    // Activity rows list
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        children: List.generate(rows.length, (idx) {
                          final r = rows[idx];
                          final isLast = idx == rows.length - 1;
                          final countStr = r['count'] as String;

                          return InkWell(
                            onTap: r['onTap'] as VoidCallback?,
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: !isLast
                                    ? Border(bottom: BorderSide(color: colors.divider))
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r['label'] as String,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (countStr.isNotEmpty) ...[
                                        Text(
                                          countStr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: colors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Icon(LucideIcons.chevronRight, size: 18, color: colors.textMuted),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Edit profile button
                    AppButton(
                      text: 'Edit profile',
                      onPressed: () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                        if (updated == true) setState(() {});
                      },
                    ),
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
