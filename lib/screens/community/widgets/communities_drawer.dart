import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/community_model.dart';
import 'create_community_dialog.dart';

class CommunitiesDrawer extends StatefulWidget {
  final List<CommunityModel> communities;
  final bool isLoading;
  final String selectedSubreddit;
  final Set<String> joinedCommunityIds;
  final ValueChanged<String> onSelectCommunity;
  final ValueChanged<CommunityModel> onToggleJoin;
  final VoidCallback onCommunityCreated;

  const CommunitiesDrawer({
    super.key,
    required this.communities,
    required this.isLoading,
    required this.selectedSubreddit,
    required this.joinedCommunityIds,
    required this.onSelectCommunity,
    required this.onToggleJoin,
    required this.onCommunityCreated,
  });

  @override
  State<CommunitiesDrawer> createState() => _CommunitiesDrawerState();
}

class _CommunitiesDrawerState extends State<CommunitiesDrawer> {
  String _drawerFilter = '';
  bool _filterByJoined = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var displayCommunities = widget.communities;
    if (_filterByJoined) {
      displayCommunities = displayCommunities
          .where((c) => widget.joinedCommunityIds.contains(c.id))
          .toList();
    }
    if (_drawerFilter.isNotEmpty) {
      displayCommunities = displayCommunities
          .where((c) =>
              c.name.toLowerCase().contains(_drawerFilter.toLowerCase()) ||
              c.title.toLowerCase().contains(_drawerFilter.toLowerCase()))
          .toList();
    }

    return Drawer(
      backgroundColor: isDark ? AppColors.zinc900 : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'r/',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Communities',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // FEEDS Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FEEDS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.zinc400)),
                  const SizedBox(height: 8),

                  // All Campus Feeds
                  GestureDetector(
                    onTap: () {
                      setState(() => _filterByJoined = false);
                      Navigator.pop(context);
                      widget.onSelectCommunity('all');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: widget.selectedSubreddit == 'all' && !_filterByJoined ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.public,
                                size: 18,
                                color: widget.selectedSubreddit == 'all' && !_filterByJoined ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'All Campus Feeds',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: widget.selectedSubreddit == 'all' && !_filterByJoined ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'r/all',
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.selectedSubreddit == 'all' && !_filterByJoined ? Colors.white70 : AppColors.zinc400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // My Subscriptions
                  GestureDetector(
                    onTap: () {
                      setState(() => _filterByJoined = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _filterByJoined ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 18,
                                color: _filterByJoined ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'My Subscriptions',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _filterByJoined ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _filterByJoined ? Colors.white24 : AppColors.zinc200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${widget.joinedCommunityIds.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _filterByJoined ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                onChanged: (v) => setState(() => _drawerFilter = v),
                decoration: InputDecoration(
                  hintText: 'Filter communities...',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.zinc400),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.zinc400),
                  filled: true,
                  fillColor: AppColors.zinc100,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // GENERAL Section Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('GENERAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.zinc400)),
            ),

            // Communities List
            Expanded(
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayCommunities.isEmpty
                      ? const Center(
                          child: Text('No communities found', style: TextStyle(fontSize: 12, color: AppColors.zinc500)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: displayCommunities.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final c = displayCommunities[idx];
                            final isJoined = widget.joinedCommunityIds.contains(c.id);
                            final isCurrent = widget.selectedSubreddit == c.name;

                            return GestureDetector(
                              onTap: () {
                                setState(() => _filterByJoined = false);
                                Navigator.pop(context);
                                widget.onSelectCommunity(c.name);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isCurrent ? AppColors.zinc100 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.zinc200,
                                      child: Text(
                                        c.name.replaceAll('r/', '').substring(0, c.name.length >= 4 ? 2 : 1).toUpperCase(),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.name,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${c.memberCount} members',
                                            style: const TextStyle(fontSize: 10, color: AppColors.zinc500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => widget.onToggleJoin(c),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isJoined ? AppColors.zinc100 : Colors.black,
                                          borderRadius: BorderRadius.circular(14),
                                          border: isJoined ? Border.all(color: AppColors.zinc300) : null,
                                        ),
                                        child: Text(
                                          isJoined ? 'Joined ✓' : '+ Join',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isJoined ? Colors.black : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Fixed Bottom "+ Create Community" Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: AppColors.zinc300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ Create Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () {
                  Navigator.pop(context);
                  CreateCommunityDialog.show(
                    context,
                    onCommunityCreated: widget.onCommunityCreated,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
