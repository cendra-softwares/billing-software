# Cendra Sync System: Implementation Guide

## 1. Overview

The Cendra Sync System is the backbone of our offline-first architecture. It ensures seamless data synchronization between the local **Isar** database and the remote **Supabase** backend. This guide provides a comprehensive overview of the sync process, from data flow and conflict resolution to best practices and error handling.

**Core Principles:**
- **Offline-First:** The application must be fully functional without an internet connection. All data is read from and written to the local Isar database first.
- **Data Integrity:** The sync process must ensure that data remains consistent between the local and remote databases.
- **Reliability:** The system should gracefully handle network interruptions and automatically resume syncing when connectivity is restored.

---

## 2. Architecture & Data Flow

The sync system is built on a simple, robust architecture:

- **Isar (Local Database):** The single source of truth for the application UI. It provides fast, offline access to all data.
- **Supabase (Remote Backend):** The central repository for all data. It ensures data is backed up and accessible across multiple devices.
- **Sync Repository:** A dedicated service layer that orchestrates the data flow between Isar and Supabase.

### Data Flow

The sync process is bidirectional:

**A. Outbound (Pushing Local Changes)**

1.  **Flagging:** When a record is created or updated locally, it's marked with `isSynced = false`.
2.  **Detection:** The sync service periodically scans the Isar database for records where `isSynced` is `false`.
3.  **Push:** Unsynced records are sent to Supabase using an `upsert` operation.
4.  **Confirmation:** Upon successful `upsert`, the local record is updated with `isSynced = true`.

**B. Inbound (Pulling Remote Changes)**

1.  **Fetch:** The sync service queries Supabase for records that have been updated since the last successful sync. This is done using a `last_updated` timestamp.
2.  **Write:** The incoming data is written to the local Isar database using `put()` or `putAll()`. This overwrites local data if the remote data is newer.

---

## 3. Implementation Steps

### Step 1: Enhance Your Isar Models

Every Isar model that needs to be synced must include the following fields:

```dart
import 'package:isar/isar.dart';

part 'menu_item.g.dart';

@collection
class MenuItem {
  Id id = Isar.autoIncrement;

  late String name;
  late double price;

  // --- Sync Fields ---
  @Index()
  late DateTime lastUpdated;

  @Index()
  bool isSynced = false;
  // -------------------
}
```

- **`lastUpdated`**: A `DateTime` field to track the last modification time. This is crucial for conflict resolution.
- **`isSynced`**: A `bool` field to easily identify records that need to be pushed to the server.

### Step 2: Create a Sync Repository

For each feature, create a dedicated repository to handle its sync logic. This keeps the code organized and maintainable.

**Example: `ConfigSyncRepository`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart';
import 'package:seo_biling/isar/services/isar_service.dart';

class ConfigSyncRepository {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  ConfigSyncRepository(this._ref);

  // Push local changes to Supabase
  Future<void> syncConfigToSupabase(RestaurantConfig config) async {
    final configData = {
      'restaurant_id': config.restaurantId,
      'primary_color': config.primaryColor,
      'secondary_color': config.secondaryColor,
      'accent_color': config.accentColor,
      'logo_url': config.logoUrl,
      'last_updated': DateTime.now().toIso8601String(),
    };

    try {
      await _supabase.from('restaurant_config').upsert(configData);
      // After successful upsert, mark the local record as synced
    } catch (e) {
      print('Error syncing config to Supabase: $e');
      rethrow;
    }
  }

  // Pull remote changes from Supabase
  Future<void> syncConfigFromSupabase() async {
    // Get the last sync timestamp from a local preferences service
    final lastSync = await _ref.read(preferencesProvider).getLastSync('config');

    final response = await _supabase
        .from('restaurant_config')
        .select()
        .gt('last_updated', lastSync);

    final configs = response.map((data) => RestaurantConfig.fromJson(data)).toList();

    if (configs.isNotEmpty) {
      final isar = await _ref.read(isarServiceProvider.future);
      await isar.writeTxn(() async {
        await isar.restaurantConfigs.putAll(configs);
      });
    }
  }
}
```

### Step 3: Handle Conflict Resolution

The default strategy is **"Last Write Wins"**. The record with the most recent `lastUpdated` timestamp overwrites any other version. This is simple and effective for most use cases.

For more complex scenarios, consider:
- **Merging:** Combine fields from the local and remote versions.
- **User Intervention:** Flag conflicts and allow the user to choose which version to keep.

### Step 4: Triggering the Sync

The sync process can be triggered in several ways:

- **On App Start:** Perform a full sync when the application launches.
- **Periodically:** Use a `Timer` to sync every few minutes.
- **On Connectivity Change:** Use the `connectivity_plus` package to trigger a sync when the device comes online.
- **Manually:** Provide a "Sync Now" button for the user.

---

## 4. Best Practices & Error Handling

- **Batch Operations:** When pushing or pulling multiple records, use batch operations like `upsert` (for Supabase) and `putAll` (for Isar) to improve performance.
- **Background Execution:** Run the sync process in a separate isolate or using a background service to avoid blocking the UI.
- **Error Handling:** Wrap all sync operations in `try-catch` blocks. Implement a retry mechanism with exponential backoff for failed attempts.
- **User Feedback:** Use the `CendraAlertService` to provide clear feedback to the user about the sync status:
  ```dart
  CendraAlertService.showInfo(context, 'Syncing data...');
  CendraAlertService.showSuccess(context, 'Sync complete');
  CendraAlertService.showError(context, 'Sync failed', description: 'Please check your internet connection.');
  ```

---

## 5. Related Files

- `lib/features/sync/data/config_sync_repository.dart`: Example sync repository.
- `lib/isar/services/isar_service.dart`: Isar database service.
- `lib/core/widgets/cendra_alert_service.dart`: For user notifications.