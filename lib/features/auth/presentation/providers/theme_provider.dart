import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';

// Helper function to convert hex string to Color
Color hexToColor(String hexString) {
  final hexCode = hexString.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

final themeProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(restaurantConfigProvider);

  return config.when(
    data: (data) {
      final primaryColor =
          hexToColor(data?['primary_color'] as String? ?? '#3B82F6');
      final secondaryColor =
          hexToColor(data?['secondary_color'] as String? ?? '#6366F1');
      final accentColor =
          hexToColor(data?['accent_color'] as String? ?? '#FACC15');

      return ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor:
                primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor:
              primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
        useMaterial3: true,
      );
    },
    loading: () => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    error: (err, stack) => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
  );
});