import 'package:flutter/material.dart';

enum TableStatus { blank, running, printed, paid, runningKOT }

class TableCard extends StatelessWidget {
  final String tableName;
  final TableStatus status;
  final bool hasPrinter;
  final bool hasEye;

  const TableCard({
    super.key,
    required this.tableName,
    this.status = TableStatus.blank,
    this.hasPrinter = false,
    this.hasEye = false,
  });

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.running:
        return Colors.lightBlue.shade200;
      case TableStatus.printed:
        return Colors.lightGreen.shade200;
      case TableStatus.paid:
        return Colors.yellow.shade200;
      case TableStatus.runningKOT:
        return Colors.orange.shade200;
      case TableStatus.blank:
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getStatusColor(status),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tableName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasPrinter) const Icon(Icons.print, size: 16),
                  if (hasEye) const SizedBox(width: 4),
                  if (hasEye) const Icon(Icons.visibility, size: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}