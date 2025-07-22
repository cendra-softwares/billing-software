import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seo_biling/isar/services/isar_service.dart';
import 'package:seo_biling/features/local_auth/presentation/pages/local_signup_page.dart';
import 'package:seo_biling/features/local_auth/presentation/pages/restaurant_creation_page.dart';
import 'package:seo_biling/features/local_auth/presentation/pages/user_dashboard_page.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_providers.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart'; // Import the model

// Create a global provider for the IsarService
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Debug log to check the current user's role
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    print('Supabase user found: ${currentUser.id}, Role: ${currentUser.role}');
  } else {
    print('Supabase user not found, operating as anonymous.');
  }

  // Initialize the IsarService
  final isarService = IsarService();

  runApp(
    ProviderScope(
      overrides: [
        // Override the provider with the initialized service
        isarServiceProvider.overrideWithValue(isarService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // Helper function to parse hex color string to Color object
  Color _parseHexColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.blueGrey; // Default color if not provided
    }
    String formattedHex = hexColor.replaceAll('#', '');
    if (formattedHex.length == 6) {
      formattedHex = 'FF$formattedHex'; // Add FF for opacity if not present
    }
    return Color(int.parse(formattedHex, radix: 16));
  }

  // Helper to determine foreground color based on background brightness
  Color _getForegroundColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(localAuthControllerProvider);
    final restaurantConfig = authState.currentRestaurantConfig;

    // Get colors from config or use defaults from the model instance
    final config = restaurantConfig ?? RestaurantConfig();
    final primaryColor = _parseHexColor(config.primaryColor);
    final secondaryColor = _parseHexColor(config.secondaryColor);
    final accentColor = _parseHexColor(config.accentColor);

    // Create a dynamic color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      onPrimary: _getForegroundColor(primaryColor),
      secondary: secondaryColor,
      onSecondary: _getForegroundColor(secondaryColor),
      tertiary: accentColor,
      onTertiary: _getForegroundColor(accentColor),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Cendra Billing (Local)',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          actionsIconTheme: IconThemeData(color: colorScheme.onPrimary),
          titleTextStyle: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.secondary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: colorScheme.primary),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
      ),
      home: const LocalAuthGate(), // Use our new local auth gate
    );
  }
}

class LocalAuthGate extends ConsumerStatefulWidget {
  const LocalAuthGate({super.key});

  @override
  ConsumerState<LocalAuthGate> createState() => _LocalAuthGateState();
}

class _LocalAuthGateState extends ConsumerState<LocalAuthGate> {
  @override
  void initState() {
    super.initState();
    // Call checkAuthStatus only once when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(localAuthControllerProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(localAuthControllerProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (authState.currentUser == null) {
      return const LocalSignupPage();
    } else if (authState.currentRestaurant == null) {
      return const RestaurantCreationPage();
    } else {
      return UserDashboardPage(
        userProfile: authState.currentUser!,
        restaurant: authState.currentRestaurant,
        restaurantConfig: authState.currentRestaurantConfig,
      );
    }
  }
}
