import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const coral = Color(0xFFD85F59);
  static const lake = Color(0xFF287F89);
  static const amber = Color(0xFFB66A0B);
  static const success = Color(0xFF347552);
  static const canvas = Color(0xFFFFF8F7);
  static const ink = Color(0xFF352F2E);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: coral,
      brightness: Brightness.light,
      primary: coral,
      secondary: lake,
      surface: canvas,
      error: const Color(0xFFBA1A1A),
    );
    const radius = BorderRadius.all(Radius.circular(8));
    const textTheme = TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: ink),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      textTheme: textTheme,
      extensions: const [
        AppSemanticColors(
          scan: lake,
          warning: amber,
          success: success,
          softCoral: Color(0xFFFFE7E3),
          softLake: Color(0xFFDCEFF1),
          softAmber: Color(0xFFFFEBCB),
        ),
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: const Color(0xFFFFFBFA),
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFFFDDD9),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected) ? coral : ink,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          side: const BorderSide(color: Color(0xFFD8C2BF)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFFFBFA),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Color(0xFFD8C2BF)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFFFBFA),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: Color(0xFFF0DFDC)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFEAD8D5)),
    );
  }

  /// 深色配色遵循系统主题，并保持正文、控件和状态颜色的可读对比度。
  static ThemeData get dark {
    const background = Color(0xFF201A19);
    const surface = Color(0xFF2B2423);
    const ink = Color(0xFFF2DEDA);
    const coralDark = Color(0xFFFFB4AA);
    const lakeDark = Color(0xFF8FD5DC);
    const amberDark = Color(0xFFFFBE66);
    const successDark = Color(0xFF8FD0A8);
    const radius = BorderRadius.all(Radius.circular(8));
    final colorScheme = ColorScheme.fromSeed(
      seedColor: coral,
      brightness: Brightness.dark,
      primary: coralDark,
      onPrimary: const Color(0xFF561E19),
      secondary: lakeDark,
      onSecondary: const Color(0xFF00363B),
      surface: surface,
      onSurface: ink,
      error: const Color(0xFFFFB4AB),
    );
    final textTheme = ThemeData.dark().textTheme.copyWith(
      headlineSmall: const TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: const TextStyle(fontSize: 16, height: 1.5, color: ink),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.45, color: ink),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      extensions: const [
        AppSemanticColors(
          scan: lakeDark,
          warning: amberDark,
          success: successDark,
          softCoral: Color(0xFF5A2824),
          softLake: Color(0xFF16434A),
          softAmber: Color(0xFF4A3215),
        ),
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF713A34),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? coralDark : ink,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          side: const BorderSide(color: Color(0xFF9A8581)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Color(0xFF9A8581)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: Color(0xFF514441)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF514441)),
    );
  }
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.scan,
    required this.warning,
    required this.success,
    required this.softCoral,
    required this.softLake,
    required this.softAmber,
  });

  final Color scan;
  final Color warning;
  final Color success;
  final Color softCoral;
  final Color softLake;
  final Color softAmber;

  @override
  AppSemanticColors copyWith({
    Color? scan,
    Color? warning,
    Color? success,
    Color? softCoral,
    Color? softLake,
    Color? softAmber,
  }) {
    return AppSemanticColors(
      scan: scan ?? this.scan,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      softCoral: softCoral ?? this.softCoral,
      softLake: softLake ?? this.softLake,
      softAmber: softAmber ?? this.softAmber,
    );
  }

  @override
  AppSemanticColors lerp(covariant AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      scan: Color.lerp(scan, other.scan, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      softCoral: Color.lerp(softCoral, other.softCoral, t)!,
      softLake: Color.lerp(softLake, other.softLake, t)!,
      softAmber: Color.lerp(softAmber, other.softAmber, t)!,
    );
  }
}
