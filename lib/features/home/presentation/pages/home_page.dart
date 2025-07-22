import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              // Set the logout message before signing out
              ref.read(authMessageProvider.notifier).state =
                  'You have been successfully logged out from Cendra.';
              // Perform the logout
              await ref.read(authRepositoryProvider).signOut();
              ref.invalidate(restaurantProvider);
              ref.invalidate(restaurantConfigProvider);
              ref.invalidate(isRestaurantOwnerProvider);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('Welcome!')),
    );
  }
}
