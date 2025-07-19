# Dark Mode Toggle Testing Checklist

## 🧪 Automated Tests
Run the following commands to verify functionality:

```powershell
# Install dependencies
flutter pub get

# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Expected Test Results:
- ✅ Counter increments smoke test
- ✅ Theme toggle button exists and works  
- ✅ Theme toggle switch exists and works

## 📱 Manual Testing Checklist

### 1. App Launch
- [ ] App starts in light mode by default
- [ ] UI elements are properly themed
- [ ] No console errors

### 2. App Bar Theme Toggle Button
- [ ] Dark mode icon (🌙) visible in app bar
- [ ] Tapping button switches to dark theme
- [ ] Icon animates to light mode icon (☀️)
- [ ] App bar colors change appropriately
- [ ] Tapping again switches back to light theme

### 3. Settings Theme Toggle Switch
- [ ] Settings card visible at bottom
- [ ] Switch shows OFF position (light mode)
- [ ] Light/dark mode icons visible beside switch
- [ ] Toggling switch changes theme
- [ ] Switch position updates correctly
- [ ] Icons highlight based on current theme

### 4. Theme Persistence
- [ ] Close and reopen app
- [ ] Theme preference is remembered
- [ ] Both toggle controls reflect saved state

### 5. Visual Verification
- [ ] Light theme: Purple app bar, white background
- [ ] Dark theme: Dark app bar, dark background
- [ ] Text remains readable in both themes
- [ ] Cards and buttons properly themed
- [ ] Smooth transitions between themes

### 6. Edge Cases
- [ ] Rapid toggling doesn't cause issues
- [ ] Both toggle methods stay in sync
- [ ] No memory leaks or performance issues

## 🚀 Running the App

```powershell
# Start the app
flutter run

# For web
flutter run -d chrome

# For specific device
flutter devices
flutter run -d [device-id]
```

## 🐛 Troubleshooting

If tests fail:
1. Ensure Flutter SDK is properly installed
2. Run `flutter doctor` to check setup
3. Clear cache: `flutter clean && flutter pub get`
4. Check console for specific error messages

If theme doesn't persist:
1. Check device storage permissions
2. Verify SharedPreferences implementation
3. Test on different platforms (iOS/Android/Web)
