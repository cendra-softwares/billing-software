import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final menuItemRepositoryProvider = Provider((ref) => MenuItemRepository(ref.read(supabaseProvider)));

class MenuItemRepository {
  final SupabaseClient _client;

  MenuItemRepository(this._client);

  Future<void> addMenuItem({
    required String name,
    String? description,
    String? imageUrl,
    int? estimatedTimeMinutes,
    required int categoryId,
    required double price,
    required int restaurantId,
    String? itemType,
  }) async {
    final Map<String, dynamic> menuItem = {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'estimated_time_minutes': estimatedTimeMinutes,
      'category_id': categoryId,
      'item_type': itemType,
    };

    try {
      final response = await _client.from('menu_items').insert(menuItem).select();
      if (response.isEmpty) {
        throw Exception('Failed to add menu item: No data returned.');
      }
      final newMenuItemId = response[0]['id'];

      final restaurantMenuItem = {
        'restaurant_id': restaurantId,
        'base_item_id': newMenuItemId,
        'price': price,
      };

      await _client.from('restaurant_menus').insert(restaurantMenuItem);
    } catch (e) {
      throw Exception('Error adding menu item: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems(int? restaurantId) async {
    if (restaurantId == null) {
      return [];
    }
    try {
      final response = await _client
          .from('restaurant_menus')
          .select('*, menu_items(*, restaurant_categories(*))')
          .eq('restaurant_id', restaurantId)
          .eq('is_deleted', false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error fetching menu items: $e');
    }
  }

  Future<void> updateMenuItem({
    required int menuItemId,
    required String name,
    String? description,
    String? imageUrl,
    int? estimatedTimeMinutes,
    required int categoryId,
    required double price,
    required int restaurantMenuItemId,
    String? itemType,
  }) async {
    final Map<String, dynamic> updates = {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'estimated_time_minutes': estimatedTimeMinutes,
      'category_id': categoryId,
      'item_type': itemType,
    };

    try {
      await _client.from('menu_items').update(updates).eq('id', menuItemId);
      await _client.from('restaurant_menus').update({'price': price}).eq('id', restaurantMenuItemId);
    } catch (e) {
      throw Exception('Error updating menu item: $e');
    }
  }

  Future<void> deleteMenuItem(int restaurantMenuItemId) async {
    final response = await _client
        .from('restaurant_menus')
        .update({'is_deleted': true})
        .eq('id', restaurantMenuItemId);

    try {
      await _client.from('restaurant_menus').update({'is_deleted': true}).eq('id', restaurantMenuItemId);
    } catch (e) {
      throw Exception('Error deleting menu item: $e');
    }
  }
}

final menuItemsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final restaurant = ref.watch(restaurantProvider).value;
  return ref.watch(menuItemRepositoryProvider).getMenuItems(restaurant?['id']);
});

final addMenuItemControllerProvider = StateNotifierProvider<AddMenuItemController, AsyncValue<void>>((ref) {
  return AddMenuItemController(ref.read(menuItemRepositoryProvider));
});

class AddMenuItemController extends StateNotifier<AsyncValue<void>> {
  final MenuItemRepository _menuItemRepository;

  AddMenuItemController(this._menuItemRepository) : super(const AsyncValue.data(null));

  Future<void> addMenuItem({
    required String name,
    String? description,
    String? imageUrl,
    int? estimatedTimeMinutes,
    required int categoryId,
    required double price,
    required int restaurantId,
    String? itemType,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _menuItemRepository.addMenuItem(
        name: name,
        description: description,
        imageUrl: imageUrl,
        estimatedTimeMinutes: estimatedTimeMinutes,
        categoryId: categoryId,
        price: price,
        restaurantId: restaurantId,
        itemType: itemType,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final updateMenuItemControllerProvider = StateNotifierProvider<UpdateMenuItemController, AsyncValue<void>>((ref) {
  return UpdateMenuItemController(ref.read(menuItemRepositoryProvider));
});

class UpdateMenuItemController extends StateNotifier<AsyncValue<void>> {
  final MenuItemRepository _menuItemRepository;

  UpdateMenuItemController(this._menuItemRepository) : super(const AsyncValue.data(null));

  Future<void> updateMenuItem({
    required int menuItemId,
    required String name,
    String? description,
    String? imageUrl,
    int? estimatedTimeMinutes,
    required int categoryId,
    required double price,
    required int restaurantMenuItemId,
    String? itemType,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _menuItemRepository.updateMenuItem(
        menuItemId: menuItemId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        estimatedTimeMinutes: estimatedTimeMinutes,
        categoryId: categoryId,
        price: price,
        restaurantMenuItemId: restaurantMenuItemId,
        itemType: itemType,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final deleteMenuItemControllerProvider = StateNotifierProvider<DeleteMenuItemController, AsyncValue<void>>((ref) {
  return DeleteMenuItemController(ref.read(menuItemRepositoryProvider));
});

class DeleteMenuItemController extends StateNotifier<AsyncValue<void>> {
  final MenuItemRepository _menuItemRepository;

  DeleteMenuItemController(this._menuItemRepository) : super(const AsyncValue.data(null));

  Future<void> deleteMenuItem(int restaurantMenuItemId) async {
    state = const AsyncValue.loading();
    try {
      await _menuItemRepository.deleteMenuItem(restaurantMenuItemId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}