import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const brand = Color(0xFF673AB7);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFB26A00);
  static const star = Color(0xFFF5A623);
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.brand, brightness: brightness);
  final background = dark ? const Color(0xFF15121C) : const Color(0xFFF6F5FB);
  final surface = dark ? const Color(0xFF1F1A29) : Colors.white;
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: background);
  final radius = BorderRadius.circular(14);

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: scheme.outlineVariant)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: scheme.outlineVariant)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: radius)),
    ),
    chipTheme: base.chipTheme.copyWith(shape: const StadiumBorder(), side: BorderSide(color: scheme.outlineVariant)),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
    ),
    navigationRailTheme: NavigationRailThemeData(backgroundColor: surface),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface, surfaceTintColor: Colors.transparent),
    dialogTheme: DialogThemeData(backgroundColor: surface, surfaceTintColor: Colors.transparent),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

final _currency = NumberFormat.currency(locale: 'es_ES', symbol: '€');

String formatPrice(num value) => _currency.format(value);
