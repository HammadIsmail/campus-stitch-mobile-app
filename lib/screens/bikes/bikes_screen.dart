import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../services/bike_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/chip_filter_row.dart';
import '../../widgets/state_view.dart';
import 'bike_detail_screen.dart';
import 'list_bike_screen.dart';

class BikesScreen extends StatefulWidget {
  const BikesScreen({super.key});

  @override
  State<BikesScreen> createState() => _BikesScreenState();
}

class _BikesScreenState extends State<BikesScreen> {
  List<BikeModel> _bikes = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedFilter = 'Available now';

  final List<String> _filters = [
    'Available now',
    'Today',
    'Weekend',
    'Under Rs 500',
  ];

  @override
  void initState() {
    super.initState();
    _loadBikes();
  }

  Future<void> _deleteBike(BikeModel bike) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bike Listing'),
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
      final res = await BikeService.deleteBike(bike.id);
      if (res.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bike listing deleted successfully'),
              backgroundColor: Color(0xFF0E6B50),
            ),
          );
          _loadBikes();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message ?? 'Failed to delete bike'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _loadBikes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final campusId = AuthState.instance.activeCampusId;
    try {
      final bikes = await BikeService.getBikes(campusId: campusId);
      if (mounted) {
        setState(() {
          _bikes = bikes;
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

  List<BikeModel> get _filteredBikes {
    if (_selectedFilter == 'Under Rs 500') {
      return _bikes.where((b) => b.dailyRate <= 500 || b.hourlyRate <= 100).toList();
    }
    if (_selectedFilter == 'Available now') {
      return _bikes.where((b) => b.isAvailable).toList();
    }
    return _bikes;
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
              title: AppStrings.tabBikes,
              actionLabel: 'List yours',
              onActionTap: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const ListBikeScreen()),
                );
                if (created == true) _loadBikes();
              },
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: ChipFilterRow(
                chips: _filters,
                selectedChip: _selectedFilter,
                onSelected: (val) => setState(() => _selectedFilter = val),
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const StateView.loadingList()
                  : _hasError
                      ? StateView.offline(onAction: _loadBikes)
                      : _filteredBikes.isEmpty
                          ? StateView.empty(
                              title: AppStrings.bikesEmptyTitle,
                              body: AppStrings.bikesEmptyBody,
                              actionLabel: AppStrings.listBikeCTA,
                              onAction: () async {
                                final created = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(builder: (_) => const ListBikeScreen()),
                                );
                                if (created == true) _loadBikes();
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: _loadBikes,
                              color: colors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                                itemCount: _filteredBikes.length,
                                itemBuilder: (context, index) {
                                  final b = _filteredBikes[index];
                                  final currentUser = AuthState.instance.currentUser;
                                  final isOwner = currentUser != null && (
                                    b.ownerName.toLowerCase() == currentUser.fullName.toLowerCase() ||
                                    b.ownerName.toLowerCase() == currentUser.name.toLowerCase()
                                  );
                                  return GestureDetector(
                                    onTap: () async {
                                      final res = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BikeDetailScreen(bike: b),
                                        ),
                                      );
                                      if (res == true) _loadBikes();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                                        border: Border.all(color: colors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 92,
                                            height: 92,
                                            decoration: BoxDecoration(
                                              color: colors.skeleton,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            alignment: Alignment.center,
                                            child: b.imageUrl != null && b.imageUrl!.isNotEmpty
                                                ? Image.network(
                                                    b.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    width: 92,
                                                    height: 92,
                                                    errorBuilder: (_, _, _) => Icon(LucideIcons.bike, size: 36, color: colors.textMuted),
                                                  )
                                                : Icon(LucideIcons.bike, size: 36, color: colors.textMuted),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        b.model,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w700,
                                                          color: colors.textPrimary,
                                                          height: 1.25,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: b.isAvailable ? colors.primarySoft : colors.skeleton,
                                                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                                      ),
                                                      child: Text(
                                                        b.status,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w700,
                                                          color: b.isAvailable ? colors.textOnPrimarySoft : colors.textPrimary,
                                                        ),
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
                                                                builder: (_) => ListBikeScreen(initialBike: b),
                                                              ),
                                                            );
                                                            if (updated == true) _loadBikes();
                                                          } else if (val == 'delete') {
                                                            _deleteBike(b);
                                                          }
                                                        },
                                                        itemBuilder: (ctx) => [
                                                          const PopupMenuItem(
                                                            value: 'edit',
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.edit_outlined, size: 18),
                                                                SizedBox(width: 8),
                                                                Text('Edit bike'),
                                                              ],
                                                            ),
                                                          ),
                                                          const PopupMenuItem(
                                                            value: 'delete',
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                                SizedBox(width: 8),
                                                                Text('Delete bike', style: TextStyle(color: Colors.red)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  b.rateText,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: colors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  b.window,
                                                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Owner: ${b.ownerName}',
                                                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
