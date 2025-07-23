import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/pages/owner_dashboard_page.dart';
import 'package:seo_biling/core/services/pdf_service.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/features/billing/presentation/pages/billing_page.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';
import 'package:seo_biling/features/billing/presentation/widgets/active_kots_dialog.dart';
import 'package:seo_biling/features/tables/presentation/providers/table_providers.dart';

class TableSelectionPage extends ConsumerWidget {
  const TableSelectionPage({super.key});

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'blank':
        return Colors.grey[300]!;
      case 'running':
        return Colors.blue[300]!;
      case 'printed':
        return Colors.green[300]!;
      case 'paid':
        return Colors.yellow[300]!;
      case 'running_kot':
        return Colors.orange[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsyncValue = ref.watch(tablesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table View'),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ActiveKotsDialog(),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('Active KOTs'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delivery_dining),
            label: const Text('Delivery'),
          ),
          TextButton.icon(
            onPressed: () {
              ref.read(selectedTableProvider.notifier).state = null;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BillingPage()),
              );
            },
            icon: const Icon(Icons.takeout_dining),
            label: const Text('Take Away'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OwnerDashboardPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: tablesAsyncValue.when(
        data: (tables) {
          final sections = tables.map((t) => t['section']).toSet().toList();

          return ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              final tablesInSection = tables
                  .where((t) => t['section'] == section)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      section ?? 'Uncategorized',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: tablesInSection.length,
                    itemBuilder: (context, index) {
                      final table = tablesInSection[index];
                      return InkWell(
                        onTap: () {
                          ref.read(selectedTableProvider.notifier).state =
                              table;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BillingPage(),
                            ),
                          );
                        },
                        child: Card(
                          color: _getColorForStatus(table['status']),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  table['name'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              if (table['status'] != 'blank')
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          final orderResponse = await ref
                                              .read(supabaseProvider)
                                              .from('orders')
                                              .select('id')
                                              .eq('table_id', table['id'])
                                              .or(
                                                'status.eq.pending,status.eq.in_progress,status.eq.running_kot',
                                              )
                                              .single();

                                          final orderId = orderResponse['id'];

                                          final orderItemsResponse = await ref
                                              .read(supabaseProvider)
                                              .from('order_items')
                                              .select(
                                                '*, restaurant_menus(*, menu_items(*))',
                                              )
                                              .eq('order_id', orderId);

                                          final List<Map<String, dynamic>>
                                          items = (orderItemsResponse as List)
                                              .map(
                                                (item) => {
                                                  'name':
                                                      item['restaurant_menus']['menu_items']['name'],
                                                  'price':
                                                      item['restaurant_menus']['price'],
                                                  'quantity': item['quantity'],
                                                },
                                              )
                                              .toList();

                                          ref
                                                  .read(
                                                    billItemsProvider.notifier,
                                                  )
                                                  .state =
                                              items;
                                          ref
                                                  .read(
                                                    selectedTableProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              table;

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const BillingPage(),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.print, size: 18),
                                        onPressed: () async {
                                          final orderResponse = await ref
                                              .read(supabaseProvider)
                                              .from('orders')
                                              .select('id, discount')
                                              .eq('table_id', table['id'])
                                              .or(
                                                'status.eq.pending,status.eq.in_progress,status.eq.running_kot',
                                              )
                                              .single();

                                          final orderId = orderResponse['id'];
                                          final discount =
                                              (orderResponse['discount']
                                                      as num?)
                                                  ?.toDouble() ??
                                              0.0;

                                          final orderItemsResponse = await ref
                                              .read(supabaseProvider)
                                              .from('order_items')
                                              .select(
                                                '*, restaurant_menus(*, menu_items(*))',
                                              )
                                              .eq('order_id', orderId);

                                          final List<Map<String, dynamic>>
                                          items = (orderItemsResponse as List)
                                              .map(
                                                (item) => {
                                                  'name':
                                                      item['restaurant_menus']['menu_items']['name'],
                                                  'price':
                                                      item['restaurant_menus']['price'],
                                                  'quantity': item['quantity'],
                                                },
                                              )
                                              .toList();

                                          double subtotal = 0.0;
                                          for (var item in items) {
                                            subtotal +=
                                                (item['price'] as num)
                                                    .toDouble() *
                                                (item['quantity'] as int);
                                          }
                                          final total = subtotal - discount;

                                          final pdfService = PdfService();
                                          final file = await pdfService
                                              .createBill(
                                                items,
                                                subtotal,
                                                discount,
                                                total,
                                              );

                                          CendraAlertService.showSuccess(
                                            context,
                                            'Bill Printed',
                                            description:
                                                'Bill saved to ${file.path}',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
