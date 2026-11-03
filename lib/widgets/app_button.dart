import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, destructive }

class AppButton extends StatelessWidget {
  final String? label;
  final String? text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool? isSecondary;
  final bool isLoading;
  final double? width;
  final double height;
  final Widget? prefixIcon;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    this.label,
    this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isSecondary,
    this.isLoading = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.prefixIcon,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
  }) : assert(label != null || text != null, 'Either label or text must be provided');

  String get effectiveLabel => label ?? text ?? '';

  AppButtonVariant get effectiveVariant {
    if (isSecondary == true) return AppButtonVariant.secondary;
    return variant;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bg;
    Color fg;
    BorderSide? border;

    switch (effectiveVariant) {
      case AppButtonVariant.primary:
        bg = backgroundColor ?? colors.primary;
        fg = textColor ?? colors.textOnPrimary;
        border = null;
        break;
      case AppButtonVariant.secondary:
        bg = backgroundColor ?? colors.surface;
        fg = textColor ?? colors.text;
        border = BorderSide(color: colors.inputBorder, width: 1);
        break;
      case AppButtonVariant.destructive:
        bg = backgroundColor ?? colors.danger;
        fg = textColor ?? Colors.white;
        border = null;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: onPressed == null ? colors.skeleton : bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
              border: border != null ? Border.fromBorderSide(border) : null,
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Builder(
                    builder: (context) {
                      final effectiveIcon = prefixIcon ?? (icon != null ? Icon(icon, size: 18, color: fg) : null);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (effectiveIcon != null) ...[
                            effectiveIcon,
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              effectiveLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: onPressed == null ? colors.mutedText : fg,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
