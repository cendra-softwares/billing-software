import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/data/auth_repository.dart';
import 'package:seo_biling/features/auth/presentation/providers/auth_providers.dart';

class LoginState {
  final bool isLoading;
  final String? error;

  LoginState({this.isLoading = false, this.error});
}

class LoginController extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;

  LoginController(this._authRepository) : super(LoginState());

  Future<void> login(String email, String password) async {
    state = LoginState(isLoading: true);
    try {
      await _authRepository.signInWithPassword(email, password);
      state = LoginState();
    } catch (e) {
      state = LoginState(error: e.toString());
    }
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginController(authRepository);
});