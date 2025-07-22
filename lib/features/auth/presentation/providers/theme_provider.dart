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
      final primaryColor = data?['primary_color'] as String? ?? '#3B82F6';
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: hexToColor(primaryColor)),
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