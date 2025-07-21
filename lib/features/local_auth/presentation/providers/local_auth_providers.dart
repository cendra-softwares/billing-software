import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/local_auth/data/local_auth_repository.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_controller.dart';
import 'package:seo_biling/isar/services/isar_service.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final localAuthRepositoryProvider = Provider<LocalAuthRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return LocalAuthRepository(isarService);
});

final localAuthControllerProvider =
    StateNotifierProvider<LocalAuthController, LocalAuthState>((ref) {
  final localAuthRepository = ref.watch(localAuthRepositoryProvider);
  return LocalAuthController(localAuthRepository);
});

final currentProfileProvider = Provider<Profile?>((ref) {
  final authState = ref.watch(localAuthControllerProvider);
  return authState.currentUser;
});

final currentRestaurantProvider = Provider<Restaurant?>((ref) {
  final authState = ref.watch(localAuthControllerProvider);
  return authState.currentRestaurant;
});

final currentRestaurantConfigProvider = Provider<RestaurantConfig?>((ref) {
  final authState = ref.watch(localAuthControllerProvider);
  return authState.currentRestaurantConfig;
});