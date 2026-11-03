import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum StatusPillVariant { available, pending, booked, soldOut, danger }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusPillVariant variant;
  final Color? customBg;
  final Color? customFg;

  const StatusPill({
    super.key,
    required this.label,
    this.variant = StatusPillVariant.available,
    this.customBg,
    this.customFg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bg;
    Color fg;

    if (customBg != null && customFg != null) {
      bg = customBg!;
      fg = customFg!;
    } else {
      switch (variant) {
        case StatusPillVariant.available:
          bg = colors.primarySoft;
          fg = colors.textOnSoft;
          break;
        case StatusPillVariant.pending:
          bg = colors.amberSoft;
          fg = colors.textOnAmberSoft;
          break;
        case StatusPillVariant.booked:
          bg = colors.skeleton;
          fg = colors.text;
          break;
        case StatusPillVariant.soldOut:
          bg = colors.skeleton;
          fg = colors.mutedText;
          break;
        case StatusPillVariant.danger:
          bg = colors.dangerSoft;
          fg = colors.textOnDangerSoft;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

