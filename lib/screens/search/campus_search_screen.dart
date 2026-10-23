import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';

class SearchResultItem {
  final String id;
  final String category; // 'Carpool', 'Marketplace', 'Cycle Rental', 'Community'
  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;

  SearchResultItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
  });
}

class CampusSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const CampusSearchScreen({super.key, this.initialQuery});

  @override
  State<CampusSearchScreen> createState() => _CampusSearchScreenState();
}

class _CampusSearchScreenState extends State<CampusSearchScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';

  final List<SearchResultItem> _allItems = [
    SearchResultItem(
      id: 'c1',
      category: 'Carpool',
      title: 'Khurrialwala to Campus Morning Carpool',
      subtitle: 'Toyota Corolla • Ahmed Raza • Departure 8:00 AM',
      meta: 'Rs. 250 / seat • 3 seats left',
      icon: Icons.directions_car,
    ),
    SearchResultItem(
      id: 'c2',
      category: 'Carpool',
      title: 'Canal Road to Main Campus Shuttle Split',
      subtitle: 'Suzuki Alto • Muhammad Bilal • Departure 7:45 AM',
      meta: 'Rs. 150 / seat • 2 seats left',
      icon: Icons.directions_car,
    ),
    SearchResultItem(
      id: 'm1',
      category: 'Marketplace',
      title: 'Operating System Concepts (10th Edition)',
      subtitle: 'Silberschatz • CS Dept • Mint condition',
      meta: 'Rs. 1,400 • Seller: Sara Khan (Verified)',
      icon: Icons.menu_book,
    ),
    SearchResultItem(
      id: 'm2',
      category: 'Marketplace',
      title: 'Casio fx-991EX Scientific Calculator',
      subtitle: 'Original natural display • Engineering faculty',
      meta: 'Rs. 3,200 • Seller: Usman Tariq (Verified)',
      icon: Icons.calculate,
    ),
    SearchResultItem(
      id: 'm3',
      category: 'Marketplace',
      title: 'Semiconductor Phone Cooler for Gaming & Lab',
      subtitle: 'RGB magnetic clamp • Hostel Block C',
      meta: 'Rs. 1,800 • Seller: Zain Ali',
      icon: Icons.memory,
    ),
    SearchResultItem(
      id: 'b1',
      category: 'Cycle Rental',
      title: 'Phoenix Commuter Cycle Rental',
      subtitle: 'Available at Hostel Block B dock',
      meta: 'Rs. 200 / day • Helmet included',
      icon: Icons.two_wheeler,
    ),
    SearchResultItem(
      id: 'f1',
      category: 'Community',
      title: 'Tips for Operating Systems Lab 3 & Threading',
      subtitle: 'r/cs-uet • 28 upvotes • 14 comments',
      meta: 'Posted by Bilal Cheema',
      icon: Icons.forum,
    ),
    SearchResultItem(
      id: 'f2',
      category: 'Community',
      title: 'Upcoming Tech Society Annual Hackathon 2026',
      subtitle: 'r/campus-events • 45 upvotes • 22 comments',
      meta: 'Registrations closing this Friday',
      icon: Icons.campaign,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SearchResultItem> get _filteredResults {
    final query = _searchController.text.trim().toLowerCase();

    return _allItems.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.meta.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final campusName = AuthState.instance.activeCampusName;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery == null,
          decoration: InputDecoration(
            hintText: 'Search $campusName...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            hintStyle: const TextStyle(fontSize: 15, color: AppColors.zinc500),
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Category filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['All', 'Carpool', 'Marketplace', 'Cycle Rental', 'Community'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: isDark ? AppColors.white : AppColors.black,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? (isDark ? AppColors.black : AppColors.white)
                          : (isDark ? AppColors.zinc400 : AppColors.zinc600),
                    ),
                    backgroundColor: isDark ? AppColors.zinc900 : AppColors.zinc100,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? AppColors.zinc800 : AppColors.zinc200),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Quick suggestion chips when query is empty
          if (_searchController.text.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 16, color: AppColors.zinc500),
                  const SizedBox(width: 8),
                  Text(
                    'TRENDING IN ${campusName.toUpperCase()}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.zinc500, letterSpacing: 0.8),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Khurrialwala',
                  'Operating Systems',
                  'Cycle rental',
                  'fx-991EX',
                  'Hostel Block B',
                ].map((sugg) {
                  return ActionChip(
                    label: Text(sugg, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: isDark ? AppColors.zinc900 : AppColors.zinc100,
                    side: BorderSide(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                    onPressed: () {
                      _searchController.text = sugg;
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredResults.length} campus record${_filteredResults.length == 1 ? '' : 's'} found',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc500),
                ),
                Text(
                  'Isolated to $campusName',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                ),
              ],
            ),
          ),

          // Results list
          Expanded(
            child: _filteredResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: isDark ? AppColors.zinc700 : AppColors.zinc400),
                        const SizedBox(height: 12),
                        const Text('No matching records found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text('Try modifying your query or selecting another category.', style: TextStyle(fontSize: 12, color: AppColors.zinc500)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredResults.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredResults[index];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.icon, size: 18, color: isDark ? AppColors.white : AppColors.black),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.category.toUpperCase(),
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.zinc500, letterSpacing: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.title,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.zinc400 : AppColors.zinc600),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.meta,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
