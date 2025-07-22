import 'package:flutter/material.dart';
import 'package:seo_biling/features/table_view/presentation/widgets/table_card.dart';

class TableViewPage extends StatelessWidget {
  const TableViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table View'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Delivery')),
          TextButton(onPressed: () {}, child: const Text('Take Away')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Table Reservation'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Contactless'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(context, 'A/C', 28),
            const SizedBox(height: 24),
            _buildSection(context, 'Non A/C', 9),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, int tableCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: tableCount,
          itemBuilder: (context, index) {
            // This is placeholder logic for status and icons
            TableStatus status = TableStatus.blank;
            bool hasPrinter = false;
            bool hasEye = false;
            if (index % 5 == 1) status = TableStatus.running;
            if (index % 5 == 2) status = TableStatus.printed;
            if (index % 5 == 3) {
              status = TableStatus.paid;
              hasPrinter = true;
            }
            if (index % 5 == 4) {
              status = TableStatus.runningKOT;
              hasPrinter = true;
              hasEye = true;
            }

            return TableCard(
              tableName: 'Table ${index + 1}',
              status: status,
              hasPrinter: hasPrinter,
              hasEye: hasEye,
            );
          },
        ),
      ],
    );
  }
}