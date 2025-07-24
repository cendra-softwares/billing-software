import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrderType {
  dineIn,
  delivery,
  takeAway,
}

class BillingState {
  final List<Map<String, dynamic>> items;
  final double discount;

  BillingState({
    this.items = const [],
    this.discount = 0.0,
  });

  double get subtotal {
    double subtotal = 0.0;
    for (var item in items) {
      subtotal += (item['price'] as num).toDouble() * (item['quantity'] as int);
    }
    return subtotal;
  }

  double get total => subtotal - discount;

  BillingState copyWith({
    List<Map<String, dynamic>>? items,
    double? discount,
  }) {
    return BillingState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
    );
  }
}

final billingStateProvider = StateNotifierProvider.family<BillingStateNotifier, BillingState, OrderType>(
  (ref, orderType) => BillingStateNotifier(),
);

class BillingStateNotifier extends StateNotifier<BillingState> {
  BillingStateNotifier() : super(BillingState());

  void addItem(Map<String, dynamic> item) {
    final existingItemIndex = state.items.indexWhere((i) => i['id'] == item['id']);
    if (existingItemIndex != -1) {
      final updatedItems = [...state.items];
      updatedItems[existingItemIndex]['quantity']++;
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void removeItem(Map<String, dynamic> item) {
    final updatedItems = [...state.items];
    updatedItems.remove(item);
    state = state.copyWith(items: updatedItems);
  }

  void updateQuantity(Map<String, dynamic> item, int quantity) {
    final updatedItems = [...state.items];
    final index = updatedItems.indexOf(item);
    if (quantity > 0) {
      updatedItems[index]['quantity'] = quantity;
      state = state.copyWith(items: updatedItems);
    } else {
      removeItem(item);
    }
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount);
  }

  void reset() {
    state = BillingState();
  }
}