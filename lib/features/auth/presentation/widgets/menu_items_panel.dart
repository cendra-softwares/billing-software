import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/menu_management/presentation/providers/category_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart';
import 'package:seo_biling/features/auth/presentation/widgets/menu_item_dialog.dart';
import 'package:seo_biling/features/search/fuzzy_search_service.dart';

class MenuItemsPanel extends ConsumerStatefulWidget {
  const MenuItemsPanel({super.key});

  @override
  ConsumerState<MenuItemsPanel> createState() => _MenuItemsPanelState();
}

class _MenuItemsPanelState extends ConsumerState<MenuItemsPanel> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final menuItemsAsyncValue = ref.watch(menuItemsProvider);
    final fuzzySearchService = ref.read(fuzzySearchServiceProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedCategory == null
                      ? 'All Menu Items'
                      : selectedCategory['name'],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const MenuItemDialog(),
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {}); // Rebuild to filter items
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
              PopupMenuButton<String>(
                onSelected: (String result) {
                  ref.read(itemTypeFilterProvider.notifier).state = result;
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'veg', child: Text('Veg')),
                  const PopupMenuItem<String>(
                    value: 'non_veg',
                    child: Text('Non-Veg'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'default',
                    child: Text('Default'),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(priceRangeProvider.notifier).state = null;
                  ref.read(itemTypeFilterProvider.notifier).state = null;
                  _searchController.clear();
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RangeSlider(
            values: ref.watch(priceRangeProvider) ?? const RangeValues(0, 1000),
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              ref.watch(priceRangeProvider)?.start.round().toString() ?? '0',
              ref.watch(priceRangeProvider)?.end.round().toString() ?? '1000',
            ),
            onChanged: (RangeValues values) {
              ref.read(priceRangeProvider.notifier).state = values;
            },
          ),
        ),
        Expanded(
          child: menuItemsAsyncValue.when(
            data: (menuItems) {
              final filteredItems = ref.watch(filteredMenuItemsProvider);
              final searchTerm = _searchController.text;

              List<Map<String, dynamic>> itemsToDisplay = filteredItems;

              if (selectedCategory != null) {
                itemsToDisplay = itemsToDisplay.where((item) {
                  final menuItemData = item['menu_items'];
                  return menuItemData['category_id'] == selectedCategory['id'];
                }).toList();
              }

              if (searchTerm.isNotEmpty) {
                itemsToDisplay = fuzzySearchService.search(
                  query: searchTerm,
                  items: itemsToDisplay,
                  choiceGetter: (item) => item['menu_items']['name'],
                );
              }

              if (itemsToDisplay.isEmpty) {
                return const Center(
                  child: Text('No matching menu items found.'),
                );
              }

              return DataTable(
                columns: const [
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Available')), // New column
                  DataColumn(label: Text('Actions')),
                ],
                rows: itemsToDisplay.map((item) {
                  final menuItemData = item['menu_items'];
                  final itemType = menuItemData['item_type'] as String?;
                  Color sideColor = Colors.transparent;
                  if (itemType == 'veg') {
                    sideColor = Colors.green;
                  } else if (itemType == 'non_veg') {
                    sideColor = Colors.red;
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: sideColor, width: 4),
                            ),
                          ),
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(menuItemData['name']),
                        ),
                      ),
                      DataCell(Text(menuItemData['description'] ?? 'N/A')),
                      DataCell(Text('₹${item['price']}')),
                      DataCell(
                        Switch(
                          value: item['is_available'] as bool,
                          onChanged: (bool value) async {
                            final updateController = ref.read(
                              updateMenuItemAvailabilityControllerProvider
                                  .notifier,
                            );
                            await updateController.updateMenuItemAvailability(
                              item['id'],
                              value,
                            );
                            // Update the local state to reflect the change immediately
                            setState(() {
                              final index = itemsToDisplay.indexWhere(
                                (element) => element['id'] == item['id'],
                              );
                              if (index != -1) {
                                itemsToDisplay[index]['is_available'] = value;
                              }
                            });
                          },
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      MenuItemDialog(menuItem: item),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Menu Item'),
                                    content: Text(
                                      'Are you sure you want to delete ${menuItemData['name']}?',
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
                                  final deleteController = ref.read(
                                    deleteMenuItemControllerProvider.notifier,
                                  );
                                  await deleteController.deleteMenuItem(
                                    item['id'],
                                  );
                                  ref.invalidate(
                                    menuItemsProvider,
                                  ); // Refresh the list after deletion
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
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
