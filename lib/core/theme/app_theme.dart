import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'app_typography.dart';

export 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const c = AppColorsExtension.light;
    final textTheme = AppTypography.createTextTheme(c.text, c.mutedText);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: c.primary,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.light(
        primary: c.primary,
        onPrimary: c.textOnPrimary,
        surface: c.surface,
        onSurface: c.text,
        error: c.danger,
        onError: Colors.white,
      ),
      dividerColor: c.divider,
      cardColor: c.surface,
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: BorderSide(color: c.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: c.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: c.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: c.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.mutedText),
        labelStyle: textTheme.labelMedium?.copyWith(color: c.text),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.text,
          elevation: 0,
          side: BorderSide(color: c.inputBorder, width: 1),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        disabledColor: c.skeleton,
        selectedColor: c.primary,
        secondarySelectedColor: c.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        secondaryLabelStyle: textTheme.bodySmall?.copyWith(color: c.textOnPrimary, fontWeight: FontWeight.w700),
        shape: const StadiumBorder(),
        side: BorderSide(color: c.inputBorder, width: 1),
      ),
      textTheme: textTheme,
      extensions: const [c],
    );
  }

  static ThemeData get darkTheme => lightTheme;

  /// Helper for text fields rendered inside custom styled containers / search pills
  /// to prevent inheriting outer OutlineInputBorder and filled colors.
  static InputDecoration borderlessInput({
    String? hintText,
    TextStyle? hintStyle,
    EdgeInsetsGeometry? contentPadding = EdgeInsets.zero,
    bool isDense = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: false,
      fillColor: Colors.transparent,
      isDense: isDense,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}
