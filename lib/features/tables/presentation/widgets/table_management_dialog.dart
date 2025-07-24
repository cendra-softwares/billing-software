import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/tables/presentation/providers/table_providers.dart';

class TableManagementDialog extends ConsumerStatefulWidget {
  const TableManagementDialog({super.key});

  @override
  ConsumerState<TableManagementDialog> createState() =>
      _TableManagementDialogState();
}

class _TableManagementDialogState extends ConsumerState<TableManagementDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _sectionController;
  String? _selectedSection;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _capacityController = TextEditingController();
    _sectionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final restaurant = ref.read(restaurantProvider).value;
      if (restaurant == null) return;

      await ref.read(supabaseProvider).from('tables').insert({
        'restaurant_id': restaurant['id'],
        'name': _nameController.text,
        'capacity': int.parse(_capacityController.text),
        'section': _selectedSection ?? _sectionController.text,
      });

      ref.invalidate(tablesProvider);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsyncValue = ref.watch(tablesProvider);
    final List<String?> sections = tablesAsyncValue.when(
      data: (tables) =>
          tables.map((t) => t.section).toSet().toList(),
      loading: () => [],
      error: (e, st) => [],
    );

    return AlertDialog(
      title: const Text('Manage Tables'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Table Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a table name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the capacity';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedSection,
                hint: const Text('Select Section'),
                items: sections
                    .whereType<String>()
                    .map(
                      (section) => DropdownMenuItem(
                        value: section,
                        child: Text(section),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value;
                  });
                },
              ),
              if (_selectedSection == null)
                TextFormField(
                  controller: _sectionController,
                  decoration: const InputDecoration(labelText: 'New Section'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Add Table')),
      ],
    );
  }
}
