import 'package:flutter/material.dart';
import 'package:seo_biling/features/billing/presentation/widgets/action_zone.dart';
import 'package:seo_biling/features/billing/presentation/widgets/command_bar.dart';
import 'package:seo_biling/features/billing/presentation/widgets/context_zone.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  flex: 7, // 70% of the screen
                  child: ActionZone(),
                ),
                const Expanded(
                  flex: 3, // 30% of the screen
                  child: ContextZone(),
                ),
              ],
            ),
          ),
          const CommandBar(),
        ],
      ),
    );
  }
}
