import 'package:isar/isar.dart';

part 'local_schema_model.g.dart';

// Enums based on Supabase schema
enum OrderStatus {
  pending,
  in_progress,
  served,
  cancelled,
  completed,
}

enum UserRole {
  admin,
  owner,
  biller,
  waiter,
}

enum PaymentMethod {
  cash,
  card,
  upi,
}

// Isar Collections based on Supabase tables

@collection
class Restaurant {
  Id id = Isar.autoIncrement;
  String? name;
  String? ownerId;
  String? location;
  String? contactEmail;
  String? contactPhone;
  bool isActive = true;
  DateTime? createdAt;
  bool isDeleted = false;

  @Backlink(to: 'restaurant')
  final profiles = IsarLinks<Profile>();
  @Backlink(to: 'restaurant')
  final restaurantConfigs = IsarLinks<RestaurantConfig>();
  @Backlink(to: 'restaurant')
  final tables = IsarLinks<Table>();
  @Backlink(to: 'restaurant')
  final restaurantMenus = IsarLinks<RestaurantMenu>();
  @Backlink(to: 'restaurant')
  final orders = IsarLinks<Order>();
}

@collection
class RestaurantConfig {
  Id id = Isar.autoIncrement;
  String? primaryColor;
  String? secondaryColor;
  String? accentColor;
  String? logoUrl;
  DateTime? createdAt;

  final restaurant = IsarLink<Restaurant>();
}

@collection
class RestaurantMenu {
  Id id = Isar.autoIncrement;
  double? price;
  bool isAvailable = true;
  bool isDeleted = false;

  final restaurant = IsarLink<Restaurant>();
  final menuItem = IsarLink<MenuItem>();
  @Backlink(to: 'restaurantMenu')
  final orderItems = IsarLinks<OrderItem>();
}

@collection
class MenuItem {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String? name;
  String? description;
  String? imageUrl;
  int? estimatedTimeMinutes;
  bool isDeleted = false;

  @Backlink(to: 'menuItem')
  final restaurantMenus = IsarLinks<RestaurantMenu>();
}

@collection
class Order {
  Id id = Isar.autoIncrement;
  @Enumerated(EnumType.name)
  OrderStatus status = OrderStatus.pending;
  double? total;
  DateTime? placedAt;

  final restaurant = IsarLink<Restaurant>();
  final table = IsarLink<Table>();
  final user = IsarLink<Profile>(); // Assuming user is a profile
  @Backlink(to: 'order')
  final orderItems = IsarLinks<OrderItem>();
  @Backlink(to: 'order')
  final bills = IsarLinks<Bill>();
}

@collection
class OrderItem {
  Id id = Isar.autoIncrement;
  int? quantity;
  double? itemPrice;

  final order = IsarLink<Order>();
  final restaurantMenu = IsarLink<RestaurantMenu>();
}

@collection
class Bill {
  Id id = Isar.autoIncrement;
  double? subtotal;
  double? tax;
  double? discount;
  double? total;
  @Enumerated(EnumType.name)
  PaymentMethod? paymentMethod;
  DateTime? paidAt;

  final order = IsarLink<Order>();
}

@collection
class Table {
  Id id = Isar.autoIncrement;
  String? name;
  int? capacity;
  bool isOccupied = false;
  bool isDeleted = false;
  DateTime? createdAt;

  final restaurant = IsarLink<Restaurant>();
  @Backlink(to: 'table')
  final orders = IsarLinks<Order>();
  @Backlink(to: 'table')
  final tableTimers = IsarLinks<TableTimer>();
}

@collection
class TableTimer {
  Id id = Isar.autoIncrement;
  DateTime? startedAt;
  DateTime? endedAt;

  final table = IsarLink<Table>();
  final order = IsarLink<Order>();
}

@collection
class Profile {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String? userId; // from supabase auth
  String? fullName;
  String? email;
  String? phoneNumber;
  @Enumerated(EnumType.name)
  UserRole role = UserRole.waiter;
  bool isActive = true;
  bool isDeleted = false;
  DateTime? createdAt;

  final restaurant = IsarLink<Restaurant>();
}