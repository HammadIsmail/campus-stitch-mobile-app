import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_model.dart';
import '../../services/market_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/sub_header.dart';
import '../messages/chat_detail_screen.dart';
import 'market_item_owner_sold_screen.dart';
import 'sell_item_screen.dart';

class MarketItemOwnerScreen extends StatefulWidget {
  final MarketItemModel item;

  const MarketItemOwnerScreen({super.key, required this.item});

  @override
  State<MarketItemOwnerScreen> createState() => _MarketItemOwnerScreenState();
}

class _MarketItemOwnerScreenState extends State<MarketItemOwnerScreen> {
  List<MarketBuyRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final reqs = await MarketService.getBuyRequests(listingId: widget.item.id);
    if (mounted) {
      setState(() {
        _requests = reqs;
        _isLoading = false;
      });
    }
  }

  Future<void> _markSoldOut([String? buyerName, int? soldPrice]) async {
    await MarketService.markSoldOut(listingId: widget.item.id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MarketItemOwnerSoldScreen(
          item: widget.item,
          buyerName: buyerName ?? 'Student Buyer',
          soldPrice: soldPrice ?? widget.item.price,
        ),
      ),
    );
  }

  Future<void> _respondToRequest(MarketBuyRequestModel req, String action) async {
    if (action == 'accept') {
      await MarketService.respondToBuyRequest(
        requestId: req.id,
        listingId: widget.item.id,
        action: 'accept',
      );
      if (!mounted) return;
      _markSoldOut(req.name, req.offerPrice > 0 ? req.offerPrice : widget.item.price);
    } else {
      await MarketService.respondToBuyRequest(
        requestId: req.id,
        listingId: widget.item.id,
        action: 'decline',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Declined offer from ${req.name}')),
      );
      _loadRequests();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text('This will remove your listing permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final res = await MarketService.deleteListing(widget.item.id);
      if (!mounted) return;
      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Failed to delete listing')),
        );
      }
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
            SubHeader(
              title: 'My listing',
              onBack: () => Navigator.of(context).pop(),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colors.textPrimary),
                onSelected: (val) async {
                  if (val == 'edit') {
                    final nav = Navigator.of(context);
                    final res = await nav.push<bool>(
                      MaterialPageRoute(builder: (_) => SellItemScreen(initialItem: widget.item)),
                    );
                    if (res == true && mounted) nav.pop(true);
                  } else if (val == 'delete') {
                    _confirmDelete();
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit listing')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete listing', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Listing card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.skeleton,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty
                                ? Image.network(
                                    widget.item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Icon(Icons.broken_image, size: 24, color: colors.textMuted),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      'Photo',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textMuted),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  widget.item.priceText,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                                ),
                                Text(
                                  widget.item.metaText,
                                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: Text(
                              'For sale',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textOnPrimarySoft),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Actions: Mark as sold out & Edit listing
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Mark as sold out',
                            height: 50,
                            backgroundColor: colors.amber,
                            textColor: const Color(0xFF2B1800),
                            onPressed: () => _markSoldOut(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Edit listing',
                            height: 50,
                            isSecondary: true,
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              final res = await nav.push<bool>(
                                MaterialPageRoute(builder: (_) => SellItemScreen(initialItem: widget.item)),
                              );
                              if (res == true && mounted) {
                                nav.pop(true);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Delete listing',
                      height: 44,
                      isSecondary: true,
                      textColor: colors.danger,
                      onPressed: _confirmDelete,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sold out items are hidden from search and other buyers are told it is gone.',
                      style: TextStyle(fontSize: 12, height: 1.45, color: colors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    // Buy requests header
                    Text(
                      'Buy requests (${_requests.length})',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (_requests.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          'No buy requests yet. Interested students will appear here.',
                          style: TextStyle(fontSize: 13, color: colors.textMuted),
                        ),
                      )
                    else
                      Column(
                        children: _requests.map((r) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colors.primarySoft,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        r.initial,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: colors.textOnPrimarySoft,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            r.rating,
                                            style: TextStyle(fontSize: 12, color: colors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      r.offer,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  r.msg,
                                  style: TextStyle(fontSize: 13, color: colors.textPrimary),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        text: 'Decline',
                                        height: 46,
                                        isSecondary: true,
                                        onPressed: () => _respondToRequest(r, 'decline'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: AppButton(
                                        text: 'Message',
                                        height: 46,
                                        isSecondary: true,
                                        textColor: colors.primary,
                                        onPressed: () {
                                          final convo = ConversationModel(
                                            id: 'conv_market_${widget.item.id}_${r.id}',
                                            contactId: r.name,
                                            contactName: r.name,
                                            contextType: 'market',
                                            contextId: widget.item.id,
                                            contextTitle: widget.item.title,
                                            lastMessage: 'Regarding offer of ${r.offerText}',
                                            lastTime: 'Just now',
                                            campusId: widget.item.campusId,
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatDetailScreen(conversation: convo),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: AppButton(
                                        text: 'Accept',
                                        height: 46,
                                        onPressed: () => _respondToRequest(r, 'accept'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
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
