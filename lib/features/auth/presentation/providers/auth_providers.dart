import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final authMessageProvider = StateProvider<String?>((ref) => null);

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getUserProfile();
});

final isRestaurantOwnerProvider = FutureProvider<bool>((ref) async {
  final userProfile = await ref.watch(userProfileProvider.future);
  return userProfile?['restaurant_id'] != null;
});