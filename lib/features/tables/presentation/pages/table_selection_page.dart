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
        return Colors.grey[300]!;
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
              ref.read(billItemsProvider.notifier).state = [];
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
          final sections = tables.map((t) => t.section).toSet().toList();

          return ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              final tablesInSection = tables
                  .where((t) => t.section == section)
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
                          maxCrossAxisExtent: 150,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: tablesInSection.length,
                    itemBuilder: (context, index) {
                      final table = tablesInSection[index];
                      return InkWell(
                        onTap: () async {
                          if (table.status != 'blank') {
                            try {
                              final orderResponse = await ref
                                  .read(supabaseProvider)
                                  .from('orders')
                                  .select('id')
                                  .eq('table_id', table.id)
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
                              ref.read(billItemsProvider.notifier).state =
                                  items;
                            } catch (e) {
                              ref.read(billItemsProvider.notifier).state = [];
                            }
                          } else {
                            ref.read(billItemsProvider.notifier).state = [];
                          }

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
                          color: _getColorForStatus(table.status),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12.0,
                                  12.0,
                                  12.0,
                                  32.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (table.status != 'blank') ...[
                                      Text(
                                        '${table.duration.inMinutes} Min',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Text(
                                      table.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (table.status != 'blank') ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        '₹${table.totalAmount.toStringAsFixed(2)}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (table.status != 'blank')
                                Positioned(
                                  bottom: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.visibility,
                                      size: 20,
                                    ),
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
