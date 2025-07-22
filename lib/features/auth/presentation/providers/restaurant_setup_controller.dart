import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/data/auth_repository.dart';
import 'package:seo_biling/features/auth/presentation/pages/owner_dashboard_page.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantSetupState {
  final bool isLoading;
  final String? error;

  RestaurantSetupState({this.isLoading = false, this.error});

  RestaurantSetupState copyWith({bool? isLoading, String? error}) {
    return RestaurantSetupState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RestaurantSetupController extends StateNotifier<RestaurantSetupState> {
  final AuthRepository _authRepository;
  final SupabaseClient _client;

  RestaurantSetupController(this._authRepository, this._client)
      : super(RestaurantSetupState());

  Future<void> createRestaurant(
      BuildContext context,
      String name,
      String location,
      String? email,
      String? phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw 'User not found';
      }

      final response = await _client.from('restaurants').insert({
        'name': name,
        'location': location,
        'contact_email': email,
        'contact_phone': phone,
        'owner_id': userId,
      }).select();

      final restaurantId = response[0]['id'];

      await _client.from('profiles').update({
        'restaurant_id': restaurantId,
      }).eq('user_id', userId);

      await _client.from('restaurant_config').insert({
        'restaurant_id': restaurantId,
      });

      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OwnerDashboardPage()));
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final restaurantSetupControllerProvider =
    StateNotifierProvider<RestaurantSetupController, RestaurantSetupState>(
        (ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final client = Supabase.instance.client;
  return RestaurantSetupController(authRepository, client);
});