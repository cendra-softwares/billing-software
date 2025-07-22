import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/category_providers.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory == null
              ? 'All Menu Items'
              : selectedCategory['name'],
        ),
        actions: [
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
          Expanded(
            child: menuItemsAsyncValue.when(
              data: (menuItems) {
                final searchTerm = _searchController.text;
                List<Map<String, dynamic>> itemsToSearch = [];

                if (searchTerm.isEmpty && selectedCategory != null) {
                  itemsToSearch = menuItems.where((item) {
                    final menuItemData = item['menu_items'];
                    return menuItemData['category_id'] ==
                        selectedCategory['id'];
                  }).toList();
                } else {
                  itemsToSearch = menuItems;
                }

                final filteredItems = fuzzySearchService.search(
                  query: searchTerm,
                  items: itemsToSearch,
                  choiceGetter: (item) => item['menu_items']['name'],
                );

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text('No matching menu items found.'),
                  );
                }

                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filteredItems.map((item) {
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
                                    // Optionally show a CendraAlertService message
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
      ),
    );
  }
}
