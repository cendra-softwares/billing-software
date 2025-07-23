import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/billing/data/billing_repository.dart';

final billingControllerProvider = StateNotifierProvider<BillingController, AsyncValue<void>>((ref) {
  return BillingController(ref.watch(billingRepositoryProvider));
});

class BillingController extends StateNotifier<AsyncValue<void>> {
  final BillingRepository _billingRepository;

  BillingController(this._billingRepository) : super(const AsyncValue.data(null));

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
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}