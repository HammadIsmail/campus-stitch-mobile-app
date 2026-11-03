import 'package:flutter/material.dart';

/// Legacy color constants retained for backward compatibility with unmigrated screens.
class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);
  static const Color lightBg = Color(0xFFF5F4EF);
  static const Color darkCard = Color(0xFF1A2822);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFB3261E);
  static const Color warning = Color(0xFFE8962E);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color campusAdmin = Color(0xFF8B5CF6);
}

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color surface;
  final Color border;
  final Color divider;
  final Color inputBorder;
  final Color text;
  final Color mutedText;
  final Color primary;
  final Color textOnPrimary;
  final Color primarySoft;
  final Color textOnSoft;
  final Color amberAccent;
  final Color amberSoft;
  final Color textOnAmberSoft;
  final Color danger;
  final Color dangerSoft;
  final Color textOnDangerSoft;
  final Color skeleton;

  // Convenience aliases for idiomatic styling
  Color get textPrimary => text;
  Color get textMuted => mutedText;
  Color get amber => amberAccent;
  Color get textOnPrimarySoft => textOnSoft;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.border,
    required this.divider,
    required this.inputBorder,
    required this.text,
    required this.mutedText,
    required this.primary,
    required this.textOnPrimary,
    required this.primarySoft,
    required this.textOnSoft,
    required this.amberAccent,
    required this.amberSoft,
    required this.textOnAmberSoft,
    required this.danger,
    required this.dangerSoft,
    required this.textOnDangerSoft,
    required this.skeleton,
  });

  static const light = AppColorsExtension(
    background: Color(0xFFF5F4EF),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE2E0D8),
    divider: Color(0xFFEEECE4),
    inputBorder: Color(0xFFCFCCC1),
    text: Color(0xFF16231F),
    mutedText: Color(0xFF5E6B66),
    primary: Color(0xFF0E6B50),
    textOnPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFDCEFE7),
    textOnSoft: Color(0xFF0B4F3B),
    amberAccent: Color(0xFFE8962E),
    amberSoft: Color(0xFFFBE9CF),
    textOnAmberSoft: Color(0xFF5E3300),
    danger: Color(0xFFB3261E),
    dangerSoft: Color(0xFFFBE4E1),
    textOnDangerSoft: Color(0xFF7A1812),
    skeleton: Color(0xFFE7E5DC),
  );

  static const dark = AppColorsExtension(
    background: Color(0xFF101A16),
    surface: Color(0xFF1A2822),
    border: Color(0xFF2E3D36),
    divider: Color(0xFF23322B),
    inputBorder: Color(0xFF384941),
    text: Color(0xFFEAF2EE),
    mutedText: Color(0xFFA3B5AD),
    primary: Color(0xFF4CC59B),
    textOnPrimary: Color(0xFF062A1E),
    primarySoft: Color(0xFF13382C),
    textOnSoft: Color(0xFF7DE0BA),
    amberAccent: Color(0xFFF5A842),
    amberSoft: Color(0xFF382510),
    textOnAmberSoft: Color(0xFFFDE4C8),
    danger: Color(0xFFFF9A92),
    dangerSoft: Color(0xFF3D1614),
    textOnDangerSoft: Color(0xFFFFC4BF),
    skeleton: Color(0xFF23322B),
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? divider,
    Color? inputBorder,
    Color? text,
    Color? mutedText,
    Color? primary,
    Color? textOnPrimary,
    Color? primarySoft,
    Color? textOnSoft,
    Color? amberAccent,
    Color? amberSoft,
    Color? textOnAmberSoft,
    Color? danger,
    Color? dangerSoft,
    Color? textOnDangerSoft,
    Color? skeleton,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      inputBorder: inputBorder ?? this.inputBorder,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      primary: primary ?? this.primary,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      primarySoft: primarySoft ?? this.primarySoft,
      textOnSoft: textOnSoft ?? this.textOnSoft,
      amberAccent: amberAccent ?? this.amberAccent,
      amberSoft: amberSoft ?? this.amberSoft,
      textOnAmberSoft: textOnAmberSoft ?? this.textOnAmberSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      textOnDangerSoft: textOnDangerSoft ?? this.textOnDangerSoft,
      skeleton: skeleton ?? this.skeleton,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      textOnSoft: Color.lerp(textOnSoft, other.textOnSoft, t)!,
      amberAccent: Color.lerp(amberAccent, other.amberAccent, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      textOnAmberSoft: Color.lerp(textOnAmberSoft, other.textOnAmberSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      textOnDangerSoft: Color.lerp(textOnDangerSoft, other.textOnDangerSoft, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
    );
  }
}

extension AppColorsContextExtension on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}
