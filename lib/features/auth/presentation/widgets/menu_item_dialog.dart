import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/category_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';

class MenuItemDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? menuItem;

  const MenuItemDialog({super.key, this.menuItem});

  @override
  ConsumerState<MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends ConsumerState<MenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _estimatedTimeMinutesController;
  late TextEditingController _priceController;
  int? _selectedCategoryId;
  String? _selectedItemType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.menuItem?['menu_items']['name'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.menuItem?['menu_items']['description'] ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.menuItem?['menu_items']['image_url'] ?? '',
    );
    _estimatedTimeMinutesController = TextEditingController(
      text:
          widget.menuItem?['menu_items']['estimated_time_minutes']
              ?.toString() ??
          '',
    );
    _priceController = TextEditingController(
      text: widget.menuItem?['price']?.toString() ?? '',
    );
    _selectedCategoryId = widget.menuItem?['menu_items']['category_id'];
    _selectedItemType = widget.menuItem?['menu_items']['item_type'] ?? 'default';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _estimatedTimeMinutesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;
      final imageUrl = _imageUrlController.text.isEmpty
          ? null
          : _imageUrlController.text;
      final estimatedTimeMinutes = int.tryParse(
        _estimatedTimeMinutesController.text,
      );
      final price = double.tryParse(_priceController.text);
      final categoryId = _selectedCategoryId;
      final itemType = _selectedItemType;
      final restaurantId = ref.read(restaurantProvider).value?['id'];

      if (price == null || categoryId == null || restaurantId == null) {
        CendraAlertService.showError(
          context,
          'Validation Error',
          description: 'Please fill all required fields.',
        );
        return;
      }

      if (widget.menuItem == null) {
        // Add new menu item
        final addController = ref.read(addMenuItemControllerProvider.notifier);
        await addController.addMenuItem(
          name: name,
          description: description,
          imageUrl: imageUrl,
          estimatedTimeMinutes: estimatedTimeMinutes,
          categoryId: categoryId,
          price: price,
          restaurantId: restaurantId,
          itemType: itemType,
        );

        if (addController.state.hasError) {
          CendraAlertService.showError(
            context,
            'Error Adding Menu Item',
            description: addController.state.error.toString(),
          );
        } else {
          CendraAlertService.showSuccess(
            context,
            'Menu Item Added',
            description: '$name added successfully!',
          );
          ref.invalidate(menuItemsProvider); // Refresh menu items
          Navigator.of(context).pop();
        }
      } else {
        // Update existing menu item
        final updateController = ref.read(
          updateMenuItemControllerProvider.notifier,
        );
        final menuItemId = widget.menuItem!['menu_items']['id'];
        final restaurantMenuItemId = widget.menuItem!['id'];

        await updateController.updateMenuItem(
          menuItemId: menuItemId,
          name: name,
          description: description,
          imageUrl: imageUrl,
          estimatedTimeMinutes: estimatedTimeMinutes,
          categoryId: categoryId,
          price: price,
          restaurantMenuItemId: restaurantMenuItemId,
          itemType: itemType,
        );

        if (updateController.state.hasError) {
          CendraAlertService.showError(
            context,
            'Error Updating Menu Item',
            description: updateController.state.error.toString(),
          );
        } else {
          CendraAlertService.showSuccess(
            context,
            'Menu Item Updated',
            description: '$name updated successfully!',
          );
          ref.invalidate(menuItemsProvider); // Refresh menu items
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return AlertDialog(
      title: Text(
        widget.menuItem == null ? 'Add New Menu Item' : 'Edit Menu Item',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
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
                  labelText: 'Description (Optional)',
                ),
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                ),
              ),
              TextFormField(
                controller: _estimatedTimeMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Time (minutes, Optional)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
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
              categoriesAsyncValue.when(
                data: (categories) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map<DropdownMenuItem<int>>((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedCategoryId = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading categories: $err'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedItemType,
                decoration: const InputDecoration(labelText: 'Item Type'),
                items: const [
                  DropdownMenuItem(value: 'veg', child: Text('Vegetarian')),
                  DropdownMenuItem(value: 'non_veg', child: Text('Non-Vegetarian')),
                  DropdownMenuItem(value: 'default', child: Text('Default')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedItemType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an item type';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(widget.menuItem == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
