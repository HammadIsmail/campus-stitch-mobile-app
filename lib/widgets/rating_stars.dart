import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final ValueChanged<int>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 20.0,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starNumber = index + 1;
        final isFilled = rating >= starNumber;

        final starIcon = Icon(
          LucideIcons.star,
          size: size,
          color: isFilled ? colors.amberAccent : colors.inputBorder,
        );

        if (onRatingChanged != null) {
          return GestureDetector(
            onTap: () => onRatingChanged!(starNumber),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: starIcon,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: starIcon,
        );
      }),
    );
  }
}
