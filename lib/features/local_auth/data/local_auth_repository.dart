import 'package:isar/isar.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart';
import 'package:seo_biling/isar/services/isar_service.dart';

class LocalAuthRepository {
  final IsarService _isarService;

  LocalAuthRepository(this._isarService);

  Future<Profile?> createUser(
    String email,
    String phoneNumber,
    String fullName,
  ) async {
    final isar = await _isarService.db;
    final newProfile = Profile()
      ..email = email
      ..phoneNumber = phoneNumber
      ..fullName =
          fullName // Assign the new fullName
      ..createdAt = DateTime.now().toUtc()
      ..role = UserRole.owner; // Default new user to owner role

    try {
      await isar.writeTxn(() async {
        await isar.profiles.put(newProfile);
      });
      return newProfile;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<Profile?> findUser(String email, String phoneNumber) async {
    final isar = await _isarService.db;
    final profile = await isar.profiles
        .filter()
        .emailEqualTo(email)
        .phoneNumberEqualTo(phoneNumber)
        .findFirst();
    return profile;
  }

  Future<Profile?> getLoggedInUser() async {
    final isar = await _isarService.db;
    final profile = await isar.profiles.where().findFirst();
    return profile;
  }

  Future<void> logoutUser() async {
    // In a real app, you'd clear a specific session or token here,
    // not delete all user data. For this simplified local auth,
    // we just need to ensure the in-memory state is cleared.
    // No direct Isar operation needed here for "logout" as it's handled by controller.
  }

  Future<Restaurant?> createRestaurant(
    Profile ownerProfile,
    String name,
    String location,
    String contactEmail,
    String contactPhone, {
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? logoUrl,
  }) async {
    final isar = await _isarService.db;
    final newRestaurant = Restaurant()
      ..name = name
      ..ownerId = ownerProfile.id
          .toString() // Use Isar's auto-incremented ID as ownerId
      ..location = location
      ..contactEmail = contactEmail
      ..contactPhone = contactPhone
      ..createdAt = DateTime.now().toUtc();

    final newConfig = RestaurantConfig()
      ..primaryColor = primaryColor ?? RestaurantConfig().primaryColor
      ..secondaryColor = secondaryColor ?? RestaurantConfig().secondaryColor
      ..accentColor = accentColor ?? RestaurantConfig().accentColor
      ..logoUrl = logoUrl
      ..createdAt = DateTime.now().toUtc();

    try {
      await isar.writeTxn(() async {
        await isar.restaurants.put(newRestaurant);
        newConfig.restaurant.value = newRestaurant;
        await isar.restaurantConfigs.put(newConfig);
        ownerProfile.restaurant.value = newRestaurant;
        await isar.profiles.put(
          ownerProfile,
        ); // Update profile with linked restaurant
        await ownerProfile.restaurant.save(); // Explicitly save the link
      });
      return newRestaurant;
    } catch (e) {
      print('Error creating restaurant: $e');
      return null;
    }
  }

  Future<Restaurant?> getRestaurantForUser(Profile profile) async {
    await profile.restaurant.load(); // Ensure the link is loaded
    return profile.restaurant.value;
  }

  Future<RestaurantConfig?> getRestaurantConfig(Restaurant restaurant) async {
    await restaurant.restaurantConfigs.load(); // Ensure the link is loaded
    final config = restaurant.restaurantConfigs.firstOrNull;
    return config;
  }

  Future<void> updateRestaurantConfig(RestaurantConfig config) async {
    final isar = await _isarService.db;
    try {
      await isar.writeTxn(() async {
        await isar.restaurantConfigs.put(config);
        await config.restaurant.save(); // Save the link if it's updated
      });
    } catch (e) {
      print('Error updating restaurant config: $e');
      rethrow; // Re-throw to be caught by controller
    }
  }
}
