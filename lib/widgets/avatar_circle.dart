import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AvatarCircle extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const AvatarCircle({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: colors.textOnSoft,
        ),
      ),
    );
  }
}

