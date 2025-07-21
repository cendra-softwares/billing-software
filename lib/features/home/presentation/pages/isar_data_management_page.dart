import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart' as local_schema_model; // Alias for clarity
import 'package:seo_biling/isar/services/isar_service.dart';

class IsarDataManagementPage extends StatefulWidget {
  const IsarDataManagementPage({super.key});

  @override
  State<IsarDataManagementPage> createState() => _IsarDataManagementPageState();
}

class _IsarDataManagementPageState extends State<IsarDataManagementPage> {
  final IsarService isarService = IsarService();
  List<String> tableNames = [
    'Restaurant',
    'RestaurantConfig',
    'RestaurantMenu',
    'MenuItem',
    'Order',
    'OrderItem',
    'Bill',
    'Table',
    'TableTimer',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isar Data Management'),
      ),
      body: ListView.builder(
        itemCount: tableNames.length,
        itemBuilder: (context, index) {
          final tableName = tableNames[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(tableName),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _showAddDialog(context, tableName);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, String tableName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New $tableName'),
          content: SingleChildScrollView(
            child: Column(
              children: _buildFormFields(tableName),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addEntry(tableName);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Map<String, Map<String, dynamic>> _tempData = {};

  @override
  void initState() {
    super.initState();
    _initializeTempData();
  }

  void _initializeTempData() {
    for (var tableName in tableNames) {
      _tempData[tableName] = {};
    }
  }

  List<Widget> _buildFormFields(String tableName) {
    final List<Widget> fields = [];
    final schema = _getSchemaForTable(tableName);

    if (schema == null) {
      return [const Text('Schema not found for this table.')];
    }

    for (var property in schema.properties.values) {
      if (property.name == 'id') continue; // Skip auto-increment ID

      Widget inputWidget;
      switch (property.type) {
        case IsarType.string:
          inputWidget = TextField(
            decoration: InputDecoration(labelText: property.name),
            onChanged: (value) {
              _tempData[tableName]![property.name] = value;
            },
          );
          break;
        case IsarType.long: // bigint in Supabase, map to int in Dart
        case IsarType.int: // integer in Supabase, map to int in Dart
          inputWidget = TextField(
            decoration: InputDecoration(labelText: property.name),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _tempData[tableName]![property.name] = int.tryParse(value);
            },
          );
          break;
        case IsarType.double: // numeric in Supabase, map to double in Dart
          inputWidget = TextField(
            decoration: InputDecoration(labelText: property.name),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _tempData[tableName]![property.name] = double.tryParse(value);
            },
          );
          break;
        case IsarType.bool:
          inputWidget = Row(
            children: [
              Text(property.name),
              Checkbox(
                value: _tempData[tableName]![property.name] ?? false,
                onChanged: (value) {
                  setState(() {
                    _tempData[tableName]![property.name] = value;
                  });
                },
              ),
            ],
          );
          break;
        case IsarType.dateTime:
          inputWidget = ListTile(
            title: Text(property.name),
            subtitle: Text(
              (_tempData[tableName]![property.name] as DateTime?)?.toIso8601String() ?? 'Not set',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _tempData[tableName]![property.name] = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                }
              },
            ),
          );
          break;
        case IsarType.byte:
        case IsarType.byteList:
        case IsarType.intList:
        case IsarType.longList:
        case IsarType.doubleList:
        case IsarType.stringList:
        case IsarType.boolList:
        case IsarType.dateTimeList:
        case IsarType.object:
        case IsarType.objectList:
          // Handle other types or display a message for unsupported types
          inputWidget = Text('${property.name}: Unsupported type ${property.type}');
          break;
        case IsarType.string: // This covers string enums as well
          inputWidget = TextField(
            decoration: InputDecoration(labelText: property.name),
            onChanged: (value) {
              _tempData[tableName]![property.name] = value;
            },
          );
          break;
        case IsarType.int: // This covers int enums as well
          inputWidget = TextField(
            decoration: InputDecoration(labelText: property.name),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _tempData[tableName]![property.name] = int.tryParse(value);
            },
          );
          break;
        default: // Default case to ensure inputWidget is always initialized
          inputWidget = Text('${property.name}: Unsupported type ${property.type}');
          break;
      }
      fields.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: inputWidget,
      ));
    }
    return fields;
  }

  CollectionSchema<dynamic>? _getSchemaForTable(String tableName) {
    switch (tableName) {
      case 'Restaurant':
        return local_schema_model.RestaurantSchema;
      case 'RestaurantConfig':
        return local_schema_model.RestaurantConfigSchema;
      case 'RestaurantMenu':
        return local_schema_model.RestaurantMenuSchema;
      case 'MenuItem':
        return local_schema_model.MenuItemSchema;
      case 'Order':
        return local_schema_model.OrderSchema;
      case 'OrderItem':
        return local_schema_model.OrderItemSchema;
      case 'Bill':
        return local_schema_model.BillSchema;
      case 'Table':
        return local_schema_model.TableSchema;
      case 'TableTimer':
        return local_schema_model.TableTimerSchema;
      case 'Profile':
        return local_schema_model.ProfileSchema;
      default:
        return null;
    }
  }

  void _addEntry(String tableName) async {
    final isar = await isarService.db;
    final data = _tempData[tableName]!;

    dynamic newObject;
    switch (tableName) {
      case 'Restaurant':
        newObject = local_schema_model.Restaurant()
          ..name = data['name']
          ..location = data['location']
          ..ownerId = data['ownerId']
          ..contactEmail = data['contactEmail']
          ..contactPhone = data['contactPhone']
          ..isActive = data['isActive'] ?? true
          ..createdAt = data['createdAt'] ?? DateTime.now()
          ..isDeleted = data['isDeleted'] ?? false;
        await isar.writeTxn(() async {
          await isar.restaurants.put(newObject);
        });
        break;
      case 'RestaurantConfig':
        newObject = local_schema_model.RestaurantConfig()
          ..primaryColor = data['primaryColor']
          ..secondaryColor = data['secondaryColor']
          ..accentColor = data['accentColor']
          ..logoUrl = data['logoUrl']
          ..createdAt = data['createdAt'] ?? DateTime.now();
        await isar.writeTxn(() async {
          await isar.restaurantConfigs.put(newObject);
        });
        break;
      case 'RestaurantMenu':
        newObject = local_schema_model.RestaurantMenu()
          ..price = data['price']
          ..isAvailable = data['isAvailable'] ?? true
          ..isDeleted = data['isDeleted'] ?? false;
        await isar.writeTxn(() async {
          await isar.restaurantMenus.put(newObject);
        });
        break;
      case 'MenuItem':
        newObject = local_schema_model.MenuItem()
          ..name = data['name']
          ..description = data['description']
          ..imageUrl = data['imageUrl']
          ..estimatedTimeMinutes = data['estimatedTimeMinutes']
          ..isDeleted = data['isDeleted'] ?? false;
        await isar.writeTxn(() async {
          await isar.menuItems.put(newObject);
        });
        break;
      case 'Order':
        newObject = local_schema_model.Order()
          ..status = local_schema_model.OrderStatus.values.byName(data['status'] ?? 'pending')
          ..total = data['total']
          ..placedAt = data['placedAt'] ?? DateTime.now();
        await isar.writeTxn(() async {
          await isar.orders.put(newObject);
        });
        break;
      case 'OrderItem':
        newObject = local_schema_model.OrderItem()
          ..quantity = data['quantity']
          ..itemPrice = data['itemPrice'];
        await isar.writeTxn(() async {
          await isar.orderItems.put(newObject);
        });
        break;
      case 'Bill':
        newObject = local_schema_model.Bill()
          ..subtotal = data['subtotal']
          ..tax = data['tax'] ?? 0.0
          ..discount = data['discount'] ?? 0.0
          ..total = data['total']
          ..paymentMethod = local_schema_model.PaymentMethod.values.byName(data['paymentMethod'] ?? 'cash')
          ..paidAt = data['paidAt'];
        await isar.writeTxn(() async {
          await isar.bills.put(newObject);
        });
        break;
      case 'Table':
        newObject = local_schema_model.Table()
          ..name = data['name']
          ..capacity = data['capacity']
          ..isOccupied = data['isOccupied'] ?? false
          ..isDeleted = data['isDeleted'] ?? false
          ..createdAt = data['createdAt'] ?? DateTime.now();
        await isar.writeTxn(() async {
          await isar.tables.put(newObject);
        });
        break;
      case 'TableTimer':
        newObject = local_schema_model.TableTimer()
          ..startedAt = data['startedAt'] ?? DateTime.now()
          ..endedAt = data['endedAt'];
        await isar.writeTxn(() async {
          await isar.tableTimers.put(newObject);
        });
        break;
      case 'Profile':
        newObject = local_schema_model.Profile()
          ..userId = data['userId']
          ..fullName = data['fullName']
          ..email = data['email']
          ..phoneNumber = data['phoneNumber']
          ..role = local_schema_model.UserRole.values.byName(data['role'] ?? 'waiter')
          ..isActive = data['isActive'] ?? true
          ..isDeleted = data['isDeleted'] ?? false
          ..createdAt = data['createdAt'] ?? DateTime.now();
        await isar.writeTxn(() async {
          await isar.profiles.put(newObject);
        });
        break;
    }
    _initializeTempData(); // Clear form fields after adding
    setState(() {}); // Refresh the UI
  }
}