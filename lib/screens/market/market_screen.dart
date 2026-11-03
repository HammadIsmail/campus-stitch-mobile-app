import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/market_service.dart';
import '../../models/chat_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/chip_filter_row.dart';
import '../../widgets/state_view.dart';
import '../messages/chat_detail_screen.dart';
import 'market_item_detail_screen.dart';
import 'market_item_owner_screen.dart';
import 'sell_item_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<MarketItemModel> _items = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Appliances',
    'Furniture',
    'Books',
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final campusId = AuthState.instance.activeCampusId;
    try {
      final items = await MarketService.getListings(
        campusId: campusId,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
      );
      if (mounted) {
        setState(() {
          _items = items;
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

  List<MarketItemModel> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.brand.toLowerCase().contains(query) ||
          (item.location != null && item.location!.toLowerCase().contains(query));
    }).toList();
  }

  void _onCardTap(MarketItemModel item) {
    final currentUser = AuthService.currentUser;
    final isOwner = currentUser != null && item.sellerName.toLowerCase() == currentUser.fullName.toLowerCase();

    if (isOwner) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MarketItemOwnerScreen(item: item)),
      ).then((_) => _loadListings());
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MarketItemDetailScreen(item: item)),
      ).then((_) => setState(() {}));
    }
  }

  void _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteListing(MarketItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to remove ""?'),
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
      final res = await MarketService.deleteListing(item.id);
      if (res.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing removed successfully'),
              backgroundColor: Color(0xFF0E6B50),
            ),
          );
          _loadListings();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message ?? 'Failed to delete listing'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _onRequestToBuy(MarketItemModel item) async {
    if (item.isSold || item.isRequested) return;

    final user = AuthService.currentUser;
    final res = await MarketService.sendBuyRequest(
      listingId: item.id,
      offerPrice: item.price,
      message: 'Interested in buying at listed price.',
      buyerName: user?.fullName ?? 'Student',
      buyerId: user?.id,
    );

    if (mounted && res.success) {
      setState(() {
        item.isRequested = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent to seller!'),
          backgroundColor: Color(0xFF0E6B50),
        ),
      );
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
              title: AppStrings.tabMarket,
              actionLabel: AppStrings.sellItemAction,
              onActionTap: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const SellItemScreen()),
                );
                if (created == true) _loadListings();
              },
            ),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.inputBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(LucideIcons.search, size: 20, color: colors.textMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 14, color: colors.textPrimary),
                            decoration: AppTheme.borderlessInput(
                              hintText: 'Search air coolers, tables, books',
                              hintStyle: TextStyle(fontSize: 14, color: colors.textMuted),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: Icon(LucideIcons.x, size: 18, color: colors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ChipFilterRow(
                    chips: _categories,
                    selectedChip: _selectedCategory,
                    onSelected: (val) {
                      setState(() => _selectedCategory = val);
                      _loadListings();
                    },
                  ),
                ],
              ),
            ),

            // Grid Content
            Expanded(
              child: _isLoading
                  ? const StateView.loadingGrid()
                  : _hasError
                      ? (MarketService.cachedListings.isNotEmpty
                          ? _buildOfflineSavedView(colors)
                          : StateView.offline(onAction: _loadListings))
                      : _filteredItems.isEmpty
                          ? StateView.empty(
                              title: AppStrings.marketEmptyTitle,
                              body: AppStrings.marketEmptyBody,
                              actionLabel: AppStrings.sellItemCTA,
                              onAction: () async {
                                final created = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(builder: (_) => const SellItemScreen()),
                                );
                                if (created == true) _loadListings();
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: _loadListings,
                              color: colors.primary,
                              child: GridView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.65,
                                ),
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final m = _filteredItems[index];
                                  final isSold = m.isSold;
                                  final isRequested = m.isRequested;
                                  final currentUser = AuthService.currentUser ?? AuthState.instance.currentUser;
                                  final isOwner = currentUser != null && (
                                    (m.sellerId != null && m.sellerId == currentUser.id) ||
                                    m.sellerName.toLowerCase() == currentUser.fullName.toLowerCase() ||
                                    m.sellerName.toLowerCase() == currentUser.name.toLowerCase()
                                  );

                                  Color btnBg = colors.primary;
                                  Color btnFg = Colors.white;
                                  String btnLabel = 'Request to buy';

                                  if (isSold) {
                                    btnBg = colors.skeleton;
                                    btnFg = colors.textMuted;
                                    btnLabel = 'Sold out';
                                  } else if (isRequested) {
                                    btnBg = colors.amberSoft;
                                    btnFg = colors.textOnAmberSoft;
                                    btnLabel = 'Request sent';
                                  }

                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Photo Box
                                        GestureDetector(
                                          onTap: () => _onCardTap(m),
                                          child: Container(
                                            height: 108,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: colors.skeleton,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                if (m.imageUrl != null && m.imageUrl!.isNotEmpty)
                                                  Image.network(
                                                    m.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) => Center(
                                                      child: Text(
                                                        'Photo',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: colors.textMuted,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Center(
                                                    child: Text(
                                                      'Photo',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: colors.textMuted,
                                                      ),
                                                    ),
                                                  ),
                                                if (isSold)
                                                  Positioned(
                                                    left: 6,
                                                    top: 6,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: colors.textPrimary,
                                                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                                      ),
                                                      child: const Text(
                                                        'Sold out',
                                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                if (isOwner)
                                                  Positioned(
                                                    right: 6,
                                                    top: 6,
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: colors.surface.withValues(alpha: 0.9),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: PopupMenuButton<String>(
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                        icon: Icon(Icons.more_vert, size: 18, color: colors.textPrimary),
                                                        onSelected: (val) async {
                                                          if (val == 'edit') {
                                                            final updated = await Navigator.of(context).push<bool>(
                                                              MaterialPageRoute(builder: (_) => SellItemScreen(initialItem: m)),
                                                            );
                                                            if (updated == true) _loadListings();
                                                          } else if (val == 'delete') {
                                                            _deleteListing(m);
                                                          }
                                                        },
                                                        itemBuilder: (ctx) => [
                                                          const PopupMenuItem(
                                                            value: 'edit',
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.edit_outlined, size: 18),
                                                                SizedBox(width: 8),
                                                                Text('Edit item'),
                                                              ],
                                                            ),
                                                          ),
                                                          const PopupMenuItem(
                                                            value: 'delete',
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                                SizedBox(width: 8),
                                                                Text('Delete item', style: TextStyle(color: Colors.red)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Title
                                        GestureDetector(
                                          onTap: () => _onCardTap(m),
                                          child: Text(
                                            m.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: colors.textPrimary,
                                              height: 1.25,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 2),

                                        // Price
                                        Text(
                                          m.priceText,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),

                                        // Meta
                                        Text(
                                          m.metaText,
                                          style: TextStyle(fontSize: 12, color: colors.textMuted),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),

                                        // Action Area
                                        if (isOwner)
                                          Container(
                                            height: 38,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: colors.primarySoft,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Your listing',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: colors.textOnPrimarySoft,
                                              ),
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (!isSold && !isRequested) {
                                                      _onRequestToBuy(m);
                                                    } else {
                                                      _onCardTap(m);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 38,
                                                    decoration: BoxDecoration(
                                                      color: btnBg,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      btnLabel,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color: btnFg,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: () {
                                                  final convo = ConversationModel(
                                                    id: 'conv_market_${m.id}',
                                                    contactId: m.sellerId ?? m.sellerName,
                                                    contactName: m.sellerName,
                                                    contextType: 'market',
                                                    contextId: m.id,
                                                    contextTitle: m.title,
                                                    lastMessage: 'Regarding: ${m.title}',
                                                    lastTime: 'Just now',
                                                    campusId: m.campusId,
                                                  );
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => ChatDetailScreen(conversation: convo),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: colors.surface,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: colors.inputBorder),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(LucideIcons.messageSquare, size: 16, color: colors.primary),
                                                ),
                                              ),
                                              if (m.phone != null && m.phone!.isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                GestureDetector(
                                                  onTap: () => _openWhatsApp(m.phone!),
                                                  child: Container(
                                                    width: 38,
                                                    height: 38,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(color: const Color(0xFF25D366)),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: const Icon(LucideIcons.phone, size: 16, color: Color(0xFF25D366)),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
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

  Widget _buildOfflineSavedView(AppColorsExtension colors) {
    final cached = MarketService.cachedListings;
    return Column(
      children: [
        // Offline Amber Banner
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.amberSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.wifiOff, size: 20, color: colors.textOnAmberSoft),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13, height: 1.35, color: colors.textOnAmberSoft),
                    children: const [
                      TextSpan(text: 'You are offline. ', style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: 'Showing items saved recently.'),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _loadListings,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.textOnAmberSoft,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Cached listings grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.63,
            ),
            itemCount: cached.length,
            itemBuilder: (context, index) {
              final m = cached[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 108,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.skeleton,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Saved photo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      m.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs ${m.price}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m.condition} · ${m.location ?? 'Campus'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Offline notice
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(
            'Contact buttons and new posts need an internet connection.',
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
