import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../services/community_service.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onPostUpdated;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.onPostUpdated,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostModel _post;
  List<CommentModel> _comments = [];
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;

  final TextEditingController _commentCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  CommentModel? _replyingToComment;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final comments = await CommunityService.getComments(_post.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _handleVote(int direction) async {
    final user = AuthState.instance.user;
    if (user == null) return;

    final originalVote = _post.userVote;
    int newVote = direction;
    int newScore = _post.score;

    if (originalVote == direction) {
      newVote = 0;
      newScore -= direction;
    } else {
      newScore += direction - originalVote;
    }

    setState(() {
      _post = _post.copyWith(
        userVote: newVote,
        score: newScore,
      );
    });

    widget.onPostUpdated?.call();

    await CommunityService.votePost(
      postId: _post.id,
      direction: direction,
      userId: user.userId,
    );
  }

  Future<void> _submitComment() async {
    final content = _commentCtrl.text.trim();
    if (content.isEmpty) return;

    final user = AuthState.instance.user;
    setState(() => _isSubmittingComment = true);

    final res = await CommunityService.addComment(
      postId: _post.id,
      parentCommentId: _replyingToComment?.id,
      content: content,
      authorName: user?.name,
      authorStudentId: user?.studentId,
      authorId: user?.userId,
    );

    if (!mounted) return;
    setState(() => _isSubmittingComment = false);

    if (res.success) {
      _commentCtrl.clear();
      setState(() {
        _replyingToComment = null;
        _post = _post.copyWith(commentsCount: _post.commentsCount + 1);
      });
      _focusNode.unfocus();
      _loadComments();
      widget.onPostUpdated?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to post comment'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyingToComment = comment;
    });
    _focusNode.requestFocus();
  }

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
      return 'recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          _post.communityName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'https://campus-stitch.vercel.app/community/post/${_post.id}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadComments,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Full Post Details Card
                  _buildPostContent(isDark),
                  const SizedBox(height: 20),

                  // Comments Header
                  Row(
                    children: [
                      const Icon(Icons.forum_outlined, size: 18, color: AppColors.zinc500),
                      const SizedBox(width: 8),
                      Text(
                        'Comments (${_comments.fold<int>(0, (sum, c) => sum + 1 + c.replies.length)})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Comments List
                  if (_isLoadingComments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_comments.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.mode_comment_outlined, size: 36, color: AppColors.zinc400),
                          const SizedBox(height: 8),
                          const Text(
                            'No comments yet',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Be the first to share your thoughts on this post!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._comments.map((comment) => _buildCommentTile(comment, isDark)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Replying banner
          if (_replyingToComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? AppColors.zinc800 : AppColors.zinc100,
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: AppColors.zinc500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingToComment!.authorName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingToComment = null),
                    child: const Icon(Icons.close, size: 18, color: AppColors.zinc500),
                  ),
                ],
              ),
            ),

          // Bottom Comment Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.zinc900 : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black,
                    child: Text(
                      AuthState.instance.user?.name.isNotEmpty == true
                          ? AuthState.instance.user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      focusNode: _focusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                      decoration: InputDecoration(
                        hintText: _replyingToComment != null
                            ? 'Reply to ${_replyingToComment!.authorName}...'
                            : 'Write a comment...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.zinc400),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmittingComment ? null : _submitComment,
                    icon: _isSubmittingComment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.black, size: 22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF059669),
                child: Text(
                  _post.authorName.isNotEmpty ? _post.authorName[0].toUpperCase() : 'S',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _post.authorName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 10, color: Color(0xFF059669)),
                              SizedBox(width: 3),
                              Text('Verified', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_post.communityName} • ${_formatTimeAgo(_post.createdAt)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _post.flair,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Post Title
          Text(
            _post.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3),
          ),
          if (_post.content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _post.content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
          if (_post.imageUrl != null && _post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Action row
          Row(
            children: [
              // Upvote/Downvote Pill
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
                        size: 16,
                        color: _post.userVote == 1 ? const Color(0xFF059669) : null,
                      ),
                      onPressed: () => _handleVote(1),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      '${_post.score}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _post.userVote == 1
                            ? const Color(0xFF059669)
                            : _post.userVote == -1
                                ? AppColors.error
                                : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_downward,
                        size: 16,
                        color: _post.userVote == -1 ? AppColors.error : null,
                      ),
                      onPressed: () => _handleVote(-1),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Comment count pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mode_comment_outlined, size: 15, color: AppColors.zinc500),
                    const SizedBox(width: 5),
                    Text(
                      '${_post.commentsCount}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Share Button
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'https://campus-stitch.vercel.app/community/post/${_post.id}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post link copied to clipboard!'), duration: Duration(seconds: 2)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.share_outlined, size: 14, color: AppColors.zinc500),
                      SizedBox(width: 5),
                      Text('Share', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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

  Widget _buildCommentTile(CommentModel comment, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.zinc700,
                child: Text(
                  comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.authorName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.check_circle, size: 12, color: Color(0xFF059669)),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: const TextStyle(fontSize: 10, color: AppColors.zinc400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Content
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              comment.content,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 6),

          // Action row: Reply button
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _startReply(comment),
                  child: const Row(
                    children: [
                      Icon(Icons.reply, size: 14, color: AppColors.zinc500),
                      SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nested Replies
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.zinc300, width: 2)),
                ),
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  children: comment.replies.map((reply) => _buildReplyTile(reply, isDark)).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyTile(CommentModel reply, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc800.withValues(alpha: 0.5) : AppColors.zinc100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.zinc600,
                child: Text(
                  reply.authorName.isNotEmpty ? reply.authorName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  reply.authorName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 10, color: Color(0xFF059669)),
              const SizedBox(width: 5),
              Text(
                _formatTimeAgo(reply.createdAt),
                style: const TextStyle(fontSize: 9, color: AppColors.zinc400),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              reply.content,
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
