import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/data/auth_repository.dart';
import 'package:seo_biling/features/auth/presentation/pages/owner_dashboard_page.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seo_biling/features/auth/presentation/providers/category_providers.dart'; // Import CategoryProviders
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart'; // Import MenuItemProviders

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
  final Ref _ref; // Add Ref

  RestaurantSetupController(this._authRepository, this._client, this._ref) // Update constructor
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

      // Seed default categories
      final defaultCategories = [
        {'name': 'Appetizers', 'description': 'Starters and small bites', 'color': '#4CAF50'}, // Green
        {'name': 'Main Courses', 'description': 'Main dishes', 'color': '#2196F3'}, // Blue
        {'name': 'Desserts', 'description': 'Sweet treats', 'color': '#FFC107'}, // Amber
        {'name': 'Beverages', 'description': 'Drinks', 'color': '#9C27B0'}, // Purple
      ];

      final categoryRepository = _ref.read(categoryRepositoryProvider);
      final menuItemRepository = _ref.read(menuItemRepositoryProvider); // Get MenuItemRepository

      for (var categoryData in defaultCategories) {
        await categoryRepository.addCategory(
          name: categoryData['name'] as String,
          description: categoryData['description'] as String,
          isDefault: true,
          restaurantId: restaurantId,
          color: categoryData['color'] as String,
        );
      }

      // Seed default menu items
      final defaultMenuItems = [
        {
          'name': 'Crispy Calamari',
          'description': 'Tender calamari, lightly breaded and fried.',
          'price': 12.99,
          'category_name': 'Appetizers',
        },
        {
          'name': 'Spinach & Artichoke Dip',
          'description': 'Creamy dip served with warm pita bread.',
          'price': 9.99,
          'category_name': 'Appetizers',
        },
        {
          'name': 'Caprese Salad',
          'description': 'Fresh mozzarella, tomatoes, and basil.',
          'price': 11.99,
          'category_name': 'Appetizers',
        },
        {
          'name': 'Mushroom Bruschetta',
          'description': 'Toasted baguette with sautéed mushrooms.',
          'price': 8.99,
          'category_name': 'Appetizers',
        },
        {
          'name': 'Grilled Salmon',
          'description': 'Served with asparagus and mashed potatoes.',
          'price': 24.50,
          'category_name': 'Main Courses',
        },
        {
          'name': 'Chocolate Lava Cake',
          'description': 'Warm chocolate cake with a molten center.',
          'price': 8.00,
          'category_name': 'Desserts',
        },
        {
          'name': 'Coca-Cola',
          'description': 'Refreshing soft drink.',
          'price': 3.00,
          'category_name': 'Beverages',
        },
      ];

      // Fetch categories to get their IDs
      final categories = await categoryRepository.getCategories(restaurantId);
      final categoryMap = {for (var cat in categories) cat['name']: cat['id']};

      for (var itemData in defaultMenuItems) {
        final categoryId = categoryMap[itemData['category_name']];
        if (categoryId != null) {
          await menuItemRepository.addMenuItem(
            name: itemData['name'] as String,
            description: itemData['description'] as String,
            price: itemData['price'] as double,
            categoryId: categoryId,
            restaurantId: restaurantId,
          );
        }
      }

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
  return RestaurantSetupController(authRepository, client, ref); // Pass ref
});