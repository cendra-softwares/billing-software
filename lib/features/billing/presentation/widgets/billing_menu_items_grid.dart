import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart';
import 'package:seo_biling/features/billing/presentation/providers/billing_providers.dart';
import 'package:seo_biling/features/menu_management/presentation/providers/category_providers.dart';

class BillingMenuItemsGrid extends ConsumerWidget {
  const BillingMenuItemsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final menuItemsAsyncValue = ref.watch(menuItemsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              ref.read(billingSearchQueryProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: menuItemsAsyncValue.when(
            data: (menuItems) {
              final searchQuery = ref.watch(billingSearchQueryProvider).toLowerCase();
              var itemsToDisplay = menuItems;

              if (selectedCategory != null) {
                itemsToDisplay = itemsToDisplay.where((item) {
                  final menuItemData = item['menu_items'];
                  return menuItemData['category_id'] == selectedCategory['id'];
                }).toList();
              }

              if (searchQuery.isNotEmpty) {
                itemsToDisplay = itemsToDisplay.where((item) {
                  final menuItemData = item['menu_items'];
                  return menuItemData['name'].toLowerCase().contains(searchQuery);
                }).toList();
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: itemsToDisplay.length,
          itemBuilder: (context, index) {
            final item = itemsToDisplay[index];
            final menuItemData = item['menu_items'];
            return InkWell(
              onTap: () {
                final billItems = ref.read(billItemsProvider.notifier);
                final existingItemIndex = billItems.state.indexWhere((billItem) => billItem['id'] == item['id']);

                if (existingItemIndex != -1) {
                  final updatedItems = [...billItems.state];
                  updatedItems[existingItemIndex]['quantity']++;
                  billItems.state = updatedItems;
                } else {
                  billItems.state = [
                    ...billItems.state,
                    {
                      'id': item['id'],
                      'name': menuItemData['name'],
                      'price': item['price'],
                      'quantity': 1,
                    }
                  ];
                }
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      menuItemData['name'],
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '₹${item['price']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}