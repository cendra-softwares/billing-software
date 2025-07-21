import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/local_auth/data/local_auth_repository.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart';

class LocalAuthState {
  final bool isLoading;
  final String? error;
  final Profile? currentUser;
  final Restaurant? currentRestaurant;
  final RestaurantConfig? currentRestaurantConfig;

  LocalAuthState({
    this.isLoading = false,
    this.error,
    this.currentUser,
    this.currentRestaurant,
    this.currentRestaurantConfig,
  });

  LocalAuthState copyWith({
    bool? isLoading,
    String? error,
    Profile? currentUser,
    Restaurant? currentRestaurant,
    RestaurantConfig? currentRestaurantConfig,
  }) {
    return LocalAuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUser: currentUser ?? this.currentUser,
      currentRestaurant: currentRestaurant ?? this.currentRestaurant,
      currentRestaurantConfig: currentRestaurantConfig ?? this.currentRestaurantConfig,
    );
  }
}

class LocalAuthController extends StateNotifier<LocalAuthState> {
  final LocalAuthRepository _localAuthRepository;

  LocalAuthController(this._localAuthRepository) : super(LocalAuthState());

  Future<void> signup(String email, String phoneNumber, String fullName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _localAuthRepository.createUser(email, phoneNumber, fullName);
      if (profile != null) {
        state = state.copyWith(isLoading: false, currentUser: profile);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to create user.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> login(String email, String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _localAuthRepository.findUser(email, phoneNumber);
      if (profile != null) {
        await _loadRestaurantData(profile);
      } else {
        state = state.copyWith(isLoading: false, error: 'Invalid email or phone number.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createRestaurant(
    String name,
    String location,
    String contactEmail,
    String contactPhone, {
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? logoUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.currentUser == null) {
        throw Exception('No user logged in to create a restaurant.');
      }
      final restaurant = await _localAuthRepository.createRestaurant(
        state.currentUser!,
        name,
        location,
        contactEmail,
        contactPhone,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        accentColor: accentColor,
        logoUrl: logoUrl,
      );
      if (restaurant != null) {
        await _loadRestaurantData(state.currentUser!);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to create restaurant.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _localAuthRepository.getLoggedInUser();
      if (profile != null) {
        await _loadRestaurantData(profile);
      } else {
        state = state.copyWith(isLoading: false, currentUser: null, currentRestaurant: null, currentRestaurantConfig: null);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadRestaurantData(Profile profile) async {
    final restaurant = await _localAuthRepository.getRestaurantForUser(profile);
    RestaurantConfig? config;
    if (restaurant != null) {
      config = await _localAuthRepository.getRestaurantConfig(restaurant);
    }
    state = state.copyWith(
      isLoading: false,
      currentUser: profile,
      currentRestaurant: restaurant,
      currentRestaurantConfig: config,
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _localAuthRepository.logoutUser();
      state = LocalAuthState(); // Reset state after logout
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateRestaurantConfig(RestaurantConfig config) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _localAuthRepository.updateRestaurantConfig(config);
      // After updating, reload restaurant data to ensure state is consistent
      if (state.currentUser != null) {
        await _loadRestaurantData(state.currentUser!);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}