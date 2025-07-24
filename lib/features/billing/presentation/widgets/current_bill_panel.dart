import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';
import 'package:seo_biling/features/tables/presentation/providers/table_providers.dart';
import 'package:seo_biling/features/billing/presentation/widgets/billing_actions.dart';

class CurrentBillPanel extends ConsumerWidget {
  const CurrentBillPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billItems = ref.watch(billItemsProvider);
    final subtotal = ref.watch(billSubtotalProvider);
    final discount = ref.watch(discountProvider);
    final total = ref.watch(totalAmountProvider);
    final selectedTable = ref.watch(selectedTableProvider);

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              selectedTable == null ? 'Take Away' : 'Table: ${selectedTable.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(),
          Expanded(
            child: billItems.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.receipt_long, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Item Selected',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Please Select Item from Left Menu Item'),
                    ],
                  )
                : DataTable(
                    columns: const [
                      DataColumn(label: Text('ITEMS')),
                      DataColumn(label: Text('QTY.')),
                      DataColumn(label: Text('PRICE')),
                      DataColumn(label: Text('')),
                    ],
                    rows: billItems.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item['name'])),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    final billItemsNotifier = ref.read(
                                      billItemsProvider.notifier,
                                    );
                                    final updatedItems = [
                                      ...billItemsNotifier.state,
                                    ];
                                    final index = updatedItems.indexOf(item);
                                    if (updatedItems[index]['quantity'] > 1) {
                                      updatedItems[index]['quantity']--;
                                      billItemsNotifier.state = updatedItems;
                                    }
                                  },
                                ),
                                Text(item['quantity'].toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    final billItemsNotifier = ref.read(
                                      billItemsProvider.notifier,
                                    );
                                    final updatedItems = [
                                      ...billItemsNotifier.state,
                                    ];
                                    final index = updatedItems.indexOf(item);
                                    updatedItems[index]['quantity']++;
                                    billItemsNotifier.state = updatedItems;
                                  },
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text('₹${item['price']}')),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                final billItemsNotifier = ref.read(
                                  billItemsProvider.notifier,
                                );
                                final updatedItems = [
                                  ...billItemsNotifier.state,
                                ];
                                updatedItems.remove(item);
                                billItemsNotifier.state = updatedItems;
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Subtotal'),
                  trailing: Text('₹${subtotal.toStringAsFixed(2)}'),
                ),
                ListTile(
                  title: const Text('Discount'),
                  trailing: Text('₹${discount.toStringAsFixed(2)}'),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  trailing: Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const BillingActions(),
        ],
      ),
    );
  }
}
