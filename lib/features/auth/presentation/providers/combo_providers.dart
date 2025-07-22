import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final comboRepositoryProvider = Provider((ref) => ComboRepository(ref.read(supabaseProvider)));

class ComboRepository {
  final SupabaseClient _client;

  ComboRepository(this._client);

  Future<void> addCombo({
    required String name,
    String? description,
    required double price,
    required int restaurantId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _client.from('combos').insert({
        'name': name,
        'description': description,
        'price': price,
        'restaurant_id': restaurantId,
      }).select();

      if (response.isEmpty) {
        throw Exception('Failed to add combo: No data returned.');
      }
      final newComboId = response[0]['id'];

      for (final item in items) {
        await _client.from('combo_items').insert({
          'combo_id': newComboId,
          'menu_item_id': item['id'],
          'quantity': item['quantity'],
        });
      }
    } catch (e) {
      throw Exception('Error adding combo: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCombos(int? restaurantId) async {
    if (restaurantId == null) {
      return [];
    }
    try {
      final response = await _client
          .from('combos')
          .select('*, combo_items(*, menu_items(*))')
          .eq('restaurant_id', restaurantId)
          .eq('is_deleted', false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error fetching combos: $e');
    }
  }

  Future<void> deleteCombo(int comboId) async {
    try {
      await _client.from('combos').update({'is_deleted': true}).eq('id', comboId);
    } catch (e) {
      throw Exception('Error deleting combo: $e');
    }
  }
}

final combosProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final restaurant = ref.watch(restaurantProvider).value;
  return ref.watch(comboRepositoryProvider).getCombos(restaurant?['id']);
});

final addComboControllerProvider = StateNotifierProvider<AddComboController, AsyncValue<void>>((ref) {
  return AddComboController(ref.read(comboRepositoryProvider));
});

class AddComboController extends StateNotifier<AsyncValue<void>> {
  final ComboRepository _comboRepository;

  AddComboController(this._comboRepository) : super(const AsyncValue.data(null));

  Future<void> addCombo({
    required String name,
    String? description,
    required double price,
    required int restaurantId,
    required List<Map<String, dynamic>> items,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _comboRepository.addCombo(
        name: name,
        description: description,
        price: price,
        restaurantId: restaurantId,
        items: items,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final deleteComboControllerProvider = StateNotifierProvider<DeleteComboController, AsyncValue<void>>((ref) {
  return DeleteComboController(ref.read(comboRepositoryProvider));
});

class DeleteComboController extends StateNotifier<AsyncValue<void>> {
  final ComboRepository _comboRepository;

  DeleteComboController(this._comboRepository) : super(const AsyncValue.data(null));

  Future<void> deleteCombo(int comboId) async {
    state = const AsyncValue.loading();
    try {
      await _comboRepository.deleteCombo(comboId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}