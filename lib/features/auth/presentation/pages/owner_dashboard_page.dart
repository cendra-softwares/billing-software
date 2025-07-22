import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerDashboardPage extends ConsumerWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value?.session?.user;
    final restaurant = ref.watch(restaurantProvider);
    final restaurantConfig = ref.watch(restaurantConfigProvider);

    void showColorPicker() {
      Color pickerColor =
          hexToColor(restaurantConfig.value?['primary_color'] ?? '#3B82F6');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                final color = '#${pickerColor.value.toRadixString(16).substring(2)}';
                try {
                  await Supabase.instance.client
                      .from('restaurant_config')
                      .update({'primary_color': color}).eq(
                          'restaurant_id', restaurant.value!['id']);
                  ref.invalidate(restaurantConfigProvider);
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle error
                }
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
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
                      Row(
                        children: [
                          Text(
                              'Primary Color: ${data?['primary_color'] ?? 'N/A'}'),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: showColorPicker,
                            child: CircleAvatar(
                              backgroundColor:
                                  hexToColor(data?['primary_color'] ?? '#3B82F6'),
                              radius: 15,
                            ),
                          )
                        ],
                      ),
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
