import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/widgets/categories_panel.dart';
import 'package:seo_biling/features/billing/presentation/widgets/active_kots_dialog.dart';
import 'package:seo_biling/features/billing/presentation/widgets/billing_menu_items_grid.dart';
import 'package:seo_biling/features/billing/presentation/widgets/current_bill_panel.dart';

class BillingPage extends ConsumerWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing / POS'),
        actions: [],
      ),
      body: Row(
        children: const [
          Expanded(
            flex: 2,
            child: CategoriesPanel(),
          ),
          Expanded(
            flex: 5,
            child: BillingMenuItemsGrid(),
          ),
          Expanded(
            flex: 3,
            child: CurrentBillPanel(),
          ),
        ],
      ),
    );
  }
}