import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';
import 'package:seo_biling/features/billing/presentation/controllers/billing_controller.dart';
import 'package:seo_biling/features/billing/presentation/widgets/held_bills_dialog.dart';

class BillingActions extends ConsumerWidget {
  const BillingActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billItems = ref.watch(billItemsProvider);
    final isBillEmpty = billItems.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaymentMethodRadio('Cash', true),
                _buildPaymentMethodRadio('Card', false),
                _buildPaymentMethodRadio('Due', false),
                _buildPaymentMethodRadio('Other', false),
                _buildPaymentMethodRadio('Part', false),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                const Text("It's Paid"),
                const SizedBox(width: 16),
                Checkbox(value: true, onChanged: (value) {}),
                const Text('Loyalty'),
                const SizedBox(width: 16),
                Checkbox(value: true, onChanged: (value) {}),
                const Text('Send Feedback SMS'),
              ],
            ),
            const Divider(),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
              children: [
                ElevatedButton(
                  onPressed: isBillEmpty ? null : () {},
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  child: const Text('Save & Print'),
                ),
                ElevatedButton(
                  onPressed: isBillEmpty
                      ? null
                      : () {
                          ref
                              .read(billingControllerProvider.notifier)
                              .createOrder();
                        },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  child: const Text('KOT'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(billingControllerProvider.notifier).holdBill();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  child: const Text('Hold'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const HeldBillsDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  child: const Text('Held Bills'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRadio(String title, bool selected) {
    return ChoiceChip(
      label: Text(title),
      selected: selected,
      onSelected: (value) {},
    );
  }
}
