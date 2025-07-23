import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final comboRepositoryProvider = Provider(
  (ref) => ComboRepository(ref.read(supabaseProvider)),
);

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

  Future<void> updateCombo({
    required int comboId,
    required String name,
    String? description,
    required double price,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await _client
          .from('combos')
          .update({'name': name, 'description': description, 'price': price})
          .eq('id', comboId);

      // Delete existing combo items and re-add them
      await _client.from('combo_items').delete().eq('combo_id', comboId);

      for (final item in items) {
        await _client.from('combo_items').insert({
          'combo_id': comboId,
          'menu_item_id': item['id'],
          'quantity': item['quantity'],
        });
      }
    } catch (e) {
      throw Exception('Error updating combo: $e');
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
      await _client
          .from('combos')
          .update({'is_deleted': true})
          .eq('id', comboId);
    } catch (e) {
      throw Exception('Error deleting combo: $e');
    }
  }
}

final combosProvider =
    StateNotifierProvider<
      CombosNotifier,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      final repository = ref.read(comboRepositoryProvider);
      final restaurantId = ref.watch(restaurantProvider).value?['id'];
      return CombosNotifier(repository, restaurantId);
    });

class CombosNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ComboRepository _repository;
  final int? _restaurantId;

  CombosNotifier(this._repository, this._restaurantId)
    : super(const AsyncValue.loading()) {
    _fetchCombos();
  }

  Future<void> _fetchCombos() async {
    state = const AsyncValue.loading();
    try {
      final combos = await _repository.getCombos(_restaurantId);
      state = AsyncValue.data(combos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCombo({
    required String name,
    String? description,
    required double price,
    required int restaurantId,
    required List<Map<String, dynamic>> items,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addCombo(
        name: name,
        description: description,
        price: price,
        restaurantId: restaurantId,
        items: items,
      );
      await _fetchCombos(); // Re-fetch after adding
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCombo({
    required int comboId,
    required String name,
    String? description,
    required double price,
    required List<Map<String, dynamic>> items,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCombo(
        comboId: comboId,
        name: name,
        description: description,
        price: price,
        items: items,
      );
      await _fetchCombos(); // Re-fetch after updating
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCombo(int comboId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteCombo(comboId);
      await _fetchCombos(); // Re-fetch after deleting
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final manageComboControllerProvider =
    StateNotifierProvider<ManageComboController, AsyncValue<void>>((ref) {
      return ManageComboController(ref.read(comboRepositoryProvider));
    });

class ManageComboController extends StateNotifier<AsyncValue<void>> {
  final ComboRepository _comboRepository;

  ManageComboController(this._comboRepository)
    : super(const AsyncValue.data(null));

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

  Future<void> updateCombo({
    required int comboId,
    required String name,
    String? description,
    required double price,
    required List<Map<String, dynamic>> items,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _comboRepository.updateCombo(
        comboId: comboId,
        name: name,
        description: description,
        price: price,
        items: items,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final deleteComboControllerProvider =
    StateNotifierProvider<DeleteComboController, AsyncValue<void>>((ref) {
      return DeleteComboController(ref.read(comboRepositoryProvider));
    });

class DeleteComboController extends StateNotifier<AsyncValue<void>> {
  final ComboRepository _comboRepository;

  DeleteComboController(this._comboRepository)
    : super(const AsyncValue.data(null));

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

final selectedComboItemsProvider =
    StateNotifierProvider.autoDispose<
      SelectedComboItemsNotifier,
      List<Map<String, dynamic>>
    >((ref) {
      return SelectedComboItemsNotifier();
    });

class SelectedComboItemsNotifier
    extends StateNotifier<List<Map<String, dynamic>>> {
  SelectedComboItemsNotifier() : super([]);

  void setItems(List<Map<String, dynamic>> items) {
    state = List.from(items);
  }

  void addItem(Map<String, dynamic> item) {
    state = [...state, item];
  }

  void removeItem(int id) {
    state = state.where((element) => element['id'] != id).toList();
  }

  void updateItemQuantity(int id, int quantity) {
    state = state.map((item) {
      if (item['id'] == id) {
        return {...item, 'quantity': quantity};
      }
      return item;
    }).toList();
  }
}
