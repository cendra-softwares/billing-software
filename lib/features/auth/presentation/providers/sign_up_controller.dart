import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/data/auth_repository.dart';
import 'package:seo_biling/features/auth/presentation/pages/restaurant_setup_page.dart';
import 'package:seo_biling/features/auth/presentation/pages/sign_up_page.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/home/presentation/pages/home_page.dart';

class SignUpState {
  final bool isLoading;
  final String? error;
  final UserRole? userRole;

  SignUpState({this.isLoading = false, this.error, this.userRole});

  SignUpState copyWith({bool? isLoading, String? error, UserRole? userRole}) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userRole: userRole ?? this.userRole,
    );
  }
}

class SignUpController extends StateNotifier<SignUpState> {
  final AuthRepository _authRepository;

  SignUpController(this._authRepository) : super(SignUpState());

  Future<void> signUp(
      BuildContext context,
      String email,
      String password,
      String fullName,
      String phone,
      UserRole role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signUp(
          email, password, fullName, phone, role.name);
      state = state.copyWith(isLoading: false, userRole: role);

      if (context.mounted) {
        if (role == UserRole.owner) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RestaurantSetupPage()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()));
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final signUpControllerProvider =
    StateNotifierProvider<SignUpController, SignUpState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignUpController(authRepository);
});