import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_model.dart';
import '../../models/roommate_model.dart';
import '../../services/roommate_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';
import '../../widgets/segmented_control.dart';
import '../../widgets/state_view.dart';
import '../messages/chat_detail_screen.dart';
import 'post_roommate_screen.dart';
import 'roommate_detail_screen.dart';

class RoommatesScreen extends StatefulWidget {
  const RoommatesScreen({super.key});

  @override
  State<RoommatesScreen> createState() => _RoommatesScreenState();
}

class _RoommatesScreenState extends State<RoommatesScreen> {
  List<RoommatePostModel> _posts = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _selectedTabIndex = 0; // 0: Rooms available, 1: Looking for a room

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final campusId = AuthState.instance.activeCampusId;
    final type = _selectedTabIndex == 0 ? 'have_room' : 'need_room';
    try {
      final posts = await RoommateService.getPosts(
        campusId: campusId,
        type: type,
      );
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _onWhatsApp(RoommatePostModel post) async {
    if (post.phone.isNotEmpty) {
      final clean = post.phone.replaceAll(RegExp(r'[^0-9+]'), '');
      final url = Uri.parse('https://wa.me/$clean');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      _openDetail(post);
    }
  }

  void _openDetail(RoommatePostModel post) async {
    final res = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoommateDetailScreen(post: post)),
    );
    if (res == true) {
      _loadPosts();
    }
  }

  void _openChat(RoommatePostModel post) {
    final contactId = (post.userId != null && post.userId!.isNotEmpty)
        ? post.userId!
        : 'contact_';

    final conv = ConversationModel(
      id: 'conv_roommate_',
      contactId: contactId,
      contactName: post.who,
      contextType: 'roommate',
      contextId: post.id,
      contextTitle: post.title,
      contextSubtitle: post.rent,
      lastMessage: 'Hi, I am interested in your roommate post: "".',
      lastTime: 'Just now',
      unreadCount: 0,
      campusId: post.campusId ?? '',
      messages: [],
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(conversation: conv),
      ),
    );
  }

  Future<void> _deletePost(RoommatePostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Roommate Post'),
        content: Text('Are you sure you want to delete ""?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await RoommateService.deletePost(post.id);
      if (res.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Roommate post deleted successfully'),
              backgroundColor: Color(0xFF0E6B50),
            ),
          );
          _loadPosts();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message ?? 'Failed to delete post'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: AppStrings.tabRoommates,
              actionLabel: AppStrings.postRoommateAction,
              onActionTap: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const PostRoommateScreen()),
                );
                if (created == true) _loadPosts();
              },
            ),

            // Tab switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: AppSegmentedControl(
                segments: const [
                  AppStrings.tabRoomsAvailable,
                  AppStrings.tabLookingForRoom,
                ],
                selectedIndex: _selectedTabIndex,
                onChanged: (idx) {
                  setState(() => _selectedTabIndex = idx);
                  _loadPosts();
                },
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const StateView.loadingList()
                  : _hasError
                      ? StateView.offline(onAction: _loadPosts)
                      : _posts.isEmpty
                          ? StateView.empty(
                              title: AppStrings.roommatesEmptyTitle,
                              body: AppStrings.roommatesEmptyBody,
                              actionLabel: AppStrings.postRoommateCTA,
                              onAction: () async {
                                final created = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(builder: (_) => const PostRoommateScreen()),
                                );
                                if (created == true) _loadPosts();
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: _loadPosts,
                              color: colors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                                itemCount: _posts.length,
                                itemBuilder: (context, index) {
                                  final p = _posts[index];
                                  final currentUser = AuthState.instance.currentUser;
                                  final isOwner = currentUser != null && (
                                    (p.userId != null && p.userId!.isNotEmpty && p.userId == currentUser.id) ||
                                    p.who.toLowerCase() == currentUser.fullName.toLowerCase()
                                  );

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (p.imageUrl != null && p.imageUrl!.isNotEmpty) ...[
                                          GestureDetector(
                                            onTap: () => _openDetail(p),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                p.imageUrl!,
                                                height: 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => _openDetail(p),
                                                child: Text(
                                                  p.title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: colors.textPrimary,
                                                    height: 1.25,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              p.rent,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            if (isOwner) ...[
                                              const SizedBox(width: 4),
                                              PopupMenuButton<String>(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: Icon(Icons.more_vert, size: 20, color: colors.textMuted),
                                                onSelected: (val) async {
                                                  if (val == 'edit') {
                                                    final updated = await Navigator.of(context).push<bool>(
                                                      MaterialPageRoute(
                                                        builder: (_) => PostRoommateScreen(initialPost: p),
                                                      ),
                                                    );
                                                    if (updated == true) _loadPosts();
                                                  } else if (val == 'delete') {
                                                    _deletePost(p);
                                                  }
                                                },
                                                itemBuilder: (ctx) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit_outlined, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Edit post'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                        SizedBox(width: 8),
                                                        Text('Delete post', style: TextStyle(color: Colors.red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${p.area} · ${p.who} · Recently',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colors.textMuted,
                                          ),
                                        ),
                                        if (p.tags.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: p.tags.map((t) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: colors.primarySoft,
                                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                                ),
                                                child: Text(
                                                  t,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: colors.textOnPrimarySoft,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                        if (!isOwner) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: AppButton(
                                                  text: 'Chat',
                                                  icon: LucideIcons.messageSquare,
                                                  height: 40,
                                                  onPressed: () => _openChat(p),
                                                ),
                                              ),
                                              if (p.phone.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: AppButton(
                                                    text: 'WhatsApp',
                                                    icon: LucideIcons.phone,
                                                    height: 40,
                                                    isSecondary: true,
                                                    onPressed: () => _onWhatsApp(p),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: AppButton(
                                                  text: 'Details',
                                                  height: 40,
                                                  isSecondary: true,
                                                  onPressed: () => _openDetail(p),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
