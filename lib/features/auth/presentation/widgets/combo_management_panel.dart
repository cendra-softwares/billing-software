import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/combo_providers.dart';
import 'package:seo_biling/features/auth/presentation/widgets/combo_maker_dialog.dart';
import 'package:seo_biling/features/search/fuzzy_search_service.dart';
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart'; // Add this import

final comboSearchQueryProvider = StateProvider<String>((ref) => '');

class ComboManagementPanel extends ConsumerWidget {
  const ComboManagementPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combosState = ref.watch(combosProvider); // Changed to combosState
    final searchQuery = ref.watch(comboSearchQueryProvider);
    final fuzzySearchService = ref.read(fuzzySearchServiceProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Combo Management',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ComboMakerDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Combo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              ref.read(comboSearchQueryProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'Search combos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: combosState.when(
              // Changed to combosState
              data: (combos) {
                // Calculate summed price for each combo
                final allMenuItemsAsync = ref.watch(menuItemsProvider);
                final allMenuItems = allMenuItemsAsync.value ?? [];

                // Function to calculate summed price
                double calculateSummedPrice(
                  List<Map<String, dynamic>> comboItems,
                ) {
                  double sum = 0.0;
                  for (var comboItem in comboItems) {
                    final menuItem = allMenuItems.firstWhere(
                      (item) =>
                          item['menu_items']['id'] == comboItem['menu_item_id'],
                      orElse: () => {'price': 0.0},
                    );
                    sum +=
                        (menuItem['price'] as double) *
                        (comboItem['quantity'] as int);
                  }
                  return sum;
                }

                final filteredCombos = fuzzySearchService.search(
                  query: searchQuery,
                  items: combos,
                  choiceGetter: (combo) => combo['name'],
                );

                if (filteredCombos.isEmpty) {
                  return const Center(child: Text('No combos found.'));
                }
                return ListView.builder(
                  itemCount: filteredCombos.length,
                  itemBuilder: (context, index) {
                    final combo = filteredCombos[index];
                    final comboItems = (combo['combo_items'] as List);
                    final summedPrice = calculateSummedPrice(
                      comboItems.cast<Map<String, dynamic>>(),
                    );
                    final actualPrice = (combo['price'] as num).toDouble();
                    final discountAmount = summedPrice - actualPrice;
                    final discountPercentage = summedPrice > 0
                        ? (discountAmount / summedPrice) * 100
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    combo['name'],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comboItems
                                        .map(
                                          (item) =>
                                              "${item['quantity']}x ${item['menu_items']['name']}",
                                        )
                                        .join(', '),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Actual Price: ₹${actualPrice.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (discountAmount > 0) ...[
                                    Text(
                                      'Summed Price: ₹${summedPrice.toStringAsFixed(2)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Discount: ₹${discountAmount.toStringAsFixed(2)} (${discountPercentage.toStringAsFixed(2)}%)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.green),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ComboMakerDialog(combo: combo),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Combo'),
                                    content: Text(
                                      'Are you sure you want to delete ${combo['name']}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await ref
                                      .read(combosProvider.notifier)
                                      .deleteCombo(combo['id']);
                                }
                              },
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
        ],
      ),
    );
  }
}
