# Cendra Alert System Usage Guide

## Overview

The Cendra Alert System is a modern, compact notification system that replaces traditional Flutter snackbars. It provides colorful, fast alerts positioned in the top-left corner like modern web applications (GitHub, Vercel, Linear).

## 🚀 Quick Start

### Import the Service
```dart
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
```

### Basic Usage
```dart
// Success notification (2 seconds)
CendraAlertService.showSuccess(context, 'Order Completed');

// Error notification (3 seconds)
CendraAlertService.showError(context, 'Payment Failed');

// Warning notification (3 seconds)
CendraAlertService.showWarning(context, 'Session Expiring');

// Info notification (2 seconds)
CendraAlertService.showInfo(context, 'New Feature Available');

// Neutral notification (2 seconds)
CendraAlertService.showNeutral(context, 'Table Assignment');
```

## 🎨 Alert Types & When to Use

| Type | Color | Duration | Use Cases |
|------|-------|----------|-----------|
| **Success** | Green | 2s | Order completed, payment successful, data saved |
| **Error** | Red | 3s | Payment failed, network error, validation error |
| **Warning** | Amber | 3s | Session expiring, kitchen delay, low stock |
| **Info** | Blue | 2s | New features, tips, general information |
| **Neutral** | Theme | 2s | Table assignments, status updates, notifications |

## 📋 Common Usage Patterns

### Restaurant Operations
```dart
// Order Management
CendraAlertService.showSuccess(context, 'Order #123 Ready');
CendraAlertService.showInfo(context, 'Order Received', 
  description: 'Table 5 - Estimated time: 15 minutes');

// Kitchen Operations
CendraAlertService.showWarning(context, 'Kitchen Delay',
  description: 'Orders running 10 minutes behind schedule');

// Payment Processing
CendraAlertService.showError(context, 'Payment Failed',
  description: 'Card declined. Please try another payment method.');

// Table Management
CendraAlertService.showNeutral(context, 'Table Updated',
  description: 'Party of 4 moved to Table 12');
```

### Authentication & User Management
```dart
// Login/Logout
CendraAlertService.showSuccess(context, 'Welcome Back');
CendraAlertService.showError(context, 'Login Failed',
  description: 'Invalid email or password');

// Profile Updates
CendraAlertService.showSuccess(context, 'Profile Updated');
CendraAlertService.showWarning(context, 'Incomplete Profile',
  description: 'Please add your phone number');
```

### Data Operations
```dart
// Save Operations
CendraAlertService.showSuccess(context, 'Changes Saved');
CendraAlertService.showError(context, 'Save Failed',
  description: 'Unable to save changes. Please try again.');

// Sync Operations
CendraAlertService.showInfo(context, 'Syncing Data...');
CendraAlertService.showSuccess(context, 'Sync Complete');
```

## 🔧 Advanced Usage

### Custom Duration
```dart
CendraAlertService.showError(
  context,
  'Critical Error',
  description: 'System maintenance required',
  duration: const Duration(seconds: 10), // Custom duration
);
```

### Non-dismissible Alerts
```dart
CendraAlertService.showWarning(
  context,
  'System Update',
  description: 'Please do not close the app',
  dismissible: false, // Cannot be dismissed manually
);
```

### Custom Icons
```dart
CendraAlertService.showSuccess(
  context,
  'Order Ready',
  description: 'Table 5 order is ready for pickup',
  icon: Icons.restaurant_menu, // Custom icon
);
```

### With Custom Content
```dart
CendraAlertService.showError(
  context,
  'Payment Issues',
  description: 'Please check the following:',
  children: [
    const SizedBox(height: 8),
    const Text('• Verify card details'),
    const Text('• Check available balance'),
    const Text('• Confirm billing address'),
  ],
);
```

## 🚫 Migration from Old Snackbars

### ❌ Old Way (Deprecated)
```dart
// Don't use this anymore
showSnackbar(context, 'Success message', isError: false);
showSnackbar(context, 'Error message', isError: true);
```

### ✅ New Way (Recommended)
```dart
// Use this instead
CendraAlertService.showSuccess(context, 'Success', 
  description: 'Success message');
CendraAlertService.showError(context, 'Error', 
  description: 'Error message');
```

## 📏 Design Specifications

- **Position**: Top-left corner
- **Width**: Fixed 320px
- **Animation**: Slide-in from left (200ms)
- **Auto-dismiss**: 2-3 seconds depending on type
- **Colors**: Material Design inspired with Cendra branding

## 🎯 Best Practices

### DO ✅
- Use appropriate alert types for the context
- Keep titles short and descriptive
- Provide helpful descriptions for errors
- Use custom icons when they add clarity
- Test on different screen sizes

### DON'T ❌
- Show multiple alerts simultaneously
- Use alerts for critical system errors (use dialogs instead)
- Make titles too long (keep under 30 characters)
- Overuse alerts (they should be meaningful)
- Use neutral alerts for errors or successes

## 🔍 Examples by Feature

### Billing System
```dart
// Invoice generation
CendraAlertService.showSuccess(context, 'Invoice Generated');
CendraAlertService.showError(context, 'Invoice Failed',
  description: 'Unable to generate invoice. Check order details.');

// Payment processing
CendraAlertService.showInfo(context, 'Processing Payment...');
CendraAlertService.showSuccess(context, 'Payment Successful');
```

### Table Management
```dart
// Table status updates
CendraAlertService.showNeutral(context, 'Table Available',
  description: 'Table 8 is now ready for seating');
CendraAlertService.showWarning(context, 'Table Needs Cleaning',
  description: 'Table 3 requires attention');
```

### Inventory Management
```dart
// Stock alerts
CendraAlertService.showWarning(context, 'Low Stock',
  description: 'Chicken breast running low (5 portions left)');
CendraAlertService.showError(context, 'Out of Stock',
  description: 'Salmon is no longer available');
```

## 🎪 Testing

Use the demo widget to test all alert types:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CendraAlertDemo()),
);
```

## 📱 Platform Considerations

- **Desktop**: Alerts appear in top-left corner of the window
- **Mobile**: Alerts respect safe area and appear below status bar
- **Web**: Positioned relative to the browser viewport

## 🔄 Backward Compatibility

The old `showSnackbar` function still works but is deprecated. It automatically routes to the new alert system:
- `isError: false` → `CendraAlertService.showSuccess()`
- `isError: true` → `CendraAlertService.showError()`

## 📚 Related Files

- `lib/core/widgets/cendra_alert.dart` - Main alert widget
- `lib/core/widgets/cendra_alert_service.dart` - Service for showing alerts
- `lib/core/widgets/cendra_alert_demo.dart` - Demo and examples
- `lib/core/widgets/README_ALERTS.md` - Detailed technical documentation
