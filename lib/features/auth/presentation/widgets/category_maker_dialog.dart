import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/category_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';

class CategoryMakerDialog extends ConsumerStatefulWidget {
  const CategoryMakerDialog({super.key});

  @override
  ConsumerState<CategoryMakerDialog> createState() =>
      _CategoryMakerDialogState();
}

class _CategoryMakerDialogState extends ConsumerState<CategoryMakerDialog> {
  final _formKey = GlobalKey<FormState>();
  String _categoryName = '';
  String _categoryDescription = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final restaurant = ref.read(restaurantProvider).value;
      ref
          .read(addCategoryControllerProvider.notifier)
          .addCategory(
            name: _categoryName,
            description: _categoryDescription,
            isDefault: false,
            restaurantId: restaurant?['id'],
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return AlertDialog(
      title: const Text('Manage Categories'),
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
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a category name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _categoryName = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) {
                      _categoryDescription = value!;
                    },
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
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
