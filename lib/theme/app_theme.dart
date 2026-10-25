import 'package:flutter/material.dart';

/// Tema global de Turco (Material 3, seedColor 0xFF00695C, tipografía Poppins).
/// Todos los colores salen del [ColorScheme]; las pantallas no usan `Colors.xxx`.
class AppTheme {
  AppTheme._();

  static const Color seedColor = Color(0xFF00695C);

  static const ColorScheme _esquemaClaro = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF006A60),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF9EF2E4),
    onPrimaryContainer: Color(0xFF00201C),
    secondary: Color(0xFF4A635F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCCE8E2),
    onSecondaryContainer: Color(0xFF05201C),
    tertiary: Color(0xFF456179),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCDE5FF),
    onTertiaryContainer: Color(0xFF001D32),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF4FBF9),
    onSurface: Color(0xFF161D1C),
    onSurfaceVariant: Color(0xFF3F4947),
    outline: Color(0xFF6F7977),
    outlineVariant: Color(0xFFBEC9C6),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2B3231),
    onInverseSurface: Color(0xFFF4FBF9),
    inversePrimary: Color(0xFF74F8E5),
    surfaceTint: Color(0xFF006A60),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEFF5F3),
    surfaceContainer: Color(0xFFE9EFED),
    surfaceContainerHigh: Color(0xFFE3EAE8),
    surfaceContainerHighest: Color(0xFFDEE4E2),
  );

  static const ColorScheme _esquemaOscuro = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF53DBC9),
    onPrimary: Color(0xFF003731),
    primaryContainer: Color(0xFF005047),
    onPrimaryContainer: Color(0xFF74F8E5),
    secondary: Color(0xFFB1CCC6),
    onSecondary: Color(0xFF1C3531),
    secondaryContainer: Color(0xFF314B47),
    onSecondaryContainer: Color(0xFFCCE8E2),
    tertiary: Color(0xFFADCAE6),
    onTertiary: Color(0xFF143349),
    tertiaryContainer: Color(0xFF2D4A62),
    onTertiaryContainer: Color(0xFFCDE5FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0E1514),
    onSurface: Color(0xFFDDE4E2),
    onSurfaceVariant: Color(0xFFBEC9C6),
    outline: Color(0xFF899390),
    outlineVariant: Color(0xFF3F4947),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFDDE4E2),
    onInverseSurface: Color(0xFF2B3231),
    inversePrimary: Color(0xFF006A60),
    surfaceTint: Color(0xFF53DBC9),
    surfaceContainerLowest: Color(0xFF090F0F),
    surfaceContainerLow: Color(0xFF161D1C),
    surfaceContainer: Color(0xFF1A2120),
    surfaceContainerHigh: Color(0xFF252B2B),
    surfaceContainerHighest: Color(0xFF303736),
  );

  static ThemeData get claro => _construir(_esquemaClaro);
  static ThemeData get oscuro => _construir(_esquemaOscuro);

  static const String _fuente = 'Poppins';

  static TextStyle _estilo(double tamano, FontWeight peso, Color color) =>
      TextStyle(
        fontFamily: _fuente,
        fontSize: tamano,
        fontWeight: peso,
        color: color,
      );

  static ThemeData _construir(ColorScheme c) {
    final textTheme = TextTheme(
      headlineSmall: _estilo(24, FontWeight.w600, c.onSurface),
      titleLarge: _estilo(22, FontWeight.w600, c.onSurface),
      titleMedium: _estilo(16, FontWeight.w500, c.onSurface),
      titleSmall: _estilo(14, FontWeight.w600, c.onSurface),
      bodyLarge: _estilo(15, FontWeight.w400, c.onSurface),
      bodyMedium: _estilo(14, FontWeight.w400, c.onSurfaceVariant),
      bodySmall: _estilo(12, FontWeight.w400, c.onSurfaceVariant),
      labelLarge: _estilo(14, FontWeight.w600, c.onSurface),
      labelMedium: _estilo(12, FontWeight.w500, c.onSurfaceVariant),
      labelSmall: _estilo(11, FontWeight.w500, c.onSurfaceVariant),
    );

    final bordeCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c.outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: c,
      fontFamily: _fuente,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        surfaceTintColor: const Color(0x00000000),
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: false,
        titleSpacing: 16,
        titleTextStyle: _estilo(20, FontWeight.w600, c.onSurface),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
          textStyle: _estilo(14, FontWeight.w600, c.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 46),
          foregroundColor: c.primary,
          side: BorderSide(color: c.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
          textStyle: _estilo(14, FontWeight.w600, c.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: _estilo(14, FontWeight.w600, c.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        hintStyle: _estilo(14, FontWeight.w400, c.outline),
        border: bordeCampo,
        enabledBorder: bordeCampo,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error, width: 2),
        ),
        errorStyle: _estilo(12, FontWeight.w400, c.error),
        prefixIconColor: c.onSurfaceVariant,
        suffixIconColor: c.onSurfaceVariant,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x00000000),
        selectedColor: c.secondaryContainer,
        side: BorderSide(color: c.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: _estilo(13, FontWeight.w500, c.onSurfaceVariant),
        secondaryLabelStyle: _estilo(13, FontWeight.w500, c.onSecondaryContainer),
        checkmarkColor: c.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        showCheckmark: true,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: WidgetStatePropertyAll(_estilo(13, FontWeight.w500, c.onSurface)),
          side: WidgetStatePropertyAll(BorderSide(color: c.outline)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? c.secondaryContainer
                : const Color(0x00000000),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? c.onSecondaryContainer
                : c.onSurface,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: c.surfaceContainer,
        surfaceTintColor: const Color(0x00000000),
        elevation: 0,
        indicatorColor: c.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? _estilo(12, FontWeight.w600, c.onSurface)
              : _estilo(12, FontWeight.w500, c.onSurfaceVariant),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected)
                ? c.onSecondaryContainer
                : c.onSurfaceVariant,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primaryContainer,
        foregroundColor: c.onPrimaryContainer,
        extendedTextStyle: _estilo(14, FontWeight.w600, c.onPrimaryContainer),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceContainer,
        surfaceTintColor: const Color(0x00000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: _estilo(20, FontWeight.w600, c.onSurface),
        contentTextStyle: _estilo(14, FontWeight.w400, c.onSurfaceVariant)
            .copyWith(height: 1.45),
        iconColor: c.error,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: const Color(0x00000000),
        modalBackgroundColor: c.surface,
        showDragHandle: true,
        dragHandleColor: c.outlineVariant,
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.inverseSurface,
        contentTextStyle: _estilo(14, FontWeight.w400, c.onInverseSurface),
        actionTextColor: c.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceContainerHigh,
        surfaceTintColor: const Color(0x00000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _estilo(14, FontWeight.w500, c.onSurface),
      ),
      dividerTheme: DividerThemeData(color: c.outlineVariant, thickness: 1, space: 1),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surfaceContainerHigh,
        surfaceTintColor: const Color(0x00000000),
      ),
    );
  }
}
