import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

class ChipFilterRow extends StatelessWidget {
  final List<String>? options;
  final String? selectedOption;
  final List<String>? chips;
  final String? selectedChip;
  final ValueChanged<String> onSelected;
  final EdgeInsets padding;

  const ChipFilterRow({
    super.key,
    this.options,
    this.selectedOption,
    this.chips,
    this.selectedChip,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  }) : assert(options != null || chips != null, 'Either options or chips must be provided');

  List<String> get effectiveOptions => chips ?? options ?? [];
  String get effectiveSelected => selectedChip ?? selectedOption ?? (effectiveOptions.isNotEmpty ? effectiveOptions.first : '');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: AppDimensions.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: effectiveOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = effectiveOptions[index];
          final isSelected = option == effectiveSelected;

          return GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              height: AppDimensions.chipHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.inputBorder,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? colors.textOnPrimary : colors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
