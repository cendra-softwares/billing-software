import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/combo_providers.dart';
import 'package:seo_biling/features/auth/presentation/widgets/combo_maker_dialog.dart';

class ComboListDialog extends ConsumerWidget {
  const ComboListDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combosAsyncValue = ref.watch(combosProvider);

    return AlertDialog(
      title: const Text('Manage Combos'),
      content: SizedBox(
        width: double.maxFinite,
        child: combosAsyncValue.when(
          data: (combos) {
            if (combos.isEmpty) {
              return const Center(child: Text('No combos created yet.'));
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: combos.length,
              itemBuilder: (context, index) {
                final combo = combos[index];
                final comboItems = (combo['combo_items'] as List)
                    .map(
                      (item) =>
                          "${item['quantity']}x ${item['menu_items']['name']}",
                    )
                    .join(', ');

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          combo['name'],
                          style: Theme.of(context).textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            comboItems,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Price: ₹${combo['price']}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ComboMakerDialog(combo: combo),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Combo'),
                                    content: Text(
                                      'Are you sure you want to delete ${combo['name']}?',
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
                                  await ref
                                      .read(
                                        deleteComboControllerProvider.notifier,
                                      )
                                      .deleteCombo(combo['id']);
                                  ref.invalidate(combosProvider);
                                }
                              },
                            ),
                          ],
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
