# Cendra Alert System

A modern, compact alert system that replaces traditional snackbars with beautiful, fast alerts positioned like modern web applications.

## Features

- 🎨 **5 Alert Types**: Success, Error, Warning, Info, and Neutral
- 🌈 **Colorful Design**: Each type has distinct, vibrant colors
- ⚡ **Fast Animations**: Quick slide-in from left (200ms)
- 📍 **Top-Left Positioning**: Like modern web apps (GitHub, Vercel, etc.)
- 📏 **Compact Size**: Fixed 320px width for consistency
- 🎯 **Quick Auto-dismiss**: 2-3 seconds for faster UX
- 🔧 **Flexible**: Support for custom icons, descriptions, and children
- 🎪 **Two Modes**: Overlay (animated) and Inline (static) display

## Quick Start

### Import the service

```dart
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
```

### Basic Usage

```dart
// Success alert
CendraAlertService.showSuccess(
  context,
  'Order Completed',
  description: 'Your order has been successfully processed.',
);

// Error alert
CendraAlertService.showError(
  context,
  'Payment Failed',
  description: 'Unable to process your payment. Please try again.',
);

// Warning alert
CendraAlertService.showWarning(
  context,
  'Session Expiring',
  description: 'Your session will expire in 5 minutes.',
);

// Info alert
CendraAlertService.showInfo(
  context,
  'New Feature',
  description: 'Check out the new bill splitting feature!',
);

// Neutral alert
CendraAlertService.showNeutral(
  context,
  'Table Assignment',
  description: 'Customer assigned to Table 7.',
);
```

## Advanced Usage

### Custom Duration and Dismissal

```dart
CendraAlertService.showError(
  context,
  'Critical Error',
  description: 'This is a critical error that needs attention.',
  duration: const Duration(seconds: 10), // Show for 10 seconds
  dismissible: false, // Cannot be dismissed manually
);
```

### Custom Icons

```dart
CendraAlertService.showSuccess(
  context,
  'Order Ready',
  description: 'Table 5 order is ready for pickup.',
  icon: Icons.restaurant_menu, // Custom icon
);
```

### With Custom Children

```dart
CendraAlertService.showError(
  context,
  'Payment Failed',
  description: 'Please check the following:',
  children: [
    const SizedBox(height: 8),
    const Text('• Verify card details'),
    const Text('• Check available balance'),
    const Text('• Confirm billing address'),
  ],
);
```

## Inline Alerts

For static alerts that don't animate or auto-dismiss:

```dart
const CendraAlert(
  type: CendraAlertType.success,
  title: 'Order Completed',
  description: 'Your order has been successfully processed.',
  showCloseButton: false, // No close button for inline alerts
)
```

## Alert Types & Colors

| Type        | Primary Color   | Use Case                                 |
| ----------- | --------------- | ---------------------------------------- |
| **Success** | Green (#22C55E) | Successful operations, confirmations     |
| **Error**   | Red (#EF4444)   | Errors, failures, critical issues        |
| **Warning** | Amber (#F59E0B) | Warnings, cautions, important notices    |
| **Info**    | Blue (#3B82F6)  | Information, tips, feature announcements |
| **Neutral** | Theme colors    | General notifications, assignments       |

## Migration from Snackbars

### Old Way (Deprecated)

```dart
showSnackbar(context, 'Success message', isError: false);
showSnackbar(context, 'Error message', isError: true);
```

### New Way (Recommended)

```dart
CendraAlertService.showSuccess(context, 'Success', description: 'Success message');
CendraAlertService.showError(context, 'Error', description: 'Error message');
```

## Best Practices

1. **Use appropriate types**: Match the alert type to the message context
2. **Keep titles short**: Use concise, descriptive titles
3. **Provide context**: Use descriptions to give users actionable information
4. **Don't overuse**: Avoid showing multiple alerts simultaneously
5. **Consider duration**: Longer durations for errors, shorter for success messages
6. **Test on devices**: Ensure alerts look good on different screen sizes

## Examples in Cendra

### Restaurant Operations

```dart
// Order completed
CendraAlertService.showSuccess(context, 'Order #123 Ready');

// Kitchen delay
CendraAlertService.showWarning(
  context,
  'Kitchen Delay',
  description: 'Orders running 10 minutes behind schedule.'
);

// Payment processing
CendraAlertService.showInfo(context, 'Processing Payment...');

// Table assignment
CendraAlertService.showNeutral(
  context,
  'Table Updated',
  description: 'Party of 4 moved to Table 12.'
);
```

### Error Handling

```dart
// Network error
CendraAlertService.showError(
  context,
  'Connection Failed',
  description: 'Unable to sync with server. Check your internet connection.',
  duration: const Duration(seconds: 8),
);

// Validation error
CendraAlertService.showWarning(
  context,
  'Invalid Input',
  description: 'Please fill in all required fields.',
);
```

## Demo

Run the demo to see all alert types in action:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CendraAlertDemo()),
);
```

The demo showcases both overlay and inline alerts with various configurations and use cases.
