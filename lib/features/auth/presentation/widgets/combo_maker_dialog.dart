import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/combo_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart';

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
  final List<Map<String, dynamic>> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.combo?['name']);
    _descriptionController = TextEditingController(text: widget.combo?['description']);
    _priceController = TextEditingController(text: widget.combo?['price']?.toString());

    if (widget.combo != null && widget.combo!['combo_items'] != null) {
      for (var item in widget.combo!['combo_items']) {
        _selectedItems.add({
          'id': item['menu_items']['id'],
          'name': item['menu_items']['name'],
          'quantity': item['quantity'],
        });
      }
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

    return AlertDialog(
      title: const Text('Create Combo'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Combo Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
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
                menuItemsAsync.when(
                  data: (items) => SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final menuItem = item['menu_items'];
                        final isSelected = _selectedItems.any(
                          (selected) => selected['id'] == menuItem['id'],
                        );
                        return CheckboxListTile(
                          title: Text(menuItem['name']),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedItems.add({
                                  'id': menuItem['id'],
                                  'name': menuItem['name'],
                                  'quantity': 1,
                                });
                              } else {
                                _selectedItems.removeWhere(
                                  (selected) =>
                                      selected['id'] == menuItem['id'],
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => const Text('Could not load items'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selected Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = _selectedItems[index];
                      return ListTile(
                        title: Text(item['name']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (item['quantity'] > 1) {
                                      item['quantity']--;
                                    }
                                  });
                                },
                              ),
                              Text(item['quantity'].toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    item['quantity']++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
                await ref.read(addComboControllerProvider.notifier).addCombo(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                      restaurantId: restaurant['id'],
                      items: _selectedItems,
                    );
              } else {
                // TODO: Implement update combo functionality
              }
              ref.invalidate(combosProvider);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.combo == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }
}
