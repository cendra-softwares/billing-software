import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/billing/data/billing_repository.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';
import 'package:seo_biling/features/tables/presentation/providers/table_providers.dart';

final billingControllerProvider =
    StateNotifierProvider<BillingController, AsyncValue<void>>((ref) {
      return BillingController(ref, ref.watch(billingRepositoryProvider));
    });

class BillingController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final BillingRepository _billingRepository;

  BillingController(this._ref, this._billingRepository)
    : super(const AsyncValue.data(null));

  Future<void> saveBill() async {
    state = const AsyncValue.loading();
    try {
      await _billingRepository.saveBill();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createOrder() async {
    state = const AsyncValue.loading();
    try {
      await _billingRepository.createOrder();
      _ref.read(billItemsProvider.notifier).state = [];
      _ref.read(discountProvider.notifier).state = 0.0;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> holdBill() async {
    state = const AsyncValue.loading();
    try {
      await _billingRepository.holdBill();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restoreHeldBill(int orderId) async {
    state = const AsyncValue.loading();
    try {
      final orderData = await _billingRepository.restoreHeldBill(orderId);

      final billItems = (orderData['order_items'] as List)
          .map(
            (item) => {
              'id': item['menu_items']['id'],
              'name': item['menu_items']['name'],
              'price': item['item_price'],
              'quantity': item['quantity'],
            },
          )
          .toList();

      _ref.read(billItemsProvider.notifier).state = billItems;
      // Not handling discount for now, assuming it's 0 for held bills
      _ref.read(discountProvider.notifier).state = 0.0;

      await _ref
          .read(supabaseProvider)
          .from('orders')
          .update({'status': 'in_progress'})
          .eq('id', orderId);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
