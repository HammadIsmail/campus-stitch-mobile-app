import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_model.dart';
import '../../models/roommate_model.dart';
import '../../services/auth_service.dart';
import '../../services/roommate_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/sub_header.dart';
import '../messages/chat_detail_screen.dart';
import '../profile/user_profile_screen.dart';
import 'post_roommate_screen.dart';

class RoommateDetailScreen extends StatelessWidget {
  final RoommatePostModel post;

  const RoommateDetailScreen({super.key, required this.post});

  void _onWhatsApp() async {
    if (post.phone.isNotEmpty) {
      final clean = post.phone.replaceAll(RegExp(r'[^0-9+]'), '');
      final url = Uri.parse('https://wa.me/$clean');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This will remove your roommate post permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final res = await RoommateService.deletePost(post.id);
      if (!context.mounted) return;
      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Failed to delete post')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentUser = AuthService.currentUser;
    final isOwner = currentUser != null &&
        ((post.userId != null && post.userId == currentUser.id) ||
            post.who.toLowerCase() == currentUser.fullName.toLowerCase());

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Post details',
              onBack: () => Navigator.of(context).pop(),
              trailing: isOwner
                  ? PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: colors.textPrimary),
                      onSelected: (val) async {
                        if (val == 'edit') {
                          final res = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => PostRoommateScreen(initialPost: post),
                            ),
                          );
                          if (res == true && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        } else if (val == 'delete') {
                          _confirmDelete(context);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit post')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete post', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )
                  : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.skeleton,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Poster Info Row
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colors.primarySoft,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            post.initial,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.textOnPrimarySoft,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.who,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => UserProfileScreen(
                                        userName: post.who,
                                        subtitle: 'Student · ${post.area}',
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Campus Student · ${post.area}',
                                  style: TextStyle(
                                    fontSize: 12,
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
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.01,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2x2 Grid of details
                    Row(
                      children: [
                        Expanded(
                          child: _DetailBox(
                            label: 'Rent per person',
                            value: post.rent,
                            colors: colors,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DetailBox(
                            label: 'Seats open',
                            value: '${post.seatsOpen} of ${post.totalSeats}',
                            colors: colors,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailBox(
                            label: 'Where',
                            value: post.area,
                            colors: colors,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DetailBox(
                            label: 'Posted',
                            value: 'Recently',
                            colors: colors,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Preference Chips
                    if (post.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: post.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textOnPrimarySoft,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // About Description
                    if (post.about.isNotEmpty) ...[
                      Text(
                        post.about,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Campus Security Lock Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.lock, size: 18, color: colors.textOnPrimarySoft),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Only students on this campus can see this post and contact the poster.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: colors.textOnPrimarySoft,
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

            // Fixed Bottom CTAs
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: isOwner
                  ? Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Edit post',
                            height: 48,
                            isSecondary: true,
                            onPressed: () async {
                              final res = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => PostRoommateScreen(initialPost: post),
                                ),
                              );
                              if (res == true && context.mounted) {
                                Navigator.of(context).pop(true);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            text: 'Delete post',
                            height: 48,
                            isSecondary: true,
                            textColor: colors.danger,
                            onPressed: () => _confirmDelete(context),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Message in app',
                            onPressed: () {
                              final convo = ConversationModel(
                                id: 'conv_room_${post.id}',
                                contactId: post.who,
                                contactName: post.who,
                                contextType: 'roommate',
                                contextId: post.id,
                                contextTitle: post.title,
                                lastMessage: 'Regarding: ${post.title}',
                                lastTime: 'Just now',
                                campusId: post.campusId ?? (currentUser?.campusId ?? ''),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(conversation: convo),
                                ),
                              );
                            },
                          ),
                        ),
                        if (post.phone.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              text: 'WhatsApp',
                              isSecondary: true,
                              onPressed: _onWhatsApp,
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

class _DetailBox extends StatelessWidget {
  final String label;
  final String value;
  final AppColorsExtension colors;

  const _DetailBox({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

