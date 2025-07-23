import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';
import 'package:seo_biling/features/tables/presentation/providers/table_providers.dart';

final activeOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase
      .from('orders')
      .select('*, tables(name)')
      .or('status.eq.pending,status.eq.in_progress,status.eq.running_kot');
  return List<Map<String, dynamic>>.from(response);
});

class ActiveKotsDialog extends ConsumerWidget {
  const ActiveKotsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrdersAsyncValue = ref.watch(activeOrdersProvider);

    return AlertDialog(
      title: const Text('Active KOTs'),
      content: SizedBox(
        width: double.maxFinite,
        child: activeOrdersAsyncValue.when(
          data: (orders) {
            if (orders.isEmpty) {
              return const Center(child: Text('No active orders.'));
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['id']}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Table: ${order['tables'] != null ? order['tables']['name'] : 'Takeaway'}',
                        ),
                        const SizedBox(height: 4),
                        Text('Status: ${order['status']}'),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              final orderId = order['id'];
                              final supabase = ref.read(supabaseProvider);
                              final response = await supabase
                                  .from('order_items')
                                  .select(
                                    '*, restaurant_menus(*, menu_items(*))',
                                  )
                                  .eq('order_id', orderId);

                              final List<Map<String, dynamic>>
                              items = (response as List)
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
                              Navigator.of(context).pop();
                            },
                            child: const Text('Bill'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
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
