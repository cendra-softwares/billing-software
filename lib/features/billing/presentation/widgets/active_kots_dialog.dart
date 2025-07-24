import 'dart:async';

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
      content: activeOrdersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No active orders.'));
          }
          return SizedBox(
            width: 800,
            height: 600,
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: orders
                  .map(
                    (order) =>
                        SizedBox(width: 200, child: KOTCard(order: order)),
                  )
                  .toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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

class KOTCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;

  const KOTCard({super.key, required this.order});

  @override
  ConsumerState<KOTCard> createState() => _KOTCardState();
}

class _KOTCardState extends ConsumerState<KOTCard> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final placedAt = order['placed_at'] != null
        ? DateTime.parse(order['placed_at'])
        : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  order['tables']?['name'] != null
                      ? 'DINE IN: ${order['tables']['name']}'
                      : 'TAKE AWAY',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'KOT No.: ${order['id']}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (placedAt != null)
                  TimerText(placedAt: placedAt)
                else
                  const Text('00:00', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Flexible(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getOrderItems(order['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = snapshot.data ?? [];
                return ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.person, size: 16),
                      title: Text(
                        order['user_id'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ...items.map((item) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          item['name'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          item['quantity'].toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () async {
                  final supabase = ref.read(supabaseProvider);
                  await supabase
                      .from('orders')
                      .update({'status': 'cancelled'})
                      .eq('id', order['id']);
                  ref.invalidate(activeOrdersProvider);
                },
                icon: const Icon(Icons.close, size: 16),
              ),
              ElevatedButton(
                onPressed: () async {
                  final supabase = ref.read(supabaseProvider);
                  await supabase
                      .from('orders')
                      .update({'status': 'served'})
                      .eq('id', order['id']);
                  ref.invalidate(activeOrdersProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Food Is Ready'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getOrderItems(int orderId) async {
    final supabase = ref.read(supabaseProvider);
    final response = await supabase
        .from('order_items')
        .select('*, restaurant_menus(*, menu_items(*))')
        .eq('order_id', orderId);

    final List<Map<String, dynamic>> items = (response as List)
        .map(
          (item) => {
            'name': item['restaurant_menus']['menu_items']['name'],
            'price': item['restaurant_menus']['price'],
            'quantity': item['quantity'],
          },
        )
        .toList();
    return items;
  }
}

class TimerText extends StatefulWidget {
  final DateTime placedAt;

  const TimerText({super.key, required this.placedAt});

  @override
  State<TimerText> createState() => _TimerTextState();
}

class _TimerTextState extends State<TimerText> {
  late Timer _timer;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _duration = DateTime.now().difference(widget.placedAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = DateTime.now().difference(widget.placedAt);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_duration.inMinutes.toString().padLeft(2, '0')}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
    );
  }
}
