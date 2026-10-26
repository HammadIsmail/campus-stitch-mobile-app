import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../services/commute_service.dart';
import '../../services/market_service.dart';

class SearchResultItem {
  final String id;
  final String category; // 'Carpool', 'Marketplace'
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
  List<SearchResultItem> _results = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text.trim());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    final campusId = AuthState.instance.activeCampusId;
    final List<SearchResultItem> aggregated = [];

    try {
      // 1. Search Commute Rides
      if (_selectedCategory == 'All' || _selectedCategory == 'Carpool') {
        final rides = await CommuteService.getRides(campusId: campusId, query: query);
        for (final r in rides) {
          aggregated.add(SearchResultItem(
            id: r.id,
            category: 'Carpool',
            title: '${r.fromLocation} → ${r.toLocation}',
            subtitle: '${r.vehicleType.toUpperCase()} • ${r.organizerName} • ${r.departureTime}',
            meta: 'Rs. ${r.pricePerSeat} / seat • ${r.availableSeats} left',
            icon: Icons.directions_car,
          ));
        }
      }

      // 2. Search Market Listings
      if (_selectedCategory == 'All' || _selectedCategory == 'Marketplace') {
        final listings = await MarketService.getListings(campusId: campusId, query: query);
        for (final l in listings) {
          aggregated.add(SearchResultItem(
            id: l.id,
            category: 'Marketplace',
            title: l.title,
            subtitle: '${l.category} • ${l.condition}',
            meta: 'Rs. ${l.price} • Seller: ${l.sellerName}',
            icon: Icons.shopping_bag_outlined,
          ));
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _results = aggregated;
        _isSearching = false;
      });
    }
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
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
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
              children: ['All', 'Carpool', 'Marketplace'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                        if (_searchController.text.trim().isNotEmpty) {
                          _performSearch(_searchController.text.trim());
                        }
                      }
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

          // Content Area
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.trim().isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 56, color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                              const SizedBox(height: 16),
                              const Text(
                                'Search Across Campus',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Find live rides, marketplace listings, and discussions on $campusName.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, color: AppColors.zinc500),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 56, color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Results Found',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'No records matched "${_searchController.text.trim()}".',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12, color: AppColors.zinc500),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _results.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              return Card(
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(item.icon, size: 20),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.meta,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.zinc400 : AppColors.zinc700,
                                        ),
                                      ),
                                    ],
                                  ),
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
