import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/tables/domain/table_view_model.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final tablesProvider = FutureProvider<List<TableViewModel>>((ref) async {
  final restaurant = await ref.watch(restaurantProvider.future);
  if (restaurant == null) {
    return [];
  }

  final tablesResponse = await ref
      .watch(supabaseProvider)
      .from('tables')
      .select('id, name, status, section')
      .eq('restaurant_id', restaurant['id'])
      .eq('is_deleted', false);

  final tables = List<Map<String, dynamic>>.from(tablesResponse);
  final List<TableViewModel> tableViewModels = [];

  for (final table in tables) {
    final orderResponse = await ref
        .watch(supabaseProvider)
        .from('orders')
        .select('total, placed_at')
        .eq('table_id', table['id'])
        .or('status.eq.pending,status.eq.in_progress,status.eq.running_kot')
        .maybeSingle();

    double totalAmount = 0;
    Duration duration = Duration.zero;

    if (orderResponse != null) {
      totalAmount = (orderResponse['total'] as num?)?.toDouble() ?? 0.0;
      final placedAt = orderResponse['placed_at'] != null
          ? DateTime.parse(orderResponse['placed_at'])
          : null;
      if (placedAt != null) {
        duration = DateTime.now().difference(placedAt);
      }
    }

    tableViewModels.add(
      TableViewModel(
        id: table['id'].toString(),
        name: table['name'],
        status: table['status'],
        section: table['section'],
        totalAmount: totalAmount,
        duration: duration,
      ),
    );
  }

  return tableViewModels;
});

final selectedTableProvider = StateProvider<TableViewModel?>((ref) => null);
