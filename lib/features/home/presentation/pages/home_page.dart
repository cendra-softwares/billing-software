import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:seo_biling/isar/models/test_model.dart';
import 'package:seo_biling/main.dart'; // Import main.dart to access the provider

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarService = ref.watch(isarServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Isar Schema Test')),
      body: FutureBuilder<Isar>(
        future: isarService.db,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final isar = snapshot.data!;
            return StreamBuilder<void>(
              stream: isar.testModels.watchLazy(),
              builder: (context, _) {
                return FutureBuilder<List<TestModel>>(
                  future: isar.testModels.where().findAll(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final testModels = snapshot.data!;
                      if (testModels.isEmpty) {
                        return const Center(
                          child: Text('No data. Press + to add.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: testModels.length,
                        itemBuilder: (context, index) {
                          final testModel = testModels[index];
                          return ListTile(
                            title: Text(testModel.name ?? 'No Name'),
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final isar = await isarService.db;
          final newTestModel = TestModel()
            ..name = 'Test Entry ${DateTime.now()}';
          await isar.writeTxn(() async {
            await isar.testModels.put(newTestModel);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
