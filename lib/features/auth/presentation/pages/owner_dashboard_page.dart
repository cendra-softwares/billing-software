import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/auth/presentation/pages/menu_management_page.dart';
import 'package:seo_biling/features/auth/presentation/providers/theme_provider.dart';
import 'package:seo_biling/features/auth/presentation/widgets/category_maker_dialog.dart';
import 'package:seo_biling/features/auth/presentation/widgets/edit_config_dialog.dart';

class OwnerDashboardPage extends ConsumerWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value?.session?.user;
    final restaurant = ref.watch(restaurantProvider);
    final restaurantConfig = ref.watch(restaurantConfigProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: restaurant.when(
          data: (restaurantData) {
            final restaurantName = restaurantData?['name'] ?? 'Dashboard';
            return restaurantConfig.when(
              data: (configData) {
                final logoUrl = configData?['logo_url'];
                return Row(
                  children: [
                    if (logoUrl != null && logoUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(logoUrl),
                        ),
                      ),
                    Text(restaurantName),
                  ],
                );
              },
              loading: () => Text(restaurantName),
              error: (err, stack) => Text(restaurantName),
            );
          },
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Error'),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'Dashboard Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Config'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                showDialog(
                  context: context,
                  builder: (context) => const EditConfigDialog(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                showDialog(
                  context: context,
                  builder: (context) => const CategoryMakerDialog(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Menu Management'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuManagementPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Owner: ${user?.userMetadata?['full_name'] ?? 'N/A'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                restaurant.when(
                  data: (data) => Text(
                    'Restaurant: ${data?['name'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                ),
                const SizedBox(height: 16),
                restaurantConfig.when(
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant Config:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('Primary Color: ${data?['primary_color'] ?? 'N/A'}'),
                      Text(
                        'Secondary Color: ${data?['secondary_color'] ?? 'N/A'}',
                      ),
                      Text('Accent Color: ${data?['accent_color'] ?? 'N/A'}'),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
