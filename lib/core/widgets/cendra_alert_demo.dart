import 'package:flutter/material.dart';
import 'cendra_alert.dart';
import 'cendra_alert_service.dart';

/// Demo widget to showcase the new Cendra Alert system
/// Demonstrates all alert types and usage patterns
class CendraAlertDemo extends StatelessWidget {
  const CendraAlertDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cendra Alert System Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cendra Alert System',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compact, fast alerts positioned like modern web apps',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Overlay Alerts Section
            Text(
              'Overlay Alerts (Top-Left, Fast)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => CendraAlertService.showSuccess(
                    context,
                    'Success!',
                    description: 'Your changes have been saved successfully.',
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Success'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => CendraAlertService.showError(
                    context,
                    'Error!',
                    description:
                        'Unable to process your payment. Please try again.',
                  ),
                  icon: const Icon(Icons.error),
                  label: const Text('Error'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => CendraAlertService.showWarning(
                    context,
                    'Warning!',
                    description: 'Your session will expire in 5 minutes.',
                  ),
                  icon: const Icon(Icons.warning),
                  label: const Text('Warning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => CendraAlertService.showInfo(
                    context,
                    'Info',
                    description: 'New features are available in this update.',
                  ),
                  icon: const Icon(Icons.info),
                  label: const Text('Info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => CendraAlertService.showNeutral(
                    context,
                    'Notification',
                    description: 'You have 3 new messages.',
                  ),
                  icon: const Icon(Icons.notifications),
                  label: const Text('Neutral'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Inline Alerts Section
            Text(
              'Inline Alerts (Static)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Success Alert
            const CendraAlert(
              type: CendraAlertType.success,
              title: 'Order Completed',
              description:
                  'Your order has been successfully processed and will be ready in 15 minutes.',
              showCloseButton: false,
            ),
            const SizedBox(height: 12),

            // Error Alert with custom children
            CendraAlert(
              type: CendraAlertType.error,
              title: 'Payment Failed',
              description:
                  'Unable to process your payment. Please check the following:',
              showCloseButton: false,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: const Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    const Text('Check your card details'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: const Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    const Text('Ensure sufficient funds'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: const Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    const Text('Verify billing address'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Warning Alert
            const CendraAlert(
              type: CendraAlertType.warning,
              title: 'Kitchen Delay',
              description:
                  'Orders are taking longer than usual due to high demand. Estimated wait time: 25 minutes.',
              showCloseButton: false,
            ),
            const SizedBox(height: 12),

            // Info Alert
            const CendraAlert(
              type: CendraAlertType.info,
              title: 'New Feature Available',
              description:
                  'You can now split bills by individual items. Try it out on your next order!',
              showCloseButton: false,
            ),
            const SizedBox(height: 12),

            // Neutral Alert
            const CendraAlert(
              type: CendraAlertType.neutral,
              title: 'Table Assignment',
              description:
                  'Customer has been assigned to Table 7. Please prepare the table.',
              showCloseButton: false,
            ),

            const SizedBox(height: 32),

            // Features Card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 5 distinct alert types with unique colors'),
                    const Text(
                      '• Compact size (320px width) positioned top-left',
                    ),
                    const Text('• Fast slide-in from left (200ms animation)'),
                    const Text('• Quick auto-dismiss (2-3 seconds)'),
                    const Text('• Manual dismiss with close button'),
                    const Text('• Support for custom icons and children'),
                    const Text('• Inline and overlay display modes'),
                    const Text('• Replaces traditional snackbars'),
                    const Text('• Modern web app positioning and timing'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
