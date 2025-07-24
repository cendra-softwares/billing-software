import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/combo_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart';

class ComboInfoDialog extends ConsumerWidget {
  final double comboPrice;

  const ComboInfoDialog({super.key, required this.comboPrice});

  double _calculateSummedPrice(
    List<Map<String, dynamic>> selectedItems,
    List<Map<String, dynamic>> allMenuItems,
  ) {
    double sum = 0.0;
    for (var selectedItem in selectedItems) {
      final menuItem = allMenuItems.firstWhere(
        (item) => item['menu_items']['id'] == selectedItem['id'],
        orElse: () => {
          'price': 0.0,
          'menu_items': {'name': 'Unknown'},
        }, // Default if not found
      );
      sum += (menuItem['price'] as double) * (selectedItem['quantity'] as int);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = ref.watch(selectedComboItemsProvider);
    final allMenuItemsAsync = ref.watch(menuItemsProvider);

    return AlertDialog(
      title: const Text('Combo Bill'), // Changed title
      content: allMenuItemsAsync.when(
        data: (allMenuItems) {
          final summedPrice = _calculateSummedPrice(
            selectedItems,
            allMenuItems,
          );
          final discountAmount = summedPrice - comboPrice;
          final discountPercentage = summedPrice > 0
              ? (discountAmount / summedPrice) * 100
              : 0.0;

          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items:', style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                ...selectedItems.map((selectedItem) {
                  final menuItem = allMenuItems.firstWhere(
                    (item) => item['menu_items']['id'] == selectedItem['id'],
                    orElse: () => {
                      'price': 0.0,
                      'menu_items': {'name': 'Unknown'},
                    },
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedItem['quantity']}x ${menuItem['menu_items']['name']}',
                        ),
                        Text(
                          '₹${(menuItem['price'] * selectedItem['quantity']).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Summed Price:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '₹${summedPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Actual Combo Price:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '₹${comboPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount Amount:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '₹${discountAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: discountAmount > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount Percentage:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${discountPercentage.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: discountPercentage > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, s) => Text('Error loading menu items: $e'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
