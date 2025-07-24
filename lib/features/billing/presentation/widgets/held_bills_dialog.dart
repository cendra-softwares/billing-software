import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/billing/presentation/controllers/billing_controller.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';
import 'package:seo_biling/features/tables/presentation/providers/table_providers.dart';

class HeldBillsDialog extends ConsumerWidget {
  const HeldBillsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldBills = ref.watch(heldBillsProvider);

    return AlertDialog(
      title: const Text('Held Bills'),
      content: SizedBox(
        width: double.maxFinite,
        child: heldBills.when(
          data: (bills) {
            if (bills.isEmpty) {
              return const Center(child: Text('No held bills.'));
            }
            return ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                final tableName = bill['tables']?['name'] ?? 'No Table';
                return ListTile(
                  title: Text('Order #${bill['id']} ($tableName)'),
                  subtitle: Text('Total: ₹${bill['total']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        final supabase = ref.read(supabaseProvider);
                        await supabase.rpc(
                          'delete_held_order',
                          params: {'order_id_to_delete': bill['id']},
                        );
                        ref.invalidate(heldBillsProvider);
                        Navigator.of(context).pop();
                      } catch (e) {
                        print('Error deleting held bill: $e');
                      }
                    },
                  ),
                  onTap: () {
                    ref
                        .read(billingControllerProvider.notifier)
                        .restoreHeldBill(bill['id']);
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
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
