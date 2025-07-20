import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/features/auth/presentation/pages/login_page.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/home/presentation/pages/home_page.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Listen for logout messages
    ref.listen<String?>(authMessageProvider, (previous, next) {
      if (next != null && context.mounted) {
        // Use a post-frame callback with a small delay to ensure the widget tree is stable
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              CendraAlertService.showSuccess(
                context,
                'Logged Out',
                description: next,
              );
              // Clear the message after showing
              ref.read(authMessageProvider.notifier).state = null;
            }
          });
        });
      }
    });

    return authState.when(
      data: (state) {
        if (state.session?.user != null) {
          return const HomePage();
        }
        return const LoginPage();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}
