import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/widgets/categories_panel.dart';
import 'package:seo_biling/features/billing/presentation/widgets/billing_menu_items_grid.dart';
import 'package:seo_biling/features/billing/presentation/widgets/current_bill_panel.dart';
import 'package:seo_biling/features/billing/presentation/widgets/active_kots_dialog.dart';

class BillingPage extends ConsumerWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing / POS'),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ActiveKotsDialog(),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('Running KOTs'),
          ),
        ],
      ),
      body: Row(
        children: const [
          Expanded(flex: 2, child: CategoriesPanel()),
          Expanded(flex: 4, child: BillingMenuItemsGrid()),
          Expanded(flex: 4, child: CurrentBillPanel()),
        ],
      ),
    );
  }
}
