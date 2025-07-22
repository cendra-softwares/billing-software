import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/data/auth_repository.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';

class LoginState {
  final bool isLoading;
  final String? error;

  LoginState({this.isLoading = false, this.error});
}

class LoginController extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  LoginController(this._authRepository, this._ref) : super(LoginState());

  Future<void> login(String email, String password) async {
    state = LoginState(isLoading: true);
    try {
      await _authRepository.signInWithPassword(email, password);
      _ref.invalidate(restaurantProvider);
      _ref.invalidate(restaurantConfigProvider);
      _ref.invalidate(isRestaurantOwnerProvider);
      state = LoginState();
    } catch (e) {
      state = LoginState(error: e.toString());
    }
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return LoginController(authRepository, ref);
    });
