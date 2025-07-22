import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/menu_item_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/category_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/auth/presentation/widgets/category_maker_dialog.dart';
import 'package:seo_biling/features/auth/presentation/widgets/menu_item_dialog.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/features/auth/presentation/widgets/categories_panel.dart';
import 'package:seo_biling/features/auth/presentation/widgets/menu_items_panel.dart';
import 'package:seo_biling/features/auth/presentation/widgets/additional_tools_panel.dart';

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
      ),
      body: Row(
        children: [
          // Left Panel (Categories)
          const Expanded(
            flex: 2,
            child: CategoriesPanel(),
          ),
          // Middle Panel (Menu Items)
          const Expanded(
            flex: 5,
            child: MenuItemsPanel(),
          ),
          // Right Panel (Promotional Tools)
          const Expanded(
            flex: 3,
            child: AdditionalToolsPanel(),
          ),
        ],
      ),
    );
  }
}
