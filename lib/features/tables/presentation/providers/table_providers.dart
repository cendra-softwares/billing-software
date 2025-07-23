import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final tablesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final restaurant = await ref.watch(restaurantProvider.future);
  if (restaurant == null) {
    return [];
  }
  final response = await ref
      .watch(supabaseProvider)
      .from('tables')
      .select('*, section, status')
      .eq('restaurant_id', restaurant['id'])
      .eq('is_deleted', false);

  return List<Map<String, dynamic>>.from(response);
});

final selectedTableProvider = StateProvider<Map<String, dynamic>?>((ref) => null);