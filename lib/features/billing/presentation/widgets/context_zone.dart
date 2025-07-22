import 'package:flutter/material.dart';

class ContextZone extends StatelessWidget {
  const ContextZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Order',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          // Itemized List
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item ${index + 1}'),
                  subtitle: const Text('x2'),
                  trailing: const Text('\$10.00'),
                );
              },
            ),
          ),
          const Divider(),
          // Order Summary
          _buildSummaryRow('Subtotal', '\$50.00'),
          _buildSummaryRow('Tax (5%)', '\$2.50'),
          _buildSummaryRow('Discount', '-\$5.00'),
          const Divider(),
          _buildSummaryRow('Total', '\$47.50', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}