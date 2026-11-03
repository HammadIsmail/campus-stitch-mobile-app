import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

class SubHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const SubHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(8, topPadding + 6, 16, 6),
      child: SizedBox(
        height: AppDimensions.minTouchTarget,
        child: Row(
          children: [
            // Back Button with minimum 44x44 touch target
            Semantics(
              label: 'Back',
              button: true,
              child: InkWell(
                onTap: onBack ?? () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  width: AppDimensions.minTouchTarget,
                  height: AppDimensions.minTouchTarget,
                  child: Center(
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 24,
                      color: colors.text,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.01 * 20,
                  color: colors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            ?trailing,
          ],
        ),
      ),
    );
  }
}
