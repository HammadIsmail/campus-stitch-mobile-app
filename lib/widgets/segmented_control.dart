import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppSegmentedControl extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int>? onValueChanged;
  final ValueChanged<int>? onChanged;

  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    this.onValueChanged,
    this.onChanged,
  }) : assert(onValueChanged != null || onChanged != null, 'Either onValueChanged or onChanged must be provided');

  ValueChanged<int> get effectiveOnChanged => onChanged ?? onValueChanged!;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.skeleton,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(segments.length, (index) {
          final isSelected = index == selectedIndex;
          final title = segments[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => effectiveOnChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? colors.text : colors.mutedText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
