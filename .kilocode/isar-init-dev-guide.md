# Offline-First Restaurant Billing App — Comprehensive Guide

This guide walks you through building an offline-first restaurant billing app using Flutter and **Isar (Community)** for local persistence, then extending it to sync with **Supabase**. The focus is on building a fully functional offline system first.

---

## 🔧 Tools & Stack

* **Frontend**: Flutter (mobile/tablet/desktop responsive)
* **Local Database**: [Isar (Community)](https://github.com/isar-community/isar)
* **Backend & Sync**: Supabase (PostgreSQL, Storage, Auth, Edge Functions)

---

## 🗂️ Folder Structure

```txt
lib/
└──isar/
    ├── models/           # Isar schemas (mirrors Supabase tables)
    ├── services/         # Database access, sync logic
    ├── screens/          # UI Screens
    ├── widgets/          # Reusable UI widgets
    ├── utils/            # Helpers & constants
    └── main.dart         # Entry point
```

---

## 🛠 Step 1: Define Isar Models

### Required Tables/Models:

**IMPORTANT !! : Firstly Check the Supabase MCP for Latest Schema**\\

1. **users** — for app users (admins, waiters, billers, etc.)
2. **restaurants** — restaurant metadata
3. **restaurant\_config** — styling/theme/colors/logo per restaurant
4. **menu\_items** — food items and consumption times
5. **tables** — dining tables
6. **orders** — each session tied to a table
7. **order\_items** — food items inside orders
8. **bills** — generated final receipts
9. **table\_timers** — estimated occupied time

### Example: `user_model.dart`

```dart
import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;
  
  late String name;
  late String email;
  late String phone;
  late String role; // admin/owner/waiter/biller (can use enum-like strings)
  late int restaurantId;

  @Index()
  late DateTime createdAt;
}
```

> Use similar patterns for other models.

---

## 🧪 Step 2: Initialize Isar

```dart
final isar = await Isar.open([
  UserSchema,
  RestaurantSchema,
  RestaurantConfigSchema,
  MenuItemSchema,
  TableSchema,
  OrderSchema,
  OrderItemSchema,
  BillSchema,
  TableTimerSchema,
]);
```

Put this in a service initializer like `isar_service.dart`

---

## 🖼️ Step 3: Build Offline UI

Focus purely on Isar integration:

* CRUD operations using Isar
* Responsive layout (tablet + touch optimized)
* Key screens:

  * Billing panel (menu, order summary, table selector)
  * Table availability dashboard
  * Orders history
  * Menu management
  * Staff management

---

## 🔁 Step 4: Plan Sync with Supabase

Once your offline logic works:

### Strategy

* Use `last_updated_at` and `id` on each model
* Mark local edits with a `isSynced` boolean
* On internet restore:

  * Push unsynced records
  * Pull latest from Supabase and update local Isar DB

### Sync Flow Pseudocode

```dart
for (item in localUnsyncedItems) {
  supabase.from('menu_items').upsert(item);
}

remoteItems = await supabase.from('menu_items').select('*');
for (item in remoteItems) {
  isar.writeTxn(() => isar.menuItems.put(item));
}
```

### Tools

* Use packages like `connectivity_plus` for online/offline detection
* You can use Supabase Edge Functions for conflict resolution logic if needed

---

## ✅ Final Steps

* Secure with Supabase Auth
* Supabase Storage for remote image/logo assets
* Edge Functions for syncing logic (optional but powerful)
* Logging + error reporting
* Testing: Offline, partial sync, full sync, bad network, conflicts

---

Would you like the individual Isar model Dart files generated for you next?
