import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class FuzzySearchService {
  List<T> search<T>({
    required String query,
    required List<T> items,
    required String Function(T item) choiceGetter,
    int limit = 5,
    int cutoff = 70,
  }) {
    if (query.isEmpty) {
      return items;
    }

    final results = extractTop(
      query: query,
      choices: items,
      getter: choiceGetter,
      limit: limit,
      cutoff: cutoff,
    );

    return results.map((r) => r.choice).toList();
  }
}

final fuzzySearchServiceProvider = Provider((ref) => FuzzySearchService());