import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/tables/presentation/providers/table_providers.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';

final billingRepositoryProvider = Provider((ref) => BillingRepository(ref));

class BillingRepository {
  final Ref _ref;
  BillingRepository(this._ref);

  Future<void> saveBill() async {
    final supabase = _ref.read(supabaseProvider);
    final restaurant = _ref.read(restaurantProvider).value;
    final selectedTable = _ref.read(selectedTableProvider);
    final billItems = _ref.read(billItemsProvider);
    final subtotal = _ref.read(billSubtotalProvider);
    final discount = _ref.read(discountProvider);
    final total = _ref.read(totalAmountProvider);
    final user = supabase.auth.currentUser;

    if (restaurant == null || user == null) {
      throw Exception('Missing required data to save the bill.');
    }

    // 1. Create a new order
    final orderData = {
      'restaurant_id': restaurant['id'],
      'user_id': user.id,
      'total': total,
      'status': 'completed',
    };
    if (selectedTable != null) {
      orderData['table_id'] = selectedTable['id'];
    }
    final orderResponse = await supabase
        .from('orders')
        .insert(orderData)
        .select();

    final orderId = orderResponse[0]['id'];

    // 2. Add order items
    final orderItems = billItems
        .map(
          (item) => {
            'order_id': orderId,
            'restaurant_menu_item_id': item['id'],
            'quantity': item['quantity'],
            'item_price': item['price'],
          },
        )
        .toList();

    await supabase.from('order_items').insert(orderItems);

    // 3. Create a new bill
    await supabase.from('bills').insert({
      'order_id': orderId,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'payment_method': 'cash', // Default to cash for now
    });

    // 4. Update table status
    if (selectedTable != null) {
      await supabase
          .from('tables')
          .update({'status': 'paid'})
          .eq('id', selectedTable['id']);
    }
  }

  Future<void> createOrder() async {
    final supabase = _ref.read(supabaseProvider);
    final restaurant = _ref.read(restaurantProvider).value;
    final selectedTable = _ref.read(selectedTableProvider);
    final billItems = _ref.read(billItemsProvider);
    final total = _ref.read(totalAmountProvider);
    final user = supabase.auth.currentUser;

    if (restaurant == null || user == null) {
      throw Exception('Missing required data to create an order.');
    }

    // 1. Create a new order
    final orderData = {
      'restaurant_id': restaurant['id'],
      'user_id': user.id,
      'total': total,
      'status': 'pending',
    };
    if (selectedTable != null) {
      orderData['table_id'] = selectedTable['id'];
    }
    final orderResponse = await supabase.from('orders').insert(orderData).select();

    final orderId = orderResponse[0]['id'];

    // 2. Add order items
    final orderItems = billItems
        .map(
          (item) => {
            'order_id': orderId,
            'restaurant_menu_item_id': item['id'],
            'quantity': item['quantity'],
            'item_price': item['price'],
          },
        )
        .toList();

    await supabase.from('order_items').insert(orderItems);

    // 3. Update table status
    if (selectedTable != null) {
      await supabase
          .from('tables')
          .update({'status': 'running_kot'})
          .eq('id', selectedTable['id']);
    }
  }
}
