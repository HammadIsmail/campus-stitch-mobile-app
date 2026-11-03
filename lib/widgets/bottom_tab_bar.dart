import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';

class BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const BottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final tabs = [
      _TabItem(
        label: AppStrings.tabServices,
        icon: LucideIcons.wrench,
      ),
      _TabItem(
        label: AppStrings.tabRoommates,
        icon: LucideIcons.users,
      ),
      _TabItem(
        label: AppStrings.tabBikes,
        icon: LucideIcons.bike,
      ),
      _TabItem(
        label: AppStrings.tabMarket,
        icon: LucideIcons.shoppingBag,
      ),
      _TabItem(
        label: AppStrings.tabProfile,
        icon: LucideIcons.user,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(6, 8, 6, 8 + (bottomPadding > 0 ? bottomPadding : 10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTabSelected(index),
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 52,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Active pill highlight
                    Container(
                      width: 56,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primarySoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        tab.icon,
                        size: 22,
                        color: isSelected ? colors.primary : colors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? colors.primary : colors.mutedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;

  const _TabItem({
    required this.label,
    required this.icon,
  });
}
