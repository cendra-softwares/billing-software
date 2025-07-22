import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/theme_provider.dart';
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
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const EditConfigDialog(),
              );
            },
          ),
        ],
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
                      Text(
                          'Primary Color: ${data?['primary_color'] ?? 'N/A'}'),
                      Text(
                          'Secondary Color: ${data?['secondary_color'] ?? 'N/A'}'),
                      Text(
                          'Accent Color: ${data?['accent_color'] ?? 'N/A'}'),
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
