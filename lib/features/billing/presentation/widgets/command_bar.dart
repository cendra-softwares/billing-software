import 'package:flutter/material.dart';

class CommandBar extends StatelessWidget {
  const CommandBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            context,
            label: 'Hold Order',
            icon: Icons.pause,
            color: Colors.orange,
            shortcut: 'F5',
          ),
          _buildActionButton(
            context,
            label: 'Cancel Order',
            icon: Icons.cancel,
            color: Colors.red,
            shortcut: 'F6',
          ),
          const Spacer(),
          _buildActionButton(
            context,
            label: 'Apply Discount',
            icon: Icons.local_offer,
            color: Colors.blue,
            shortcut: 'F7',
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.payment),
            label: const Text('Pay (F9)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String shortcut,
  }) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color),
      label: Text(
        '$label ($shortcut)',
        style: TextStyle(color: color),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}