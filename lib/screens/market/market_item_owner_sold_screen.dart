import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/market_item_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/sub_header.dart';
import '../ratings/rate_user_screen.dart';
import 'sell_item_screen.dart';

class MarketItemOwnerSoldScreen extends StatelessWidget {
  final MarketItemModel item;
  final String buyerName;
  final int soldPrice;

  const MarketItemOwnerSoldScreen({
    super.key,
    required this.item,
    this.buyerName = 'Ali R.',
    this.soldPrice = 13500,
  });

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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Marked as sold out banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.check, size: 20, color: colors.textOnPrimarySoft),
                          const SizedBox(width: 8),
                          Text(
                            'Marked as sold out',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textOnPrimarySoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sold item card
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
                            alignment: Alignment.center,
                            child: Text(
                              'Photo',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textMuted),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textMuted,
                                  ),
                                ),
                                Text(
                                  'Sold for Rs ${soldPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                                ),
                                Text(
                                  'To $buyerName · Today',
                                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.textPrimary,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: const Text(
                              'Sold out',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'The listing is hidden from search. Other interested buyers were notified that the item is gone.',
                      style: TextStyle(fontSize: 13, height: 1.5, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 14),

                    // Rate buyer card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How was $buyerName?',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your rating helps other sellers on your campus.',
                            style: TextStyle(fontSize: 13, color: colors.textMuted),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            text: 'Rate $buyerName',
                            height: 48,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RateUserScreen(
                                    peerId: 'u_buyer',
                                    peerName: buyerName,
                                    contextTitle: 'Market item: ${item.title}',
                                    transactionId: item.id,
                                    category: 'market',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Relist item',
                      isSecondary: true,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const SellItemScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Done',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

