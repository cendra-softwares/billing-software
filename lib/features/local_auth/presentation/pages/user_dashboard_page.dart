import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart'; // Import Isar models
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_providers.dart'; // Import local auth providers

class UserDashboardPage extends ConsumerWidget {
  final Profile userProfile;
  final Restaurant? restaurant;
  final RestaurantConfig? restaurantConfig;

  const UserDashboardPage({
    super.key,
    required this.userProfile,
    this.restaurant,
    this.restaurantConfig,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Welcome, ${userProfile.fullName ?? userProfile.email ?? 'User'}!',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(localAuthControllerProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(theme, 'Email:', userProfile.email ?? 'N/A'),
            _buildInfoRow(
              theme,
              'Phone Number:',
              userProfile.phoneNumber ?? 'N/A',
            ),
            _buildInfoRow(theme, 'Role:', userProfile.role.name),
            const SizedBox(height: 32),
            if (restaurant != null) ...[
              Text(
                'Linked Restaurant',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                theme,
                'Restaurant Name:',
                restaurant!.name ?? 'N/A',
              ),
              _buildInfoRow(theme, 'Location:', restaurant!.location ?? 'N/A'),
              _buildInfoRow(
                theme,
                'Contact Email:',
                restaurant!.contactEmail ?? 'N/A',
              ),
              _buildInfoRow(
                theme,
                'Contact Phone:',
                restaurant!.contactPhone ?? 'N/A',
              ),
              const SizedBox(height: 32),
            ],
            if (restaurantConfig != null) ...[
              Text(
                'Restaurant Configuration',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  _formatRestaurantConfig(restaurantConfig!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
            if (restaurant == null) ...[
              const SizedBox(height: 32),
              Text(
                'No restaurant linked yet.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to restaurant creation page
                },
                child: const Text('Create Restaurant'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRestaurantConfig(RestaurantConfig config) {
    // Simple JSON-like string representation for display
    return '''
{
  "primaryColor": "${config.primaryColor ?? 'N/A'}",
  "secondaryColor": "${config.secondaryColor ?? 'N/A'}",
  "accentColor": "${config.accentColor ?? 'N/A'}",
  "logoUrl": "${config.logoUrl ?? 'N/A'}",
  "createdAt": "${config.createdAt?.toIso8601String() ?? 'N/A'}"
}
''';
  }
}
