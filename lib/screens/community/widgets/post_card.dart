import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/post_model.dart';
import '../post_detail_screen.dart';
import 'edit_post_dialog.dart';

class CommunityPostCard extends StatelessWidget {
  final PostModel post;
  final Function(PostModel, int) onVote;
  final ValueChanged<PostModel> onPostUpdated;
  final ValueChanged<PostModel> onDeletePost;
  final ValueChanged<PostModel> onReportPost;
  final ValueChanged<String> onBlockAuthor;
  final VoidCallback onRefresh;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onVote,
    required this.onPostUpdated,
    required this.onDeletePost,
    required this.onReportPost,
    required this.onBlockAuthor,
    required this.onRefresh,
  });

  String _formatTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return '1 day ago';
      if (diff.inDays < 30) return '${diff.inDays}d ago';
      return '${(diff.inDays / 30).floor()}mo ago';
    } catch (_) {
      return 'just now';
    }
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          onPostUpdated: onRefresh,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthState.instance.user;
    final currentUserName = (user != null && user.name.isNotEmpty) ? user.name.trim().toLowerCase() : '';
    final isAuthor = currentUserName.isNotEmpty && post.authorName.trim().toLowerCase() == currentUserName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar • Handle • Time • Author • Verified • PopupMenu
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF059669),
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : 'S',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.communityName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('•', style: TextStyle(color: AppColors.zinc400)),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeAgo(post.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.zinc400),
                    ),
                    const SizedBox(width: 4),
                    const Text('•', style: TextStyle(color: AppColors.zinc400)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        post.authorName,
                        style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 9, color: Color(0xFF059669)),
                          SizedBox(width: 2),
                          Text('Verified', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: const Icon(Icons.more_horiz, size: 18, color: AppColors.zinc400),
                onSelected: (value) {
                  if (value == 'edit') {
                    EditPostDialog.show(
                      context,
                      post: post,
                      onPostUpdated: onPostUpdated,
                    );
                  } else if (value == 'delete') {
                    onDeletePost(post);
                  } else if (value == 'report') {
                    onReportPost(post);
                  } else if (value == 'block') {
                    onBlockAuthor(post.authorName);
                  }
                },
                itemBuilder: (context) => [
                  if (isAuthor) ...[
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16, color: AppColors.zinc700),
                          SizedBox(width: 8),
                          Text('Edit Post', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete Post', style: TextStyle(fontSize: 12, color: AppColors.error)),
                        ],
                      ),
                    ),
                  ] else ...[
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Report Post', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block_outlined, size: 16, color: AppColors.zinc600),
                          SizedBox(width: 8),
                          Text('Block Author', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Post Title (Tappable to view details & comments)
          GestureDetector(
            onTap: () => _openDetail(context),
            child: Text(
              post.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _openDetail(context),
              child: Text(
                post.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          ],
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Action Row: [ ↑ 1 | ↓ 0 ], [ 💬 0 ], [ 🔁 ], [ 🔗 Share ]
          Row(
            children: [
              // Upvote / Downvote Pill
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_upward,
                        size: 15,
                        color: post.userVote == 1 ? const Color(0xFF059669) : null,
                      ),
                      onPressed: () => onVote(post, 1),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      '${post.score}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: post.userVote == 1
                            ? const Color(0xFF059669)
                            : post.userVote == -1
                                ? AppColors.error
                                : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 1,
                      height: 12,
                      color: isDark ? AppColors.zinc700 : AppColors.zinc300,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_downward,
                        size: 15,
                        color: post.userVote == -1 ? AppColors.error : null,
                      ),
                      onPressed: () => onVote(post, -1),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Comment Pill
              GestureDetector(
                onTap: () => _openDetail(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 14, color: AppColors.zinc600),
                      const SizedBox(width: 5),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Repost / sync Icon
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.repeat, size: 15, color: AppColors.zinc600),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: 'https://campus-stitch.vercel.app/community/post/${post.id}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post link copied to share!'), duration: Duration(seconds: 2)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Share Pill
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'https://campus-stitch.vercel.app/community/post/${post.id}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post link copied to clipboard!'), duration: Duration(seconds: 2)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.share_outlined, size: 13, color: AppColors.zinc600),
                      SizedBox(width: 5),
                      Text(
                        'Share',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
