import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart';
import 'package:seo_biling/isar/services/isar_service.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_providers.dart';

final configSyncRepositoryProvider = Provider<ConfigSyncRepository>((ref) {
  return ConfigSyncRepository(ref);
});

class ConfigSyncRepository {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  ConfigSyncRepository(this._ref);

  Future<void> syncConfigToSupabase(RestaurantConfig config) async {
    final isarService = _ref.read(isarServiceProvider);
    final restaurant = await isarService.getRestaurantByConfig(config);

    if (restaurant == null) {
      throw Exception('Restaurant not found for the given config');
    }

    final configData = {
      'restaurant_id': restaurant.id,
      'primary_color': config.primaryColor,
      'secondary_color': config.secondaryColor,
      'accent_color': config.accentColor,
      'logo_url': config.logoUrl,
      'last_updated': DateTime.now().toIso8601String(),
    };

    try {
      await _supabase.from('restaurant_config').upsert(configData);
    } catch (e) {
      // Handle error
      print('Error syncing config to Supabase: $e');
      rethrow;
    }
  }
}