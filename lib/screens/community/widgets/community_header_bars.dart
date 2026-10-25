import 'package:flutter/material.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../messages/messages_screen.dart';
import '../../notifications/notifications_screen.dart';

// --- Top App Bar ---
class CommunityTopAppBar extends StatelessWidget {
  final String campusName;
  final bool isDark;

  const CommunityTopAppBar({
    super.key,
    required this.campusName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.zinc900 : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '⚡',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CampuStitch',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    campusName.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.zinc500),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Stack(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 20),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(radius: 3, backgroundColor: AppColors.error),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Stack(
                  children: [
                    Icon(Icons.notifications_none, size: 20),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(radius: 3, backgroundColor: AppColors.error),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Action Bar: Browse Communities & + Post ---
class CommunityActionBar extends StatelessWidget {
  final VoidCallback onBrowseCommunities;
  final VoidCallback onCreatePost;
  final bool isDark;

  const CommunityActionBar({
    super.key,
    required this.onBrowseCommunities,
    required this.onCreatePost,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onBrowseCommunities,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu, size: 18, color: isDark ? Colors.white : Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      'Browse Communities',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: onCreatePost,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                SizedBox(width: 4),
                Text('Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Campus Feed Banner ---
class CampusFeedBanner extends StatelessWidget {
  final String campusName;
  final bool isDark;

  const CampusFeedBanner({
    super.key,
    required this.campusName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.apartment, size: 18, color: isDark ? Colors.white70 : AppColors.zinc700),
              const SizedBox(width: 8),
              Text(
                campusName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'CAMPUS FEED',
              style: TextStyle(
                color: Color(0xFF059669),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Quick Create Post Bar ---
class QuickPostBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const QuickPostBar({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthState.instance.user;
    final initial = (user != null && user.name.isNotEmpty) ? user.name[0].toUpperCase() : 'M';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.zinc900 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Text(
                initial,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Create a post in any community...',
                  style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.image_outlined, size: 20, color: AppColors.zinc500),
            const SizedBox(width: 8),
            const Icon(Icons.link, size: 20, color: AppColors.zinc500),
          ],
        ),
      ),
    );
  }
}

// --- Sort & Flair Bar ---
class CommunitySortFilterBar extends StatelessWidget {
  final bool isDark;
  final String activeSort;
  final String selectedFlair;
  final List<String> flairs;
  final TextEditingController searchController;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onFlairChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onClearSearch;

  const CommunitySortFilterBar({
    super.key,
    required this.isDark,
    required this.activeSort,
    required this.selectedFlair,
    required this.flairs,
    required this.searchController,
    required this.onSortChanged,
    required this.onFlairChanged,
    required this.onSearchSubmitted,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort pills [Hot, New, Top]
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.zinc800 : AppColors.zinc100,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _buildSortTab('hot', '🔥 Hot'),
                _buildSortTab('new', '✨ New'),
                _buildSortTab('top', '📈 Top'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Flair filter horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: flairs.map((flair) {
                final isSel = selectedFlair == flair;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => onFlairChanged(flair),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.black : (isDark ? AppColors.zinc800 : AppColors.zinc100),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        flair,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : (isDark ? Colors.white70 : AppColors.zinc800),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Search in feed
          TextField(
            controller: searchController,
            onSubmitted: onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Search in feed...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.zinc400),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.zinc400),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortTab(String sortKey, String label) {
    final isSel = activeSort == sortKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSortChanged(sortKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSel ? Colors.white : AppColors.zinc600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Empty State ---
class CommunityEmptyState extends StatelessWidget {
  final bool isDark;
  final String selectedSubreddit;
  final VoidCallback onCreateFirstPost;

  const CommunityEmptyState({
    super.key,
    required this.isDark,
    required this.selectedSubreddit,
    required this.onCreateFirstPost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.zinc800 : AppColors.zinc100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 28, color: AppColors.zinc500),
          ),
          const SizedBox(height: 14),
          Text(
            'No posts found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.zinc900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No posts found in ${selectedSubreddit == 'all' ? 'all' : selectedSubreddit}. Be the first student to start the conversation!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.zinc500),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: onCreateFirstPost,
            child: const Text('+ Create the First Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
