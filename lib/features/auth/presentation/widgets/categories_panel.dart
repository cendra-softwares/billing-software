import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/menu_management/presentation/providers/category_providers.dart';
import 'package:seo_biling/features/menu_management/presentation/widgets/category_maker_dialog.dart';
import 'package:seo_biling/features/search/fuzzy_search_service.dart';

class CategoriesPanel extends ConsumerWidget {
  const CategoriesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(categorySearchQueryProvider);
    final fuzzySearchService = ref.read(fuzzySearchServiceProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CategoryMakerDialog(),
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              ref.read(categorySearchQueryProvider.notifier).state = value;
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
                query: searchQuery,
                items: categories,
                choiceGetter: (category) => category['name'],
              );

              return ListView.builder(
                itemCount: filteredCategories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.list),
                      title: const Text('Show All'),
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            null;
                      },
                    );
                  }
                  final category = filteredCategories[index - 1];
                  final isSelected = selectedCategory?['id'] == category['id'];
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
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  CategoryMakerDialog(category: category),
                            );
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Category'),
                                content: Text(
                                  'Are you sure you want to delete ${category['name']}?',
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
                                deleteCategoryControllerProvider.notifier,
                              );
                              await deleteController.deleteCategory(
                                category['id'],
                              );
                              // Optionally show a CendraAlertService message
                            }
                          }
                        },
                      ),
                      tileColor: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : null,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
                      },
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
