import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_model.dart';
import '../../services/auth_service.dart';
import '../../services/market_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/sub_header.dart';
import '../messages/chat_detail_screen.dart';
import '../profile/user_profile_screen.dart';
import 'sell_item_screen.dart';

class MarketItemDetailScreen extends StatefulWidget {
  final MarketItemModel item;

  const MarketItemDetailScreen({super.key, required this.item});

  @override
  State<MarketItemDetailScreen> createState() => _MarketItemDetailScreenState();
}

class _MarketItemDetailScreenState extends State<MarketItemDetailScreen> {
  final _offerController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  bool _requestSent = false;

  @override
  void initState() {
    super.initState();
    _requestSent = widget.item.isRequested;
    _offerController.text = widget.item.price.toString();
  }

  @override
  void dispose() {
    _offerController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitBuyRequest() async {
    final offerVal = int.tryParse(_offerController.text.trim()) ?? widget.item.price;
    setState(() => _isSubmitting = true);

    final user = AuthService.currentUser;
    final res = await MarketService.sendBuyRequest(
      listingId: widget.item.id,
      offerPrice: offerVal,
      message: _messageController.text.trim(),
      buyerName: user?.fullName ?? 'Student',
      buyerId: user?.id,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (res.success) {
        _requestSent = true;
        widget.item.isRequested = true;
      }
    });

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buy request sent to seller!'),
          backgroundColor: Color(0xFF0E6B50),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to send request'),
          backgroundColor: const Color(0xFFB3261E),
        ),
      );
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
    final isSold = widget.item.isSold;
    final currentUser = AuthService.currentUser;
    final isOwner = currentUser != null &&
        (widget.item.sellerId == currentUser.id ||
            widget.item.sellerName.toLowerCase() == currentUser.fullName.toLowerCase());

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Item details',
              onBack: () => Navigator.of(context).pop(),
              trailing: isOwner
                  ? PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: colors.textPrimary),
                      onSelected: (val) async {
                        final nav = Navigator.of(context);
                        if (val == 'edit') {
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
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete listing', style: TextStyle(color: Colors.red))),
                      ],
                    )
                  : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo placeholder box
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.skeleton,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty
                          ? Image.network(
                              widget.item.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, _, _) => Center(
                                child: Icon(Icons.broken_image, size: 36, color: colors.textMuted),
                              ),
                            )
                          : Text(
                              'Photos',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textMuted,
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),

                    // Header: Title and Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.title,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                  letterSpacing: -0.01,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.item.location ?? 'Hostel'} · Campus Market',
                                style: TextStyle(fontSize: 13, color: colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.item.priceText,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                            if (widget.item.isNegotiable)
                              Text(
                                'Negotiable',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 2x2 Specs Grid
                    Row(
                      children: [
                        Expanded(
                          child: _SpecBox(
                            label: 'Condition',
                            value: widget.item.condition,
                            colors: colors,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SpecBox(
                            label: 'Brand',
                            value: widget.item.brand.isNotEmpty ? widget.item.brand : 'Campus Standard',
                            colors: colors,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SpecBox(
                            label: widget.item.attributes.containsKey('Tank') ? 'Tank' : 'Category',
                            value: widget.item.attributes['Tank']?.toString() ?? widget.item.category,
                            colors: colors,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SpecBox(
                            label: widget.item.attributes.containsKey('Power') ? 'Power' : 'Status',
                            value: widget.item.attributes['Power']?.toString() ?? (isSold ? 'Sold out' : 'For sale'),
                            colors: colors,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Seller profile card
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UserProfileScreen(
                              userName: widget.item.sellerName,
                              subtitle: 'Market Seller · ${widget.item.location ?? 'Campus'}',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
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
                                widget.item.sellerName.isNotEmpty ? widget.item.sellerName[0].toUpperCase() : 'S',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textOnPrimarySoft,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.item.sellerName,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                                  ),
                                  Text(
                                    '4.8 rating · 23 reviews',
                                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Icon(LucideIcons.chevronRight, size: 18, color: colors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Request state notice if sent
                    if (_requestSent)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.amberSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.clock, size: 20, color: colors.textOnAmberSoft),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Buy request sent! The seller will review your offer.',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textOnAmberSoft),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isSold)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.skeleton,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.ban, size: 20, color: colors.textPrimary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This item has already been sold.',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Offer & Message inputs
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Your offer (Rs)',
                              controller: _offerController,
                              keyboardType: TextInputType.number,
                              hintText: '13500',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Message',
                              controller: _messageController,
                              hintText: 'When can I see it?',
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed Bottom CTAs
            if (!isOwner)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 12,
                      child: AppButton(
                        text: isSold
                            ? 'Sold out'
                            : _requestSent
                                ? 'Request sent'
                                : 'Request to buy',
                        isLoading: _isSubmitting,
                        backgroundColor: isSold
                            ? colors.skeleton
                            : _requestSent
                                ? colors.amberSoft
                                : colors.primary,
                        textColor: isSold
                            ? colors.textMuted
                            : _requestSent
                                ? colors.textOnAmberSoft
                                : Colors.white,
                        onPressed: (!isSold && !_requestSent) ? _submitBuyRequest : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 10,
                      child: AppButton(
                        text: 'Chat',
                        icon: LucideIcons.messageSquare,
                        isSecondary: true,
                        onPressed: () {
                          final convo = ConversationModel(
                            id: 'conv_market_${widget.item.id}',
                            contactId: widget.item.sellerId ?? widget.item.sellerName,
                            contactName: widget.item.sellerName,
                            contextType: 'market',
                            contextId: widget.item.id,
                            contextTitle: widget.item.title,
                            lastMessage: 'Regarding: ${widget.item.title}',
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
                    if (widget.item.phone != null && widget.item.phone!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final clean = widget.item.phone!.replaceAll(RegExp(r'[^0-9+]'), '');
                          final url = Uri.parse('https://wa.me/$clean');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(LucideIcons.phone, color: Color(0xFF25D366)),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpecBox extends StatelessWidget {
  final String label;
  final String value;
  final AppColorsExtension colors;

  const _SpecBox({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
