import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/community_model.dart';
import '../../models/post_model.dart';
import '../../services/community_service.dart';
import 'widgets/communities_drawer.dart';
import 'widgets/community_header_bars.dart';
import 'widgets/create_post_dialog.dart';
import 'widgets/post_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State
  List<PostModel> _posts = [];
  List<CommunityModel> _communities = [];
  bool _isLoading = true;
  bool _isLoadingCommunities = false;

  // Filters & Sorting
  String _selectedSubreddit = 'all';
  String _selectedFlair = 'All Flairs';
  String _activeSort = 'hot'; // 'hot' | 'new' | 'top'
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final Set<String> _joinedCommunityIds = {};
  final Set<String> _blockedUsers = {};
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  final List<String> _flairs = [
    'All Flairs',
    'Resource',
    'Question',
    'Discussion',
    'Notice',
    'Carpool',
    'Meme',
    'Event',
  ];

  @override
  void initState() {
    super.initState();
    _loadCommunities();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 150) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  Future<void> _loadCommunities() async {
    setState(() => _isLoadingCommunities = true);
    try {
      final list = await CommunityService.getCommunities(all: true);
      if (mounted) {
        setState(() {
          _communities = list;
          for (var c in list) {
            if (c.isJoined) _joinedCommunityIds.add(c.id);
          }
          _isLoadingCommunities = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCommunities = false);
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
        sort: _activeSort,
        query: _searchQuery,
        flair: _selectedFlair,
        page: 1,
        limit: 10,
      );
      if (mounted) {
        setState(() {
          _posts = posts.where((p) => !_blockedUsers.contains(p.authorName)).toList();
          _hasMore = posts.length >= 10;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading posts: $e');
      if (mounted) setState(() => _isLoading = false);
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
        sort: _activeSort,
        query: _searchQuery,
        flair: _selectedFlair,
        page: nextPage,
        limit: 10,
      );
      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          final existingIds = _posts.map((p) => p.id).toSet();
          final uniquePosts = newPosts
              .where((p) => !existingIds.contains(p.id) && !_blockedUsers.contains(p.authorName))
              .toList();
          _posts.addAll(uniquePosts);
          _hasMore = newPosts.length >= 10;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading more posts: $e');
      if (mounted) setState(() => _isLoadingMore = false);
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

  Future<void> _toggleJoinCommunity(CommunityModel community) async {
    final user = AuthState.instance.user;
    if (user == null) return;

    final isCurrentlyJoined = _joinedCommunityIds.contains(community.id);
    setState(() {
      if (isCurrentlyJoined) {
        _joinedCommunityIds.remove(community.id);
      } else {
        _joinedCommunityIds.add(community.id);
      }
    });

    final res = await CommunityService.joinCommunity(
      communityId: community.id,
      userId: user.userId,
    );

    if (res.success) {
      _loadCommunities();
    }
  }

  void _blockUser(String authorName) {
    setState(() {
      _blockedUsers.add(authorName);
      _posts.removeWhere((p) => p.authorName == authorName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Blocked $authorName. Their posts will no longer appear.'),
        backgroundColor: AppColors.zinc800,
      ),
    );
  }

  void _showReportDialog(PostModel post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag_outlined, size: 20, color: AppColors.error),
            SizedBox(width: 8),
            Text('Report Objectionable Content', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report post by "${post.authorName}":', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...['Harassment or Bullying', 'Spam or Misleading', 'Hate Speech / Slander', 'Explicit or Inappropriate Content'].map(
              (reason) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.circle_outlined, size: 14),
                title: Text(reason, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted. Campus moderators will review this content.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePost(PostModel post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              final success = await CommunityService.deletePost(post.id);
              if (!mounted) return;
              if (success) {
                setState(() {
                  _posts.removeWhere((p) => p.id == post.id);
                });
                scaffold.showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: AppColors.zinc800,
                  ),
                );
              } else {
                scaffold.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete post'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openCreatePost() {
    CreatePostDialog.show(
      context,
      communities: _communities,
      initialCommunity: _selectedSubreddit,
      onPostCreated: _loadPosts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final campusName = AuthState.instance.activeCampusName;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CommunitiesDrawer(
        communities: _communities,
        isLoading: _isLoadingCommunities,
        selectedSubreddit: _selectedSubreddit,
        joinedCommunityIds: _joinedCommunityIds,
        onSelectCommunity: (name) {
          setState(() => _selectedSubreddit = name);
          _loadPosts();
        },
        onToggleJoin: _toggleJoinCommunity,
        onCommunityCreated: _loadCommunities,
      ),
      backgroundColor: isDark ? AppColors.black : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            CommunityTopAppBar(campusName: campusName, isDark: isDark),

            // Feed Body
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadCommunities();
                  await _loadPosts();
                },
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  children: [
                    // Action Row: [ ≡ Browse Communities ] and [ + Post ]
                    CommunityActionBar(
                      isDark: isDark,
                      onBrowseCommunities: () => _scaffoldKey.currentState?.openDrawer(),
                      onCreatePost: _openCreatePost,
                    ),
                    const SizedBox(height: 12),

                    // Campus Feed Banner
                    CampusFeedBanner(campusName: campusName, isDark: isDark),
                    const SizedBox(height: 12),

                    // Quick Post Bar
                    QuickPostBar(isDark: isDark, onTap: _openCreatePost),
                    const SizedBox(height: 12),

                    // Sort, Flair and Search Controls
                    CommunitySortFilterBar(
                      isDark: isDark,
                      activeSort: _activeSort,
                      selectedFlair: _selectedFlair,
                      flairs: _flairs,
                      searchController: _searchCtrl,
                      onSortChanged: (sort) {
                        setState(() => _activeSort = sort);
                        _loadPosts();
                      },
                      onFlairChanged: (flair) {
                        setState(() => _selectedFlair = flair);
                        _loadPosts();
                      },
                      onSearchSubmitted: (q) {
                        setState(() => _searchQuery = q);
                        _loadPosts();
                      },
                      onClearSearch: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                        _loadPosts();
                      },
                    ),
                    const SizedBox(height: 14),

                    // Post Feed or Empty State
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_posts.isEmpty)
                      CommunityEmptyState(
                        isDark: isDark,
                        selectedSubreddit: _selectedSubreddit,
                        onCreateFirstPost: _openCreatePost,
                      )
                    else ...[
                      ..._posts.map((post) => CommunityPostCard(
                            post: post,
                            onVote: _handleVote,
                            onPostUpdated: (updated) {
                              setState(() {
                                final idx = _posts.indexWhere((p) => p.id == updated.id);
                                if (idx != -1) _posts[idx] = updated;
                              });
                            },
                            onDeletePost: _confirmDeletePost,
                            onReportPost: _showReportDialog,
                            onBlockAuthor: _blockUser,
                            onRefresh: _loadPosts,
                          )),
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "You're all caught up! No more posts to load.",
                              style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
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
