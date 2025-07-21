import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/isar/services/isar_service.dart';
import 'package:seo_biling/features/local_auth/presentation/pages/local_signup_page.dart';
import 'package:seo_biling/features/local_auth/presentation/pages/restaurant_creation_page.dart';
import 'package:seo_biling/features/local_auth/presentation/pages/user_dashboard_page.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_providers.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_controller.dart';

// Create a global provider for the IsarService
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cendra Billing (Local)',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // Changed theme for local version
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
