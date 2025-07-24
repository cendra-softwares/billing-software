import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final restaurantProvider = FutureProvider.autoDispose((ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;

  if (userId == null) {
    return null;
  }

  final profileResponse = await client
      .from('profiles')
      .select('restaurant_id')
      .eq('user_id', userId)
      .limit(1)
      .maybeSingle();

  if (profileResponse == null) {
    return null;
  }
  final restaurantId = profileResponse['restaurant_id'];

  if (restaurantId == null) {
    return null;
  }

  final restaurantResponse = await client
      .from('restaurants')
      .select()
      .eq('id', restaurantId)
      .limit(1)
      .maybeSingle();
  return restaurantResponse;
});

final restaurantConfigProvider = FutureProvider.autoDispose((ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;

  if (userId == null) {
    return null;
  }

  final profileResponse = await client
      .from('profiles')
      .select('restaurant_id')
      .eq('user_id', userId)
      .limit(1)
      .maybeSingle();

  if (profileResponse == null) {
    return null;
  }
  final restaurantId = profileResponse['restaurant_id'];

  if (restaurantId == null) {
    return null;
  }

  final configResponse = await client
      .from('restaurant_config')
      .select()
      .eq('restaurant_id', restaurantId)
      .limit(1)
      .maybeSingle();
  return configResponse;
});
