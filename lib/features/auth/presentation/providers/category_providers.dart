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
  }) async {
    final Map<String, dynamic> category = {
      'name': name,
      'description': description,
      'is_default': isDefault,
      'restaurant_id': isDefault ? null : restaurantId,
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

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final categoriesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final restaurant = ref.watch(restaurantProvider).value;
  return ref.watch(categoryRepositoryProvider).getCategories(restaurant?['id']);
});

final addCategoryControllerProvider = StateNotifierProvider<AddCategoryController, AsyncValue<void>>((ref) {
  return AddCategoryController(ref.read(categoryRepositoryProvider));
});

class AddCategoryController extends StateNotifier<AsyncValue<void>> {
  final CategoryRepository _categoryRepository;

  AddCategoryController(this._categoryRepository) : super(const AsyncValue.data(null));

  Future<void> addCategory({
    required String name,
    required String description,
    required bool isDefault,
    int? restaurantId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _categoryRepository.addCategory(
        name: name,
        description: description,
        isDefault: isDefault,
        restaurantId: restaurantId,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}