import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/sub_header.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName;
  final String subtitle;
  final double? ratingAvg;
  final int ratingCount;
  final List<Map<String, dynamic>>? distributions;
  final List<String> tags;
  final List<Map<String, dynamic>> reviews;

  final String? avatarUrl;

  const UserProfileScreen({
    super.key,
    this.userName = 'Student',
    this.subtitle = 'Campus Member',
    this.ratingAvg,
    this.ratingCount = 0,
    this.distributions,
    this.tags = const [],
    this.reviews = const [],
    this.avatarUrl,
  });

  String get _initial => userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentUser = AuthService.currentUser ?? AuthState.instance.currentUser;
    final isSelf = currentUser != null && userName.toLowerCase() == currentUser.fullName.toLowerCase();
    final effectiveAvatarUrl = avatarUrl ?? (isSelf ? currentUser.avatarUrl : null);
    final hasRatings = ratingCount > 0 && ratingAvg != null && ratingAvg! > 0;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Profile',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colors.primarySoft,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: effectiveAvatarUrl != null && effectiveAvatarUrl.isNotEmpty
                              ? Image.network(
                                  effectiveAvatarUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Center(
                                    child: Text(
                                      _initial,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: colors.textOnPrimarySoft,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _initial,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: colors.textOnPrimarySoft,
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TextStyle(fontSize: 13, color: colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Rating Breakdown Card or Honest Empty State
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: hasRatings
                          ? Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      ratingAvg!.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        height: 1.0,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RatingStars(rating: ratingAvg!, size: 14),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$ratingCount ratings',
                                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: (distributions ?? []).map((d) {
                                      final pct = (d['pct'] as num?)?.toDouble() ?? 0.0;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 12,
                                              child: Text(
                                                d['stars']?.toString() ?? '5',
                                                style: TextStyle(fontSize: 12, color: colors.textMuted),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: colors.skeleton,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                alignment: Alignment.centerLeft,
                                                child: FractionallySizedBox(
                                                  widthFactor: pct.clamp(0.0, 1.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: colors.primary,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: colors.primarySoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.star_outline_rounded, color: colors.primary, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No ratings yet',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Verified campus ratings will appear after completing rides, services, or marketplace trades.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.35,
                                          color: colors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Tag Chips (Only when tags exist)
                    if (tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textOnPrimarySoft,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Recent reviews Header
                    Text(
                      'Recent reviews',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    // Reviews List or Honest Empty State
                    if (reviews.isNotEmpty)
                      Column(
                        children: reviews.map((r) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r['name']?.toString() ?? 'Student',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                                    ),
                                    Text(
                                      '${r['stars'] ?? 5} stars · ${r['when'] ?? ''}',
                                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r['text']?.toString() ?? '',
                                  style: TextStyle(fontSize: 13, height: 1.45, color: colors.textPrimary),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.rate_review_outlined, size: 28, color: colors.textMuted),
                            const SizedBox(height: 8),
                            Text(
                              'No reviews yet',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSelf
                                  ? 'Reviews from your campus peers will appear here after you share rides, offer services, or sell items.'
                                  : 'Be the first to share a ride, hire a service, or complete a trade with $userName to leave a review.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: colors.textMuted,
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

            // Fixed Bottom CTAs
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  if (isSelf) ...[
                    Expanded(
                      child: AppButton(
                        text: 'Edit profile',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: AppButton(
                        text: 'Message',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening chat with $userName...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        text: 'Rate $userName',
                        isSecondary: true,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening rating modal for $userName...')),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
