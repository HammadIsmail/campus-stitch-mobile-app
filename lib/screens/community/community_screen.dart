import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/post_model.dart';
import '../../services/community_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String _selectedSubreddit = 'all';

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 150) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });
    try {
      final campusId = AuthState.instance.activeCampusId;
      final posts = await CommunityService.getPosts(
        campusId: campusId,
        community: _selectedSubreddit,
        page: 1,
        limit: 3,
      );
      setState(() {
        _posts = posts;
        _hasMore = posts.length >= 3;
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final campusId = AuthState.instance.activeCampusId;
      final nextPage = _currentPage + 1;
      final newPosts = await CommunityService.getPosts(
        campusId: campusId,
        community: _selectedSubreddit,
        page: nextPage,
        limit: 3,
      );
      setState(() {
        _currentPage = nextPage;
        final existingIds = _posts.map((p) => p.id).toSet();
        final uniquePosts = newPosts.where((p) => !existingIds.contains(p.id)).toList();
        _posts.addAll(uniquePosts);
        _hasMore = newPosts.length >= 3;
      });
    } catch (e) {
      debugPrint('Error loading more posts: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _handleVote(PostModel post, int direction) async {
    final user = AuthState.instance.user;
    if (user == null) return;

    final originalVote = post.userVote;
    int newVote = direction;
    int newScore = post.score;

    if (originalVote == direction) {
      newVote = 0;
      newScore -= direction;
    } else {
      newScore += direction - originalVote;
    }

    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          userVote: newVote,
          score: newScore,
        );
      }
    });

    await CommunityService.votePost(
      postId: post.id,
      direction: direction,
      userId: user.userId,
    );
  }

  void _showCreatePostModal() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String selectedFlair = 'Discussion';
    String selectedComm = 'r/general';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create Post in Campus Feed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedComm,
                        decoration: const InputDecoration(labelText: 'Community'),
                        items: ['r/general', 'r/exams', 'r/commute-splits', 'r/cs-uet'].map((c) {
                          return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedComm = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedFlair,
                        decoration: const InputDecoration(labelText: 'Flair'),
                        items: ['Discussion', 'Resource', 'Question', 'Notice', 'Meme'].map((f) {
                          return DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedFlair = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Post Title', hintText: 'Interesting question or topic'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Post Content', hintText: 'What’s on your mind?'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final user = AuthState.instance.user;
                    final res = await CommunityService.createPost(
                      communityName: selectedComm,
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      flair: selectedFlair,
                      campusId: AuthState.instance.activeCampusId,
                      universityId: user?.universityId,
                      authorName: user?.name,
                      authorStudentId: user?.studentId,
                    );
                    if (res.success && ctx.mounted) {
                      Navigator.pop(ctx);
                      _loadPosts();
                    }
                  },
                  child: const Text('Publish Post'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campusName = AuthState.instance.activeCampusName;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Community & Discussions'),
            Text(
              campusName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Create Post',
            onPressed: _showCreatePostModal,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Subreddit Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: ['all', 'r/general', 'r/exams', 'r/commute-splits', 'r/cs-uet'].map((sub) {
                final isSelected = _selectedSubreddit == sub;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(sub == 'all' ? 'All Feeds' : sub),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedSubreddit = sub);
                      _loadPosts();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.zinc400),
                            const SizedBox(height: 12),
                            const Text('No Posts in Campus Feed Yet', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Be the first to post in $campusName', style: const TextStyle(fontSize: 12, color: AppColors.zinc500)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _posts.length + (_isLoadingMore || !_hasMore ? 1 : 0),
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == _posts.length) {
                            if (_isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  "You're all caught up!",
                                  style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                                ),
                              ),
                            );
                          }
                          final post = _posts[index];
                          return _buildPostCard(post);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Subreddit • Author • Flair
            Row(
              children: [
                Text(
                  post.communityName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 6),
                const Text('•', style: TextStyle(color: AppColors.zinc400)),
                const SizedBox(width: 6),
                Text(
                  post.authorName,
                  style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.zinc800.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    post.flair,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              post.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                post.content,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ],
            const SizedBox(height: 12),

            // Voting and Comments
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.zinc900
                        : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: post.userVote == 1 ? AppColors.success : null,
                        ),
                        onPressed: () => _handleVote(post, 1),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                      Text(
                        '${post.score}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: post.userVote == 1
                              ? AppColors.success
                              : post.userVote == -1
                                  ? AppColors.error
                                  : null,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_downward,
                          size: 16,
                          color: post.userVote == -1 ? AppColors.error : null,
                        ),
                        onPressed: () => _handleVote(post, -1),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Row(
                  children: [
                    const Icon(Icons.mode_comment_outlined, size: 16, color: AppColors.zinc500),
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentsCount} comments',
                      style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
