import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/features/auth/presentation/pages/login_page.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/home/presentation/pages/home_page.dart';
import 'package:seo_biling/features/auth/presentation/pages/restaurant_setup_page.dart';
import 'package:seo_biling/features/auth/presentation/providers/sign_up_controller.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    ref.listen<SignUpState>(signUpControllerProvider, (previous, next) {
      if (previous?.isLoading == true &&
          !next.isLoading &&
          next.error == null) {
        CendraAlertService.showSuccess(
          context,
          'Account Created',
          description: 'Welcome aboard!',
        );
      }
    });

    ref.listen<String?>(authMessageProvider, (previous, next) {
      if (next != null && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              CendraAlertService.showSuccess(
                context,
                'Logged Out',
                description: next,
              );
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
