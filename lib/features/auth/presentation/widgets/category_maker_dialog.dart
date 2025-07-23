import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/category_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryMakerDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryMakerDialog({super.key, this.category});

  @override
  ConsumerState<CategoryMakerDialog> createState() =>
      _CategoryMakerDialogState();
}

class _CategoryMakerDialogState extends ConsumerState<CategoryMakerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Color _pickerColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?['name'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.category?['description'] ?? '');
    _pickerColor = widget.category?['color'] != null
        ? Color(int.parse(widget.category!['color'].replaceFirst('#', '0xff')))
        : Colors.blue; // Default color
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final restaurant = ref.read(restaurantProvider).value;
      final colorHex = '#${_pickerColor.value.toRadixString(16).substring(2)}';

      if (widget.category == null) {
        ref.read(addCategoryControllerProvider.notifier).addCategory(
              name: _nameController.text,
              description: _descriptionController.text,
              isDefault: false,
              restaurantId: restaurant?['id'],
              color: colorHex,
            );
      } else {
        ref.read(updateCategoryControllerProvider.notifier).updateCategory(
              categoryId: widget.category!['id'],
              name: _nameController.text,
              description: _descriptionController.text,
              color: colorHex,
            );
      }
      Navigator.of(context).pop();
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) {
              setState(() {
                _pickerColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: categories.when(
                data: (data) => ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final category = data[index];
                    final colorStr = category['color'] as String?;
                    final color = colorStr != null
                        ? Color(int.parse(colorStr.replaceFirst('#', '0xff')))
                        : null;

                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: color ?? Colors.transparent,
                            width: 4,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(category['name']),
                        subtitle: Text(category['description'] ?? ''),
                        trailing: category['is_default']
                            ? null
                            : const Chip(
                                label: Text('Custom'),
                                backgroundColor: Colors.orange,
                              ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            const Divider(),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a category name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _showColorPicker,
                          child: const Text('Pick Color'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _pickerColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.category == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
