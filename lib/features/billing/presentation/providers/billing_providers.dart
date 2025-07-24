import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/tables/presentation/providers/table_providers.dart';

// This provider will hold the search query for the billing page.
final billingSearchQueryProvider = StateProvider<String>((ref) => '');

// This provider will hold the list of items in the current bill.
final billItemsProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

// This provider will calculate the subtotal of the items in the bill.
final billSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(billItemsProvider);
  double subtotal = 0.0;
  for (var item in items) {
    subtotal += (item['price'] as num).toDouble() * (item['quantity'] as int);
  }
  return subtotal;
});

// This provider will hold the discount applied to the bill.
final discountProvider = StateProvider<double>((ref) => 0.0);

// This provider will calculate the total amount after the discount.
final totalAmountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(billSubtotalProvider);
  final discount = ref.watch(discountProvider);
  return subtotal - discount;
});

final heldBillsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final restaurantData = await ref.watch(restaurantProvider.future);
  if (restaurantData == null) {
    return [];
  }
  final restaurant = restaurantData as Map<String, dynamic>;

  final response = await supabase
      .from('orders')
      .select('*, tables(name)')
      .eq('restaurant_id', restaurant['id'])
      .eq('status', 'held');

  return List<Map<String, dynamic>>.from(response);
});