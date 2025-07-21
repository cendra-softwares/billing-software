import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/widgets/auth_gate.dart';
import 'package:seo_biling/isar/services/isar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      title: 'Cendra Billing',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const AuthGate(),
    );
  }
}
