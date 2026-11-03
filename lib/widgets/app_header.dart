import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/constants/app_constants.dart';
import '../core/state/auth_state.dart';
import '../core/theme/app_colors.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/search/campus_search_screen.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onActionTap;
  final int unreadMessagesCount;
  final int unreadNotificationsCount;

  VoidCallback? get effectiveOnAction => onActionTap ?? onAction;

  const AppHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.onActionTap,
    this.unreadMessagesCount = 0,
    this.unreadNotificationsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final topPadding = MediaQuery.of(context).padding.top;
    final campusName = AuthState.instance.activeCampusName;

    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(20, topPadding + 8, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Campus lock line + Quick action icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Campus Lock Indicator
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.lock,
                      size: 14,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        campusName,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Icon Buttons: Ask, Messages, Notifications
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ask / AI Search Button
                  IconButton(
                    icon: Icon(
                      LucideIcons.sparkles,
                      size: 20,
                      color: colors.text,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CampusSearchScreen(),
                        ),
                      );
                    },
                    tooltip: 'Ask AI or Search',
                    visualDensity: VisualDensity.compact,
                  ),

                  // Messages with unread indicator
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
                          LucideIcons.messageSquare,
                          size: 20,
                          color: colors.text,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MessagesScreen(),
                            ),
                          );
                        },
                        tooltip: 'Messages',
                        visualDensity: VisualDensity.compact,
                      ),
                      if (unreadMessagesCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Notifications with unread indicator
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
                          LucideIcons.bell,
                          size: 20,
                          color: colors.text,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                        tooltip: 'Notifications',
                        visualDensity: VisualDensity.compact,
                      ),
                      if (unreadNotificationsCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Bottom Row: Big Title + Optional Action Pill
          SizedBox(
            height: AppDimensions.minTouchTarget,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.02 * 26,
                      color: colors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (actionLabel != null && effectiveOnAction != null) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: effectiveOnAction,
                    child: Container(
                      height: AppDimensions.minTouchTarget,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        actionLabel!,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
