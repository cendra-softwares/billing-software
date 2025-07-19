# Billing Software

A Flutter-based billing software application with modern UI and dark mode support.

## Features

- ✨ **Dark Mode Toggle**: Seamless switching between light and dark themes
- 💾 **Theme Persistence**: Your theme preference is saved and restored
- 🎨 **Material Design 3**: Modern UI with Material You design system
- 📱 **Responsive Design**: Works across different screen sizes
- 🧪 **Well Tested**: Comprehensive test coverage for theme functionality

## Dark Mode Implementation

The app includes a robust dark mode implementation with the following components:

### ThemeProvider (`lib/providers/theme_provider.dart`)
- Manages theme state using Provider pattern
- Persists theme preference using SharedPreferences
- Provides both light and dark theme configurations
- Supports smooth theme transitions

### Theme Toggle Widgets (`lib/widgets/theme_toggle_button.dart`)
- **ThemeToggleButton**: Icon button for app bar with animated transitions
- **ThemeToggleSwitch**: Switch widget for settings with visual indicators
- Both widgets automatically update when theme changes

### Usage
1. **App Bar Toggle**: Tap the theme icon in the app bar to switch themes
2. **Settings Toggle**: Use the switch in the settings section for more control
3. **Automatic Persistence**: Your theme choice is automatically saved

## Getting Started

This project demonstrates modern Flutter development practices with state management and theming.

### Dependencies
- `provider: ^6.1.2` - State management
- `shared_preferences: ^2.2.3` - Local storage for theme persistence

### Running the App
```bash
flutter pub get
flutter run
```

### Running Tests
```bash
flutter test
```

## Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Provider Package Documentation](https://pub.dev/packages/provider)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
