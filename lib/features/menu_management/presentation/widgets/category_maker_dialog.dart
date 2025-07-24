import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/menu_management/presentation/providers/category_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/search/fuzzy_search_service.dart';

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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?['name'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.category?['description'] ?? '',
    );
    _pickerColor = widget.category?['color'] != null
        ? Color(int.parse(widget.category!['color'].replaceFirst('#', '0xff')))
        : Colors.blue;
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
        ref
            .read(addCategoryControllerProvider.notifier)
            .addCategory(
              name: _nameController.text,
              description: _descriptionController.text,
              isDefault: false,
              restaurantId: restaurant?['id'],
              color: colorHex,
            );
      } else {
        ref
            .read(updateCategoryControllerProvider.notifier)
            .updateCategory(
              categoryId: widget.category!['id'],
              name: _nameController.text,
              description: _descriptionController.text,
              color: colorHex,
            );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final fuzzySearchService = ref.read(fuzzySearchServiceProvider);

    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: categoriesAsyncValue.when(
                data: (categories) {
                  final filteredCategories = fuzzySearchService.search(
                    query: _searchQuery,
                    items: categories,
                    choiceGetter: (category) => category['name'],
                  );

                  return ListView.builder(
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final colorStr = category['color'] as String?;
                      final color = colorStr != null
                          ? Color(int.parse(colorStr.replaceFirst('#', '0xff')))
                          : null;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          radius: 15,
                        ),
                        title: Text(category['name']),
                        subtitle: Text(category['description'] ?? ''),
                        trailing: category['is_default']
                            ? const Chip(label: Text('Default'))
                            : null,
                        onTap: () {
                          setState(() {
                            _nameController.text = category['name'];
                            _descriptionController.text =
                                category['description'] ?? '';
                            _pickerColor = color ?? Colors.blue;
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
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
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Category Color'),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: Colors.primaries
                            .map(
                              (color) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _pickerColor = color;
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: color,
                                  radius: 20,
                                  child: _pickerColor == color
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
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
