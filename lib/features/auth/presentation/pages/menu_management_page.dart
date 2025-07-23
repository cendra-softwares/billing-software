import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/widgets/additional_tools_dialog.dart';
import 'package:seo_biling/features/auth/presentation/widgets/categories_panel.dart';
import 'package:seo_biling/features/auth/presentation/widgets/combo_management_panel.dart';
import 'package:seo_biling/features/auth/presentation/widgets/menu_items_panel.dart';

class MenuManagementPage extends ConsumerStatefulWidget {
  const MenuManagementPage({super.key});

  @override
  ConsumerState<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends ConsumerState<MenuManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'additional_tools') {
                showDialog(
                  context: context,
                  builder: (context) => const AdditionalToolsDialog(),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'additional_tools',
                child: Text('Additional Tools'),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel (Categories)
          const Expanded(flex: 2, child: CategoriesPanel()),
          // Middle Panel (Menu Items)
          const Expanded(flex: 5, child: MenuItemsPanel()),
          // Right Panel (Promotional Tools)
          const Expanded(flex: 3, child: ComboManagementPanel()),
        ],
      ),
    );
  }
}
