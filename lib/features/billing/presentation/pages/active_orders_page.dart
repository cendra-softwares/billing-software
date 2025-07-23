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

class ActiveOrdersPage extends ConsumerWidget {
  const ActiveOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(activeOrdersProvider, (_, __) {});
    final activeOrdersAsyncValue = ref.watch(activeOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Active Orders')),
      body: activeOrdersAsyncValue.when(
        data: (orders) {
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Order #${order['id']}'),
                subtitle: Text(
                  'Table: ${order['tables'] != null ? order['tables']['name'] : 'Takeaway'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(order['status']),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        await ref
                            .read(supabaseProvider)
                            .from('orders')
                            .update({'status': 'served'})
                            .eq('id', order['id']);
                        ref.invalidate(activeOrdersProvider);
                      },
                    ),
                  ],
                ),
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
