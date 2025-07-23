import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final categoryRepositoryProvider = Provider((ref) => CategoryRepository(ref.read(supabaseProvider)));

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  Future<void> addCategory({
    required String name,
    required String description,
    required bool isDefault,
    int? restaurantId,
    String? color,
  }) async {
    final Map<String, dynamic> category = {
      'name': name,
      'description': description,
      'is_default': isDefault,
      'restaurant_id': isDefault ? null : restaurantId,
      'color': color,
    };

    final response = await _client.from('restaurant_categories').insert(category);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Future<List<Map<String, dynamic>>> getCategories(int? restaurantId) async {
    if (restaurantId == null) {
      return [];
    }
    try {
      final response = await _client
          .from('restaurant_categories')
          .select()
          .or('restaurant_id.eq.$restaurantId,is_default.eq.true');

      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    String? color,
  }) async {
    final Map<String, dynamic> updates = {
      'name': name,
      'description': description,
      'color': color,
    };

    try {
      await _client.from('restaurant_categories').update(updates).eq('id', categoryId);
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }
  Future<void> deleteCategory(int categoryId) async {
    try {
      await _client
          .from('restaurant_categories')
          .update({'is_deleted': true})
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}

final categoriesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final restaurant = ref.watch(restaurantProvider).value;
  return ref.watch(categoryRepositoryProvider).getCategories(restaurant?['id']);
});

final selectedCategoryProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final categorySearchQueryProvider = StateProvider<String>((ref) => '');

final addCategoryControllerProvider = StateNotifierProvider<AddCategoryController, AsyncValue<void>>((ref) {
  return AddCategoryController(ref.read(categoryRepositoryProvider), ref);
});

class AddCategoryController extends StateNotifier<AsyncValue<void>> {
  final CategoryRepository _categoryRepository;
  final Ref _ref;

  AddCategoryController(this._categoryRepository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addCategory({
    required String name,
    required String description,
    required bool isDefault,
    int? restaurantId,
    String? color,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _categoryRepository.addCategory(
        name: name,
        description: description,
        isDefault: isDefault,
        restaurantId: restaurantId,
        color: color,
      );
      _ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final updateCategoryControllerProvider = StateNotifierProvider<UpdateCategoryController, AsyncValue<void>>((ref) {
  return UpdateCategoryController(ref.read(categoryRepositoryProvider), ref);
});

class UpdateCategoryController extends StateNotifier<AsyncValue<void>> {
  final CategoryRepository _categoryRepository;
  final Ref _ref;

  UpdateCategoryController(this._categoryRepository, this._ref) : super(const AsyncValue.data(null));

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    String? color,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _categoryRepository.updateCategory(
        categoryId: categoryId,
        name: name,
        description: description,
        color: color,
      );
      _ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final deleteCategoryControllerProvider = StateNotifierProvider<DeleteCategoryController, AsyncValue<void>>((ref) {
  return DeleteCategoryController(ref.read(categoryRepositoryProvider), ref);
});

class DeleteCategoryController extends StateNotifier<AsyncValue<void>> {
  final CategoryRepository _categoryRepository;
  final Ref _ref;

  DeleteCategoryController(this._categoryRepository, this._ref) : super(const AsyncValue.data(null));

  Future<void> deleteCategory(int categoryId) async {
    state = const AsyncValue.loading();
    try {
      await _categoryRepository.deleteCategory(categoryId);
      _ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}