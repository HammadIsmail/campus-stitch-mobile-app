import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class VerifiedStudentBadge extends StatelessWidget {
  final bool isVerified;
  final double iconSize;
  final bool showLabel;
  final double fontSize;

  const VerifiedStudentBadge({
    super.key,
    this.isVerified = true,
    double? iconSize,
    double? size,
    this.showLabel = false,
    this.fontSize = 11,
  }) : iconSize = iconSize ?? size ?? 14;

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!showLabel) {
      return Tooltip(
        message: 'Verified Campus Student',
        child: Icon(
          Icons.verified,
          size: iconSize,
          color: AppColors.success,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: iconSize, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Verified Student',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
            ),
          ),
        ],
      ),
    );
  }
}
