import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';
import 'package:seo_biling/features/billing/presentation/controllers/billing_controller.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/core/services/pdf_service.dart';

class CurrentBillPanel extends ConsumerWidget {
  const CurrentBillPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billItems = ref.watch(billItemsProvider);
    final subtotal = ref.watch(billSubtotalProvider);
    final discount = ref.watch(discountProvider);
    final total = ref.watch(totalAmountProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Current Bill',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: billItems.length,
                itemBuilder: (context, index) {
                  final item = billItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('₹${item['price']} x ${item['quantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final billItemsNotifier = ref.read(
                              billItemsProvider.notifier,
                            );
                            final updatedItems = [...billItemsNotifier.state];
                            if (updatedItems[index]['quantity'] > 1) {
                              updatedItems[index]['quantity']--;
                              billItemsNotifier.state = updatedItems;
                            } else {
                              updatedItems.removeAt(index);
                              billItemsNotifier.state = updatedItems;
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final billItemsNotifier = ref.read(
                              billItemsProvider.notifier,
                            );
                            final updatedItems = [...billItemsNotifier.state];
                            updatedItems[index]['quantity']++;
                            billItemsNotifier.state = updatedItems;
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Subtotal'),
              trailing: Text('₹${subtotal.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Discount'),
              trailing: Text('₹${discount.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ref.watch(billingControllerProvider).isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(billingControllerProvider.notifier)
                          .saveBill();
                      ref
                          .read(billingControllerProvider)
                          .whenOrNull(
                            data: (_) {
                              CendraAlertService.showSuccess(
                                context,
                                'Bill Saved',
                                description:
                                    'The bill has been successfully saved.',
                              );
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            error: (error, stackTrace) {
                              CendraAlertService.showError(
                                context,
                                'Save Failed',
                                description: 'Failed to save bill: $error',
                              );
                            },
                          );
                    },
                    child: const Text('Finalize & Pay'),
                  ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(billingControllerProvider.notifier).createOrder();
                ref.read(billingControllerProvider).whenOrNull(
                  data: (_) {
                    CendraAlertService.showSuccess(
                      context,
                      'Order Created',
                      description: 'The order has been sent to the kitchen.',
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  error: (error, stackTrace) {
                    CendraAlertService.showError(
                      context,
                      'Order Failed',
                      description: 'Failed to create order: $error',
                    );
                  },
                );
              },
              child: const Text('Create Order (KOT)'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pdfService = PdfService();
                final file = await pdfService.createBill(
                  billItems,
                  subtotal,
                  discount,
                  total,
                );
                CendraAlertService.showSuccess(
                  context,
                  'Bill Printed',
                  description: 'Bill saved to ${file.path}',
                );
              },
              child: const Text('Print Bill'),
            ),
            TextButton(
              onPressed: () {
                ref.read(billItemsProvider.notifier).state = [];
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
