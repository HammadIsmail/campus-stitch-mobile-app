import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/theme/app_theme.dart';
import 'verified_student_badge.dart';

class PublicProfileDialog extends StatefulWidget {
  final String userId;
  final String fallbackName;
  final bool fallbackVerified;

  const PublicProfileDialog({
    super.key,
    required this.userId,
    required this.fallbackName,
    this.fallbackVerified = false,
  });

  static void show(
    BuildContext context, {
    required String userId,
    required String fallbackName,
    bool fallbackVerified = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PublicProfileDialog(
        userId: userId,
        fallbackName: fallbackName,
        fallbackVerified: fallbackVerified,
      ),
    );
  }

  @override
  State<PublicProfileDialog> createState() => _PublicProfileDialogState();
}

class _PublicProfileDialogState extends State<PublicProfileDialog> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  double _averageRating = 0.0;
  int _totalReviews = 0;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileAndRatings();
  }

  Future<void> _fetchProfileAndRatings() async {
    try {
      // 1. Fetch profile
      final profileUrl = '${ApiConstants.profile}?userId=${encodeURIComponent(widget.userId)}';
      final res = await ApiClient.get(profileUrl);

      if (res.success && res.data is Map && (res.data as Map)['profile'] != null) {
        _profile = Map<String, dynamic>.from((res.data as Map)['profile']);
      }

      // 2. Fetch real ratings
      final ratingsUrl = '${ApiConstants.baseUrl}/api/profile/ratings?userId=${encodeURIComponent(widget.userId)}';
      final ratingsRes = await ApiClient.get(ratingsUrl);
      if (ratingsRes.success && ratingsRes.data is Map) {
        final data = ratingsRes.data as Map;
        _averageRating = (data['averageRating'] is num) ? (data['averageRating'] as num).toDouble() : 0.0;
        _totalReviews = (data['totalReviews'] is num) ? (data['totalReviews'] as num).toInt() : 0;
        _reviews = (data['reviews'] is List) ? (data['reviews'] as List) : [];
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String encodeURIComponent(String s) => Uri.encodeComponent(s);

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Submit an anonymous campus safety report regarding ${widget.fallbackName}? Our campus moderation team will review this profile within 24 hours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted. Thank you for keeping campus safe.')),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Are you sure you want to block ${widget.fallbackName}? You will no longer see their listings, rides, or messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.zinc800, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.fallbackName} has been blocked.')),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _profile?['full_name'] ?? _profile?['name'] ?? widget.fallbackName;
    final isVerified = _profile?['is_verified'] ?? widget.fallbackVerified;
    final university = _profile?['university'] ?? 'University Campus';
    final campus = _profile?['campus_name'] ?? _profile?['city'] ?? '';
    final program = _profile?['program'] ?? '';
    final bio = _profile?['bio']?.toString().trim();
    final avatarUrl = _profile?['avatar_url']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.zinc700 : AppColors.zinc300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row: Avatar, Name, Badge, Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isDark ? AppColors.zinc800 : AppColors.zinc200,
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Text(
                            (name.isNotEmpty ? name[0] : 'S').toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.black,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 6),
                              const VerifiedStudentBadge(isVerified: true, iconSize: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$university${campus.isNotEmpty ? ' • $campus' : ''}',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.zinc400 : AppColors.zinc500),
                        ),
                        if (program.isNotEmpty)
                          Text(
                            program,
                            style: TextStyle(fontSize: 11, color: isDark ? AppColors.zinc400 : AppColors.zinc500),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (v) {
                      if (v == 'report') _showReportDialog();
                      if (v == 'block') _showBlockDialog();
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Report Profile', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('Block Student'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bio
              if (bio != null && bio.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    bio,
                    style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? Colors.white70 : AppColors.zinc800),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Rating Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 8),
                    if (_totalReviews > 0) ...[
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'})',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.zinc400 : AppColors.zinc500),
                      ),
                    ] else ...[
                      Text(
                        'No reviews yet',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.zinc400 : AppColors.zinc500),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isVerified ? 'Verified Student' : 'Student Peer',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isVerified ? AppColors.success : AppColors.zinc500),
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Peer Reviews
              if (_reviews.isNotEmpty) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Peer Feedback',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.zinc400 : AppColors.zinc600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._reviews.take(3).map((r) {
                  final map = r is Map ? r : <String, dynamic>{};
                  final raterName = map['rater_name'] ?? 'Student';
                  final rating = (map['rating'] is num) ? (map['rating'] as num).toInt() : 5;
                  final comment = map['comment'] ?? '';
                  final category = map['category'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              raterName.toString(),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                            if (category.toString().isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  category.toString().toUpperCase(),
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: isDark ? AppColors.zinc400 : AppColors.zinc600),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 12,
                                  color: i < rating ? const Color(0xFFF59E0B) : (isDark ? AppColors.zinc700 : AppColors.zinc300),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (comment.toString().trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            comment.toString(),
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.zinc300 : AppColors.zinc700),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],

              if (_isLoading) ...[
                const SizedBox(height: 20),
                const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              ],

              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
