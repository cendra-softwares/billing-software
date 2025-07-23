import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/combo_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart';
import 'package:seo_biling/features/search/fuzzy_search_service.dart';
import 'package:seo_biling/features/auth/presentation/widgets/combo_info_dialog.dart'; // Import the new dialog

final menuItemSearchQueryProvider = StateProvider<String>((ref) => '');

class ComboMakerDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? combo;
  const ComboMakerDialog({super.key, this.combo});

  @override
  ConsumerState<ComboMakerDialog> createState() => _ComboMakerDialogState();
}

class _ComboMakerDialogState extends ConsumerState<ComboMakerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.combo?['name']);
    _descriptionController = TextEditingController(
      text: widget.combo?['description'],
    );
    _priceController = TextEditingController(
      text: widget.combo?['price']?.toString(),
    );

    if (widget.combo != null && widget.combo!['combo_items'] != null) {
      // Initialize the Riverpod state with existing combo items
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(selectedComboItemsProvider.notifier)
            .setItems(
              (widget.combo!['combo_items'] as List)
                  .map<Map<String, dynamic>>(
                    (item) => {
                      'id': item['menu_items']['id'],
                      'name': item['menu_items']['name'],
                      'quantity': item['quantity'],
                    },
                  )
                  .toList(),
            );
      });
    } else {
      // Clear the selected items if it's a new combo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedComboItemsProvider.notifier).setItems([]);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItemsAsync = ref.watch(menuItemsProvider);
    final restaurant = ref.watch(restaurantProvider).value;
    final selectedItems = ref.watch(selectedComboItemsProvider);

    return AlertDialog(
      title: const Text('Create Combo'),
      content: Row(
        // Changed to Row to place ComboInfoDialog next to the form
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 400, // Increased width for the form
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Combo Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        // Added onChanged to trigger rebuild for ComboInfoDialog
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        onChanged: (value) {
                          ref.read(menuItemSearchQueryProvider.notifier).state =
                              value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Search menu items...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    menuItemsAsync.when(
                      data: (items) {
                        final searchQuery = ref.watch(
                          menuItemSearchQueryProvider,
                        );
                        final fuzzySearchService = ref.read(
                          fuzzySearchServiceProvider,
                        );

                        final filteredItems = fuzzySearchService.search(
                          query: searchQuery,
                          items: items,
                          choiceGetter: (item) => item['menu_items']['name'],
                        );

                        return SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final menuItem = item['menu_items'];
                              final isSelected = selectedItems.any(
                                (selected) => selected['id'] == menuItem['id'],
                              );
                              final isAvailable =
                                  item['is_available'] as bool? ?? true;

                              return CheckboxListTile(
                                title: Text(
                                  menuItem['name'],
                                  style: TextStyle(
                                    color: isAvailable ? null : Colors.grey,
                                  ),
                                ),
                                subtitle: isAvailable
                                    ? null
                                    : const Text(
                                        'Unavailable',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  if (value == true) {
                                    ref
                                        .read(
                                          selectedComboItemsProvider.notifier,
                                        )
                                        .addItem({
                                          'id': menuItem['id'],
                                          'name': menuItem['name'],
                                          'quantity': 1,
                                        });
                                  } else {
                                    ref
                                        .read(
                                          selectedComboItemsProvider.notifier,
                                        )
                                        .removeItem(menuItem['id']);
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, s) => const Text('Could not load items'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Selected Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item['name']} (x${item['quantity']})'),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  ref
                                      .read(selectedComboItemsProvider.notifier)
                                      .removeItem(item['id']);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20), // Spacer between form and info dialog
          ComboInfoDialog(
            // Display the ComboInfoDialog
            comboPrice: double.tryParse(_priceController.text) ?? 0.0,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && restaurant != null) {
              if (widget.combo == null) {
                await ref
                    .read(
                      manageComboControllerProvider.notifier,
                    ) // Changed to manageComboControllerProvider
                    .addCombo(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                      restaurantId: restaurant['id'],
                      items: selectedItems,
                    );
              } else {
                await ref
                    .read(
                      manageComboControllerProvider.notifier,
                    ) // Changed to manageComboControllerProvider
                    .updateCombo(
                      // Calling updateCombo
                      comboId: widget.combo!['id'], // Pass combo ID
                      name: _nameController.text,
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                      items: selectedItems,
                    );
              }
              ref.refresh(combosProvider); // Changed to ref.refresh
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.combo == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }
}
